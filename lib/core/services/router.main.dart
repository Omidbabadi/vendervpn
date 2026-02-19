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
      },
    ),

    GoRoute(
      path: StatusScreen.path,
      builder: (_, state) {
        final extra = state.extra as StatusUtils?;
        return StatusScreen(status: extra);
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
          path: XrayVpnScreen.path,
          builder: (_, __) {
            return const XrayVpnScreen();
          },
        ),
        GoRoute(
          path: ServerListScreen.path,
          builder: (_, __) {
            return const ServerListScreen();
          },
        ),
      ],
    ),
  ],
);
