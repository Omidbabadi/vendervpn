import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/l10n/app_localizations.dart';

class QrScannerSheet extends StatefulWidget {
  const QrScannerSheet({super.key});

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _laserController;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasPopped) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw != null && raw.isNotEmpty) {
        _hasPopped = true;
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop(raw);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surfaceColor = Colours.cardSurface(context);
    final textColor = Colours.classicAdabtiveTextColor(context);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.76,
      margin: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colours.subtleBorder(context)),
        boxShadow: Colours.softCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header + Torch & Camera Flip Controls
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.scan_v2ray_qr_title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.scan_v2ray_qr_subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colours.subtitleGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _scannerController.toggleTorch(),
                style: IconButton.styleFrom(
                  backgroundColor: Colours.softChipBg(context),
                ),
                icon: Icon(
                  Icons.flash_on_rounded,
                  size: 18,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => _scannerController.switchCamera(),
                style: IconButton.styleFrom(
                  backgroundColor: Colours.softChipBg(context),
                ),
                icon: Icon(
                  Icons.cameraswitch_rounded,
                  size: 18,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colours.softChipBg(context),
                ),
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Live Camera Viewfinder with Animated Laser Frame
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),

                  // Viewfinder Box + Scanning Line
                  SizedBox(
                    width: 230,
                    height: 230,
                    child: AnimatedBuilder(
                      animation: _laserController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _QrViewfinderPainter(
                            scanProgress: _laserController.value,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrViewfinderPainter extends CustomPainter {
  const _QrViewfinderPainter({required this.scanProgress});
  final double scanProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint =
        Paint()
          ..color = Colours.orbEmerald
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round;

    const cornerLen = 28.0;
    const r = 18.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLen)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(cornerLen, 0),
      borderPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLen, 0)
        ..lineTo(size.width - r, 0)
        ..quadraticBezierTo(size.width, 0, size.width, r)
        ..lineTo(size.width, cornerLen),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLen)
        ..lineTo(0, size.height - r)
        ..quadraticBezierTo(0, size.height, r, size.height)
        ..lineTo(cornerLen, size.height),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLen, size.height)
        ..lineTo(size.width - r, size.height)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width,
          size.height - r,
        )
        ..lineTo(size.width, size.height - cornerLen),
      borderPaint,
    );

    // Animated horizontal laser line
    final laserY = 16.0 + (size.height - 32.0) * scanProgress;
    final laserPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colours.orbEmerald.withValues(alpha: 0.0),
              Colours.orbEmerald,
              Colours.orbCyan,
              Colours.orbEmerald.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, laserY - 2, size.width, 4))
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(12, laserY),
      Offset(size.width - 12, laserY),
      laserPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrViewfinderPainter oldDelegate) =>
      oldDelegate.scanProgress != scanProgress;
}
