import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/travel_app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/trip_card.dart';

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TravelAppState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: SectionTitle(
                      eyebrow: 'Your archive',
                      title: 'My Trips',
                    ),
                  ),
                  FilledButton(
                    onPressed: () => context.push('/trips/new'),
                    child: const Text('+ New'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.terracotta),
                    )
                  : state.trips.isEmpty
                      ? EmptyState(
                          title: 'Your next story starts here.',
                          description:
                              'Create your first trip and start collecting memories.',
                          actionLabel: 'Create a trip',
                          onAction: () => context.push('/trips/new'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 22,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.62,
                          ),
                          itemCount: state.trips.length,
                          itemBuilder: (context, index) {
                            final trip = state.trips[index];
                            return TripCard(
                              trip: trip,
                              onTap: () => context.push('/trips/${trip.id}'),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
