import 'package:flutter/material.dart';

class OnBoardingScreenInfo extends StatelessWidget {
  const OnBoardingScreenInfo.first({super.key}) : first = true;
  const OnBoardingScreenInfo.second({super.key}) : first = false;

  final bool first;

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none,
    alignment: AlignmentGeometry.center,
    children: [],
    );
  }
}
