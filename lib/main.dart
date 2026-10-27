import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/travel_app_state.dart';
import 'data/repositories/travel_repository.dart';
import 'features/onboarding/onboarding_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.cream,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final repository = TravelRepository();
  final appState = TravelAppState(repository);
  await appState.initialize();
  final showOnboarding = await OnboardingOverlay.shouldShow();

  runApp(TravelPalApp(appState: appState, showOnboarding: showOnboarding));
}

class TravelPalApp extends StatefulWidget {
  const TravelPalApp({
    super.key,
    required this.appState,
    required this.showOnboarding,
  });

  final TravelAppState appState;
  final bool showOnboarding;

  @override
  State<TravelPalApp> createState() => _TravelPalAppState();
}

class _TravelPalAppState extends State<TravelPalApp> {
  late final GoRouter _router = createRouter();
  late bool _showOnboarding = widget.showOnboarding;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.appState,
      child: MaterialApp.router(
        title: 'Travel Pal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
        builder: (context, child) {
          return Stack(
            children: [
              ?child,
              if (_showOnboarding)
                OnboardingOverlay(
                  onFinished: () => setState(() => _showOnboarding = false),
                ),
            ],
          );
        },
      ),
    );
  }
}
