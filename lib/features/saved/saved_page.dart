import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/travel_app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/masonry_memory_grid.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TravelAppState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: SectionTitle(
                eyebrow: 'Kept for later',
                title: 'Saved memories',
              ),
            ),
            Expanded(
              child: state.loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.terracotta),
                    )
                  : state.saved.isEmpty
                      ? EmptyState(
                          title: 'Nothing saved yet.',
                          description:
                              'When a photo stops you mid-scroll, keep it here.',
                          actionLabel: 'Browse memories',
                          onAction: () => context.go('/'),
                        )
                      : MasonryMemoryGrid(
                          memories: state.saved,
                          onTap: (m) => context.push('/memories/${m.id}'),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
