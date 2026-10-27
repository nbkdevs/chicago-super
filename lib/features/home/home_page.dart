import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/travel_app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/masonry_memory_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TravelAppState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppStrings.appName,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          color: AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Settings',
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                  Text(
                    AppStrings.homeGreeting,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    onChanged: state.setSearch,
                    decoration: const InputDecoration(
                      hintText: 'Search memories…',
                      prefixIcon: Icon(Icons.search, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionTitle(
                    eyebrow: 'A collection of memories',
                    title: 'Recently captured',
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: state.loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.terracotta),
                    )
                  : state.feed.isEmpty
                      ? EmptyState(
                          title: 'Your next story starts here.',
                          description:
                              'Create your first trip, save a few moments, and build your travel scrapbook.',
                          actionLabel: 'Create a trip',
                          onAction: () => context.push('/trips/new'),
                        )
                      : RefreshIndicator(
                          color: AppColors.terracotta,
                          onRefresh: state.refresh,
                          child: MasonryMemoryGrid(
                            memories: state.feed,
                            onTap: (m) => context.push('/memories/${m.id}'),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
