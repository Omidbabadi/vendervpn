import 'package:flutter/material.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/widgets/dot_matrix_text.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 116, this.showText = true});

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final textColor = Colours.classicAdabtiveTextColor(context);
    final isDark = context.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            size: Size.square(size),
            painter: _VenderEmblemPainter(isDark: isDark),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 18),
          DotMatrixText(
            text: 'VENDER',
            dotSize: 3.0,
            dotSpacing: 1.5,
            charSpacing: 6.5,
            activeColor: textColor,
            inactiveColor: textColor.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 8),
          Text(
            'PRIVATE TUNNEL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.2,
              color: Colours.subtitleGrey.withValues(alpha: 0.85),
            ),
          ),
        ],
      ],
    );
  }
}

class _VenderEmblemPainter extends CustomPainter {
  const _VenderEmblemPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final boxSize = size.width * 0.78;
    final boxRect = Rect.fromCenter(
      center: center,
      width: boxSize,
      height: boxSize,
    );
    final cornerRadius = Radius.circular(boxSize * 0.30);
    final squircle = RRect.fromRectAndRadius(boxRect, cornerRadius);

    // 1. Soft multi-color aurora glow behind the squircle emblem
    final leftGlowPaint =
        Paint()
          ..color = Colours.orbViolet.withValues(alpha: isDark ? 0.42 : 0.32)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(
      Offset(center.dx - boxSize * 0.18, center.dy - boxSize * 0.12),
      boxSize * 0.42,
      leftGlowPaint,
    );

    final rightGlowPaint =
        Paint()
          ..color = Colours.orbEmerald.withValues(alpha: isDark ? 0.40 : 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(
      Offset(center.dx + boxSize * 0.18, center.dy + boxSize * 0.14),
      boxSize * 0.42,
      rightGlowPaint,
    );

    // 2. Soft matte charcoal squircle base (#171922)
    final basePaint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2230), Color(0xFF13151E)],
          ).createShader(boxRect);
    canvas.drawRRect(squircle, basePaint);

    // Subtle glass border around the squircle
    final borderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.24),
              Colours.orbEmerald.withValues(alpha: 0.35),
            ],
          ).createShader(boxRect);
    canvas.drawRRect(squircle, borderPaint);

    // 3. Geometric Interlocking "V" Tunnel Shield inside the emblem
    final strokeW = boxSize * 0.135;
    final topY = center.dy - boxSize * 0.20;
    final bottomY = center.dy + boxSize * 0.23;
    final leftX = center.dx - boxSize * 0.22;
    final rightX = center.dx + boxSize * 0.22;

    // Left Wing of the V (Violet -> Cyan)
    final leftWingPath =
        Path()
          ..moveTo(leftX, topY)
          ..lineTo(center.dx, bottomY);
    final leftWingPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [Colours.orbCoral, Colours.orbViolet, Colours.orbCyan],
          ).createShader(boxRect);
    canvas.drawPath(leftWingPath, leftWingPaint);

    // Right Wing of the V (Emerald -> Cyan, overlapping at apex)
    final rightWingPath =
        Path()
          ..moveTo(center.dx, bottomY)
          ..lineTo(rightX, topY);
    final rightWingPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topRight,
            colors: [Colours.orbCyan, Colours.orbEmerald],
          ).createShader(boxRect);
    canvas.drawPath(rightWingPath, rightWingPaint);

    // Luminous top portal dot between the V wings
    final dotCenter = Offset(center.dx, topY - boxSize * 0.01);
    final dotGlowPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(dotCenter, strokeW * 0.36, dotGlowPaint);
    canvas.drawCircle(
      dotCenter,
      strokeW * 0.28,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _VenderEmblemPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
