import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.state, required this.child});
  final GoRouterState state;
  final Widget child;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
