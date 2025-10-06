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
        return const SplashScreen();

        // final firstTimer = sl<CacheHelper>().firstTimer;
        // if (firstTimer) {
        //   return const OnBoardingScreen();
        // }
      },
    ),
    
    ShellRoute(
      builder: (context, state, child) {
        return DashboardScreen(state: state, child: child);
      },
      routes: [
        GoRoute(
          path: HomeView.path,
          builder: (_, __) {
            return const HomeView();
          },
        ),
        GoRoute(
          path: ConfigsList.path,
          builder: (_, __) {
            return const ConfigsList();
          },
        ),
      ],
    ),
  ],
);
