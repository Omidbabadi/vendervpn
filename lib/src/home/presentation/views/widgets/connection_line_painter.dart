import 'package:flutter/widgets.dart';

class ConnectionLinePainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Color userCountry;
  final Color serverColor;

  const ConnectionLinePainter({
    required this.from,
    required this.to,
    required this.serverColor,
    required this.userCountry,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = serverColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round
          ;

    final Offset p1 = _latLonOffset(from, size);
    final Offset p2 = _latLonOffset(to, size);

    final path =
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..quadraticBezierTo(size.width / 2, size.height / 3, p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  Offset _latLonOffset(Offset coord, Size size) {
    final x = (coord.dx + 180) * (size.width / 360);
    final y = (90 - coord.dy) * (size.height / 360);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
