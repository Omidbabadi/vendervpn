import 'package:flutter/material.dart';

/// A pill-shaped progress bar for quota and usage meters.
///
/// Dumb by design: the caller works out [value] and the colours, so the
/// widget doesn't depend on any provider or quota type.
class QuotaProgressBar extends StatelessWidget {
  const QuotaProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.backgroundColor,
    this.minHeight = 5,
  });

  /// Fraction used, clamped to 0..1.
  final double value;
  final Color color;
  final Color backgroundColor;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: minHeight,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
