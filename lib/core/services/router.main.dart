part of 'router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) {
        final firstTimer = sl<CacheHelper>().firstTimer;
        if (firstTimer) {
          return const OnBoardingScreen();
        }
        return const SplashScreen();
      },
    ),
  ],
);
