part of 'router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _buildOrbMoodTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: const Duration(milliseconds: 650),
    reverseTransitionDuration: const Duration(milliseconds: 600),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedIn = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final curvedOut = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInOutCubic,
      );

      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedIn),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curvedIn),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.035),
              end: Offset.zero,
            ).animate(curvedIn),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(curvedOut),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 0.96).animate(curvedOut),
                child: child,
              ),
            ),
          ),
        ),
      );
    },
  );
}

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: StatusScreen.path,
      pageBuilder: (_, state) {
        final extra = state.extra as StatusUtils?;
        return _buildOrbMoodTransitionPage(
          key: state.pageKey,
          child: StatusScreen(status: extra),
        );
      },
    ),
    ShellRoute(
      pageBuilder: (context, state, child) {
        return _buildOrbMoodTransitionPage(
          key: state.pageKey,
          child: DashboardScreen(state: state, child: child),
        );
      },
      routes: [
        GoRoute(
          path: HomeView.path,
          builder: (_, _) {
            return const HomeView();
          },
        ),
        GoRoute(
          path: NodesView.path,
          builder: (_, _) {
            return const NodesView();
          },
        ),
        GoRoute(
          path: SettingsView.path,
          builder: (_, _) {
            return const SettingsView();
          },
        ),
      ],
    ),
  ],
);
