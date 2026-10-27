import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_formatters.dart';
import '../../data/models/memory_entry.dart';
import '../../data/models/trip.dart';
import '../../data/repositories/travel_app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/local_image.dart';
import '../../shared/widgets/trip_hero.dart';
import '../gallery/photo_viewer_page.dart';

class TripDetailPage extends StatefulWidget {
  const TripDetailPage({super.key, required this.tripId});

  final String tripId;

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Trip? _trip;
  List<MemoryEntry> _memories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final state = context.read<TravelAppState>();
    final trip = await state.getTrip(widget.tripId);
    final memories = await state.memoriesForTrip(widget.tripId);
    if (!mounted) return;
    setState(() {
      _trip = trip;
      _memories = memories;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
      );
    }
    final trip = _trip;
    if (trip == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          title: 'Trip not found',
          description: 'This page wandered off the map.',
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.paper,
            title: Text(trip.title),
            actions: [
              IconButton(
                tooltip: 'Add memory',
                onPressed: () async {
                  await context.push('/memories/new?tripId=${trip.id}');
                  await _load();
                },
                icon: const Icon(Icons.add_photo_alternate_outlined),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  final state = context.read<TravelAppState>();
                  if (value == 'export') {
                    final md = await state.repository.exportTripMarkdown(trip.id);
                    await SharePlus.instance.share(ShareParams(text: md));
                  } else if (value == 'delete') {
                    await state.deleteTrip(trip.id);
                    if (context.mounted) context.go('/trips');
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'export', child: Text('Export as Markdown')),
                  PopupMenuItem(value: 'delete', child: Text('Delete trip')),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(child: TripHero(trip: trip)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabs,
                labelColor: AppColors.ink,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.terracotta,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Timeline'),
                  Tab(text: 'Gallery'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _OverviewTab(memories: _memories, onOpen: _openMemory, onRefresh: _load),
            _TimelineTab(memories: _memories, onOpen: _openMemory),
            _GalleryTab(memories: _memories),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/memories/new?tripId=${trip.id}');
          await _load();
        },
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Add memory'),
      ),
    );
  }

  Future<void> _openMemory(MemoryEntry memory) async {
    await context.push('/memories/${memory.id}');
    await _load();
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(color: AppColors.paper, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.memories,
    required this.onOpen,
    required this.onRefresh,
  });

  final List<MemoryEntry> memories;
  final Future<void> Function(MemoryEntry) onOpen;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return EmptyState(
        eyebrow: 'Empty pages',
        title: 'This page is waiting for a memory.',
        description: 'Add photos and a short story — the scrapbook begins here.',
        actionLabel: 'Add a memory',
        onAction: () => context.push('/memories/new'),
      );
    }

    final grouped = <String, List<MemoryEntry>>{};
    for (final memory in memories) {
      final key = memory.date.toIso8601String().split('T').first;
      grouped.putIfAbsent(key, () => []).add(memory);
    }

    return RefreshIndicator(
      color: AppColors.terracotta,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          for (final entry in grouped.entries) ...[
            Text(
              DateFormatters.timelineHeader(DateTime.parse(entry.key)),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 6),
            Text(
              (entry.value.first.location.split(',').first).toUpperCase(),
              style: GoogleFonts.playfairDisplay(
                fontSize: 30,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 18),
            for (final memory in entry.value) ...[
              _MemoryBlock(memory: memory, onTap: () => onOpen(memory)),
              const SizedBox(height: 36),
            ],
          ],
        ],
      ),
    );
  }
}

class _MemoryBlock extends StatelessWidget {
  const _MemoryBlock({required this.memory, required this.onTap});

  final MemoryEntry memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photos = memory.photos;
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photos.isNotEmpty)
            AspectRatio(
              aspectRatio: photos.first.aspectRatio.clamp(0.7, 1.4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LocalImage(path: photos.first.filePath),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            memory.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          if (memory.content.isNotEmpty)
            Text(
              memory.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.ink.withValues(alpha: 0.88),
                    height: 1.5,
                  ),
            ),
          if (photos.length > 1) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length - 1,
                separatorBuilder: (_, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final photo = photos[index + 1];
                  return AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LocalImage(path: photo.filePath),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 10),
          LocationLabel(memory.location),
          if (memory.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: memory.tags.map((t) => TagChip(t)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.memories, required this.onOpen});

  final List<MemoryEntry> memories;
  final Future<void> Function(MemoryEntry) onOpen;

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return const EmptyState(
        title: 'No days written yet.',
        description: 'Add a memory and the timeline will unfold.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        final showDate = index == 0 ||
            memories[index - 1].date.day != memory.date.day ||
            memories[index - 1].date.month != memory.date.month;
        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDate) ...[
                Text(
                  DateFormatters.timelineHeader(memory.date),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  memory.location.split(',').first.toUpperCase(),
                  style: GoogleFonts.playfairDisplay(fontSize: 28),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
              ],
              InkWell(
                onTap: () => onOpen(memory),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: GoogleFonts.playfairDisplay(fontSize: 22),
                    ),
                    if (memory.coverPhoto != null) ...[
                      const SizedBox(height: 12),
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LocalImage(path: memory.coverPhoto!.filePath),
                        ),
                      ),
                    ],
                    if (memory.content.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(memory.content),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({required this.memories});

  final List<MemoryEntry> memories;

  @override
  Widget build(BuildContext context) {
    final photos = memories.expand((m) => m.photos).toList();
    if (photos.isEmpty) {
      return const EmptyState(
        title: 'No photographs yet.',
        description: 'Upload photos with a memory and they’ll gather here.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PhotoViewerPage(
                  photos: photos,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LocalImage(path: photo.filePath),
          ),
        );
      },
    );
  }
}
