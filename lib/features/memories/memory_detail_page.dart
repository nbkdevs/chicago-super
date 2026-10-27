import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_formatters.dart';
import '../../data/models/memory_entry.dart';
import '../../data/repositories/travel_app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/local_image.dart';
import '../gallery/photo_viewer_page.dart';

class MemoryDetailPage extends StatefulWidget {
  const MemoryDetailPage({super.key, required this.memoryId});

  final String memoryId;

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  MemoryEntry? _memory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memory = await context.read<TravelAppState>().getMemory(widget.memoryId);
    if (!mounted) return;
    setState(() {
      _memory = memory;
      _loading = false;
    });
  }

  Future<void> _share() async {
    final memory = _memory;
    if (memory == null) return;
    final text = [
      memory.title,
      DateFormatters.memoryDate(memory.date),
      if (memory.location.isNotEmpty) memory.location,
      if (memory.content.isNotEmpty) memory.content,
    ].join('\n');
    final files = memory.photos
        .take(1)
        .map((p) => XFile(p.filePath))
        .toList();
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: files.isEmpty ? null : files,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
      );
    }
    final memory = _memory;
    if (memory == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          title: 'Memory not found',
          description: 'This page may have been removed.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: memory.isSaved ? 'Unsave' : 'Save',
            onPressed: () async {
              await context.read<TravelAppState>().toggleSaved(memory.id);
              await _load();
            },
            icon: Icon(
              memory.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: memory.isSaved ? AppColors.terracotta : AppColors.ink,
            ),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: _share,
            icon: const Icon(Icons.ios_share_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                await context.read<TravelAppState>().deleteMemory(memory.id);
                if (context.mounted) context.pop();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete memory')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          if (memory.photos.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PhotoViewerPage(
                      photos: memory.photos,
                      title: memory.title,
                    ),
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: memory.photos.first.aspectRatio.clamp(0.7, 1.35),
                child: Hero(
                  tag: 'memory-cover-${memory.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LocalImage(path: memory.photos.first.filePath),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 22),
          Text(
            memory.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              height: 1.1,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          DateLabel(DateFormatters.memoryDate(memory.date)),
          const SizedBox(height: 16),
          if (memory.content.isNotEmpty)
            Text(
              memory.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
            ),
          const SizedBox(height: 16),
          LocationLabel(memory.location),
          if (memory.tripTitle != null) ...[
            const SizedBox(height: 8),
            Text(
              memory.tripTitle!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (memory.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: memory.tags.map(TagChip.new).toList(),
            ),
          ],
          if (memory.photos.length > 1) ...[
            const SizedBox(height: 24),
            Text(
              'Photographs',
              style: GoogleFonts.playfairDisplay(fontSize: 22),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: memory.photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final photo = memory.photos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PhotoViewerPage(
                          photos: memory.photos,
                          initialIndex: index,
                          title: memory.title,
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
            ),
          ],
        ],
      ),
    );
  }
}
