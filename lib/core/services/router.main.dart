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

    GoRoute(path: StatusScreen.path,
      builder: (_,state) {
        final status = state.extra as Status;
        return StatusScreen(status: status,);
      }
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
      ],
    ),
  ],
);
