import 'package:go_router/go_router.dart';

import '../../features/home/home_page.dart';
import '../../features/memories/create_memory_page.dart';
import '../../features/memories/memory_detail_page.dart';
import '../../features/saved/saved_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shell/app_shell.dart';
import '../../features/trips/create_trip_page.dart';
import '../../features/trips/trip_detail_page.dart';
import '../../features/trips/trips_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                builder: (context, state) => const TripsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/trips/new',
        builder: (context, state) => const CreateTripPage(),
      ),
      GoRoute(
        path: '/trips/:id',
        builder: (context, state) => TripDetailPage(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/memories/new',
        builder: (context, state) => CreateMemoryPage(
          tripId: state.uri.queryParameters['tripId'],
        ),
      ),
      GoRoute(
        path: '/memories/:id',
        builder: (context, state) => MemoryDetailPage(
          memoryId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
