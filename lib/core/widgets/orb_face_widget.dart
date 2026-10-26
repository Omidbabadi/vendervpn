import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:vendervpn/core/res/styles/colors.dart';

enum OrbMood { disconnected, connecting, connected, error }

class OrbFaceWidget extends StatefulWidget {
  const OrbFaceWidget({
    super.key,
    required this.mood,
    this.size = 210,
    this.onTap,
    this.showSatellites = true,
  });

  final OrbMood mood;
  final double size;
  final VoidCallback? onTap;
  final bool showSatellites;

  @override
  State<OrbFaceWidget> createState() => OrbFaceWidgetState();
}

class OrbFaceWidgetState extends State<OrbFaceWidget>
    with TickerProviderStateMixin {
  late final AnimationController _auraController;
  late final AnimationController _wiggleController;
  late final AnimationController _volumeController;
  late final AnimationController _awakeController;
  late final AnimationController _angryController;

  double _targetVolumeForMood(OrbMood mood) {
    return switch (mood) {
      OrbMood.connected => 1.0,
      OrbMood.connecting => 0.72,
      OrbMood.error => 0.90,
      OrbMood.disconnected => 0.25,
    };
  }

  double _targetAwakeForMood(OrbMood mood) {
    return switch (mood) {
      OrbMood.disconnected => 0.0, // Sleeping when idle
      OrbMood.connecting || OrbMood.connected || OrbMood.error => 1.0,
    };
  }

  double _targetAngryForMood(OrbMood mood) {
    return mood == OrbMood.error ? 1.0 : 0.0;
  }

  @override
  void initState() {
    super.initState();
    // Continuous AI talking-sphere wave & plasma morphing
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();

    // Wiggle animation controller — ONLY runs when tapped!
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );

    // Smoothly scales up the talking-sphere amplitude & glow when connected
    _volumeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      value: _targetVolumeForMood(widget.mood),
    );

    // Smoothly transitions the face between sleeping (idle) and awake
    _awakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: _targetAwakeForMood(widget.mood),
    );

    // Smoothly morphs the awake face into an angry glare on OrbMood.error
    _angryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      value: _targetAngryForMood(widget.mood),
    );
  }

  @override
  void didUpdateWidget(covariant OrbFaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _volumeController.animateTo(
        _targetVolumeForMood(widget.mood),
        curve: Curves.easeOutBack,
      );
      _awakeController.animateTo(
        _targetAwakeForMood(widget.mood),
        curve: Curves.easeInOutCubic,
      );
      _angryController.animateTo(
        _targetAngryForMood(widget.mood),
        curve: Curves.easeOutBack,
      );
      if (widget.mood == OrbMood.error) {
        triggerWiggle();
      }
    }
  }

  void triggerWiggle() {
    HapticFeedback.lightImpact();
    _wiggleController.forward(from: 0.0);
  }

  void _handleTap() {
    triggerWiggle();
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _auraController.dispose();
    _wiggleController.dispose();
    _volumeController.dispose();
    _awakeController.dispose();
    _angryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _auraController,
            _wiggleController,
            _volumeController,
            _awakeController,
            _angryController,
          ]),
          builder: (context, _) {
            final t = _wiggleController.value;
            final isWiggling = _wiggleController.isAnimating;
            // Damped harmonic oscillation only when tapped
            final wiggle =
                isWiggling ? math.sin(t * math.pi * 6.0) * (1.0 - t) : 0.0;
            final bounceScale =
                isWiggling
                    ? 1.0 + math.sin(t * math.pi * 3.0) * 0.07 * (1.0 - t)
                    : 1.0;

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Wavy AI Talking Sphere + Face
                Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..translateByDouble(wiggle * 10.0, 0.0, 0.0, 1.0)
                        ..rotateZ(wiggle * 0.16)
                        ..scaleByDouble(
                          bounceScale + wiggle.abs() * 0.06,
                          bounceScale - wiggle.abs() * 0.05,
                          1.0,
                          1.0,
                        ),
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: _WavyAiTalkingSpherePainter(
                      mood: widget.mood,
                      auraPhase: _auraController.value * 2 * math.pi,
                      shadowVolume: _volumeController.value.clamp(0.0, 1.25),
                      awakeFactor: _awakeController.value.clamp(0.0, 1.0),
                      angryFactor: _angryController.value.clamp(0.0, 1.2),
                      wiggle: wiggle,
                      wiggleProgress: isWiggling ? t : 0.0,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Two floating glass satellite bubbles on bottom-right
                if (widget.showSatellites) ...[
                  Positioned(
                    bottom: widget.size * 0.06 - (wiggle * 5),
                    right: widget.size * 0.28 + (wiggle * 4),
                    child: _GlassSatelliteBubble(
                      diameter: widget.size * 0.13,
                      isDark: isDark,
                    ),
                  ),
                  Positioned(
                    bottom: widget.size * 0.10 + (wiggle * 6),
                    right: widget.size * 0.08 - (wiggle * 5),
                    child: _GlassSatelliteBubble(
                      diameter: widget.size * 0.16,
                      isDark: isDark,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GlassSatelliteBubble extends StatelessWidget {
  const _GlassSatelliteBubble({required this.diameter, required this.isDark});

  final double diameter;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.04),
                  ]
                  : [
                    Colors.white.withValues(alpha: 0.92),
                    const Color(0xFFF3E8FF).withValues(alpha: 0.65),
                  ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.85),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0xFFF43F5E).withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class _WavyAiTalkingSpherePainter extends CustomPainter {
  const _WavyAiTalkingSpherePainter({
    required this.mood,
    required this.auraPhase,
    required this.shadowVolume,
    required this.awakeFactor,
    required this.angryFactor,
    required this.wiggle,
    required this.wiggleProgress,
    required this.isDark,
  });

  final OrbMood mood;
  final double auraPhase;
  final double shadowVolume;
  final double awakeFactor;
  final double angryFactor;
  final double wiggle;
  final double wiggleProgress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.32;
    final v = shadowVolume; // 0.25 when disconnected -> 1.0 when connected
    final anger = angryFactor.clamp(0.0, 1.0);

    // Dynamic AI speech envelope (syllable-like modulation, faster/agitated when angry)
    final syllableEnvelope =
        0.55 +
        0.28 * math.sin(auraPhase * 2.0) +
        0.22 * math.cos(auraPhase * 5.0 - 0.7) +
        0.15 * math.sin(auraPhase * 7.0 + 1.2);
    final voiceEnergy =
        (0.28 + 0.92 * v) * (0.58 + 0.48 * syllableEnvelope) +
        wiggle.abs() * 0.65 +
        anger * 0.22;

    final primaryColor = switch (mood) {
      OrbMood.connected => Colours.orbEmerald,
      OrbMood.connecting => Colours.orbViolet,
      OrbMood.error => Colours.orbRose,
      OrbMood.disconnected => Colours.orbCoral,
    };

    final secondaryColor = switch (mood) {
      OrbMood.connected => Colours.orbCyan,
      OrbMood.connecting => Colours.orbMagenta,
      OrbMood.error => const Color(0xFFFF4D6D),
      OrbMood.disconnected => Colours.orbViolet,
    };

    final accentColor = switch (mood) {
      OrbMood.connected => const Color(0xFF38BDF8),
      OrbMood.connecting => const Color(0xFF6366F1),
      OrbMood.error => const Color(0xFFFF9E00),
      OrbMood.disconnected => const Color(0xFFF43F5E),
    };

    // 1. Deep Atmospheric AI Glow Halo
    final haloRadius = baseRadius * (1.55 + 0.58 * v + 0.16 * voiceEnergy);
    final haloAlpha = ((isDark ? 0.32 : 0.24) +
            0.36 * v +
            0.12 * syllableEnvelope)
        .clamp(0.0, 1.0);
    final haloPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              primaryColor.withValues(alpha: haloAlpha),
              secondaryColor.withValues(
                alpha: ((isDark ? 0.22 : 0.16) + 0.28 * v).clamp(0.0, 1.0),
              ),
              accentColor.withValues(
                alpha: ((isDark ? 0.10 : 0.08) + 0.18 * v).clamp(0.0, 1.0),
              ),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 0.76, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: haloRadius));
    canvas.drawCircle(center, haloRadius, haloPaint);

    // 2. Outer Liquid Acoustic Wave Lobes (Morphing AI Voice Aura)
    final outerLobes = <_WavyLobeSpec>[
      _WavyLobeSpec(
        scale: 1.08 + 0.22 * v,
        amp: 0.11 + 0.16 * voiceEnergy,
        freqA: 3,
        freqB: 5,
        freqC: 7,
        speedA: 1.0,
        speedB: -2.0,
        speedC: 3.0,
        phase: 0.0,
        blur: 12.0 + 8.0 * v,
        strokeWidth: 3.2 + 1.8 * v,
        colors: [secondaryColor, primaryColor, accentColor, secondaryColor],
      ),
      _WavyLobeSpec(
        scale: 1.03 + 0.18 * v,
        amp: 0.12 + 0.18 * voiceEnergy,
        freqA: 4,
        freqB: 3,
        freqC: 6,
        speedA: -1.0,
        speedB: 2.0,
        speedC: -3.0,
        phase: 2.1,
        blur: 8.0 + 6.0 * v,
        strokeWidth: 2.6 + 1.5 * v,
        colors: [
          const Color(0xFFEC4899),
          primaryColor,
          secondaryColor,
          const Color(0xFFEC4899),
        ],
      ),
      _WavyLobeSpec(
        scale: 0.98 + 0.14 * v,
        amp: 0.10 + 0.15 * voiceEnergy,
        freqA: 2,
        freqB: 6,
        freqC: 5,
        speedA: 2.0,
        speedB: -1.0,
        speedC: 2.0,
        phase: 4.2,
        blur: 5.0 + 4.0 * v,
        strokeWidth: 2.2 + 1.2 * v,
        colors: [primaryColor, Colors.white, secondaryColor, primaryColor],
      ),
    ];

    for (var i = 0; i < outerLobes.length; i++) {
      final spec = outerLobes[i];
      final path = _buildMultiHarmonicWavePath(
        center: center,
        baseRadius: baseRadius * spec.scale,
        amplitude: baseRadius * spec.amp,
        freqA: spec.freqA,
        freqB: spec.freqB,
        freqC: spec.freqC,
        phaseA: auraPhase * spec.speedA + spec.phase + wiggle * 0.7,
        phaseB: auraPhase * spec.speedB - spec.phase,
        phaseC: auraPhase * spec.speedC + spec.phase * 0.5,
      );

      final rect = Rect.fromCircle(
        center: center,
        radius: baseRadius * (spec.scale + spec.amp * 1.5),
      );
      final rotation = auraPhase * (i.isEven ? 1.0 : -1.0) + spec.phase;

      // Translucent glowing liquid lobe body
      final fillPaint =
          Paint()
            ..style = PaintingStyle.fill
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, spec.blur)
            ..shader = SweepGradient(
              colors:
                  spec.colors
                      .map(
                        (c) => c.withValues(
                          alpha: (0.48 + 0.28 * v).clamp(0.0, 1.0),
                        ),
                      )
                      .toList(),
              stops: const [0.0, 0.33, 0.66, 1.0],
              transform: GradientRotation(rotation),
            ).createShader(rect);
      canvas.drawPath(path, fillPaint);

      // Sharp glowing wave crest rim
      final rimPaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = spec.strokeWidth
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
            ..shader = SweepGradient(
              colors:
                  spec.colors
                      .map(
                        (c) => c.withValues(
                          alpha: (0.78 + 0.22 * v).clamp(0.0, 1.0),
                        ),
                      )
                      .toList(),
              stops: const [0.0, 0.33, 0.66, 1.0],
              transform: GradientRotation(rotation + 0.35),
            ).createShader(rect);
      canvas.drawPath(path, rimPaint);
    }

    // 3. THE MAIN WAVY AI SPHERE BODY
    final coreRadius = baseRadius * 0.90;
    final coreWaveAmp = coreRadius * (0.045 + 0.085 * voiceEnergy);
    final wavyCorePath = _buildMultiHarmonicWavePath(
      center: center,
      baseRadius: coreRadius,
      amplitude: coreWaveAmp,
      freqA: 3,
      freqB: 4,
      freqC: 6,
      phaseA: auraPhase * 1.0 + wiggle * 0.8,
      phaseB: -auraPhase * 2.0 + 1.2,
      phaseC: auraPhase * 3.0 - 0.7,
    );

    final coreBounds = Rect.fromCircle(
      center: center,
      radius: coreRadius + coreWaveAmp * 1.5,
    );

    // Soft outer shadow following the wavy silhouette
    final coreShadowPaint =
        Paint()
          ..color = const Color(0xFF07080E).withValues(alpha: 0.80)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(wavyCorePath, coreShadowPaint);

    // Clip internal 3D waves & plasma to the morphing wavy sphere boundary
    canvas.save();
    canvas.clipPath(wavyCorePath);

    // 3a. Deep 3D Spherical Liquid Base
    final baseSpherePaint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.28, -0.32),
            radius: 1.15,
            colors: [
              Color.lerp(
                const Color(0xFF1B1F32),
                primaryColor,
                0.24 + 0.20 * v + 0.18 * anger,
              )!,
              const Color(0xFF10131E),
              const Color(0xFF07080E),
            ],
            stops: const [0.0, 0.60, 1.0],
          ).createShader(coreBounds);
    canvas.drawRect(coreBounds, baseSpherePaint);

    // 3b. 3D Internal Flowing Sine-Wave Ribbons across the Sphere

    // 3c. Soft Inner Contrast Core so the White Face Eyes pop clearly
    final faceContrastPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment(wiggle * 0.20, -0.02),
            radius: 0.62,
            colors: [
              const Color(0xFF090B12).withValues(alpha: 0.76),
              const Color(0xFF090B12).withValues(alpha: 0.35),
              Colors.transparent,
            ],
            stops: const [0.0, 0.65, 1.0],
          ).createShader(coreBounds);
    canvas.drawRect(coreBounds, faceContrastPaint);

    canvas.restore();

    // 3d. Glowing Iridescent Wavy Outer Rim of the Core Sphere
    final wavyCoreRimPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2 + 1.4 * v
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
          ..shader = SweepGradient(
            colors: [
              Colors.white.withValues(alpha: 0.70 + 0.25 * v),
              primaryColor.withValues(alpha: 0.85),
              secondaryColor.withValues(alpha: 0.80),
              const Color(0xFFEC4899).withValues(alpha: 0.75),
              Colors.white.withValues(alpha: 0.70 + 0.25 * v),
            ],
            transform: GradientRotation(auraPhase),
          ).createShader(coreBounds);
    canvas.drawPath(wavyCorePath, wavyCoreRimPaint);

    // 4. THE FACE: Sleeping eyes when idle -> Awake pill eyes -> Angry glare when error
    final sleepAmount = 1.0 - awakeFactor;
    // Eyes pinch slightly closer together when angry
    final eyeSpacing = coreRadius * (0.34 - 0.03 * anger);
    // Gentle breathing vertical movement while sleeping
    final sleepBreathingY =
        sleepAmount *
        (coreRadius * 0.06 + math.sin(auraPhase) * coreRadius * 0.035);

    // Subtle high-frequency tension tremor when angry
    final angryTremorX =
        anger > 0.01
            ? math.sin(auraPhase * 18.0) * coreRadius * 0.016 * anger
            : 0.0;
    final angryTremorY =
        anger > 0.01
            ? math.cos(auraPhase * 14.0) * coreRadius * 0.010 * anger
            : 0.0;

    final faceOffset = Offset(
      center.dx + wiggle * coreRadius * 0.18 + angryTremorX,
      center.dy -
          coreRadius * 0.02 +
          sleepBreathingY +
          angryTremorY +
          anger * coreRadius * 0.025,
    );

    final leftEyeCenter = Offset(faceOffset.dx - eyeSpacing, faceOffset.dy);
    final rightEyeCenter = Offset(faceOffset.dx + eyeSpacing, faceOffset.dy);

    if (awakeFactor < 0.35) {
      // Original sleeping closed curved eyelids (⌣ ⌣) morphing toward flat blink
      final p = (awakeFactor / 0.35).clamp(0.0, 1.0);
      final strokeW = coreRadius * 0.115;
      final halfSpan = coreRadius * 0.125;
      final sag = coreRadius * 0.11 * (1.0 - p);

      final sleepGlowPaint =
          Paint()
            ..color = Colors.white.withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeW * 1.35
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final sleepEyePaint =
          Paint()
            ..color = Colors.white.withValues(alpha: 0.88 + 0.12 * p)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeW
            ..strokeCap = StrokeCap.round;

      for (final eyeCenter in [leftEyeCenter, rightEyeCenter]) {
        final path =
            Path()
              ..moveTo(eyeCenter.dx - halfSpan, eyeCenter.dy - sag * 0.25)
              ..quadraticBezierTo(
                eyeCenter.dx,
                eyeCenter.dy + sag,
                eyeCenter.dx + halfSpan,
                eyeCenter.dy - sag * 0.25,
              );
        canvas.drawPath(path, sleepGlowPaint);
        canvas.drawPath(path, sleepEyePaint);
      }

      // Floating "Z z" sleep particles drifting above top-right when sleeping
      _drawSleepingZzz(canvas, center, coreRadius, sleepAmount * (1.0 - p));
    } else {
      // Awake vertical rounded pill eyes (| |) with smooth Angry Glare morphing
      final q = ((awakeFactor - 0.35) / 0.65).clamp(0.0, 1.0);
      final squintFactor =
          wiggleProgress > 0
              ? (1.0 - 0.38 * math.sin(wiggleProgress * math.pi))
              : 1.0;

      // Slightly wider and more intense when angry
      final eyeWidth =
          coreRadius * (0.26 * (1.0 - q) + (0.175 + 0.035 * anger) * q);
      final eyeHeight =
          coreRadius *
          (0.115 * (1.0 - q) + (0.38 - 0.04 * anger) * q) *
          squintFactor.clamp(0.35, 1.0);

      final eyeGlowPaint =
          Paint()
            ..color = Color.lerp(
              Colors.white,
              const Color(0xFFFFB3C1),
              anger * 0.45,
            )!.withValues(
              alpha: (0.35 + 0.25 * v + 0.20 * anger).clamp(0.0, 1.0),
            )
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + 3 * anger);

      final eyePaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

      for (final isLeft in [true, false]) {
        final eyeCenter = isLeft ? leftEyeCenter : rightEyeCenter;
        final eyeRRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: eyeCenter,
            width: eyeWidth,
            height: eyeHeight,
          ),
          Radius.circular(eyeWidth),
        );
        final eyePath = Path()..addRRect(eyeRRect);

        if (anger > 0.01) {
          // Slice the top of each pill eye at a fierce inward diagonal (\ /)
          final outerX =
              isLeft
                  ? eyeCenter.dx - eyeWidth * 0.9
                  : eyeCenter.dx + eyeWidth * 0.9;
          final innerX =
              isLeft
                  ? eyeCenter.dx + eyeWidth * 0.9
                  : eyeCenter.dx - eyeWidth * 0.9;

          final outerCutY = eyeCenter.dy - eyeHeight * (0.58 - 0.10 * anger);
          final innerCutY = eyeCenter.dy - eyeHeight * (0.58 - 0.82 * anger);

          final bottomY = eyeCenter.dy + eyeHeight;
          final clipPoly = Path();
          if (isLeft) {
            clipPoly
              ..moveTo(outerX, outerCutY)
              ..lineTo(innerX, innerCutY)
              ..lineTo(innerX, bottomY)
              ..lineTo(outerX, bottomY)
              ..close();
          } else {
            clipPoly
              ..moveTo(innerX, innerCutY)
              ..lineTo(outerX, outerCutY)
              ..lineTo(outerX, bottomY)
              ..lineTo(innerX, bottomY)
              ..close();
          }

          final angryEyePath = Path.combine(
            PathOperation.intersect,
            eyePath,
            clipPoly,
          );
          canvas.drawPath(angryEyePath, eyeGlowPaint);
          canvas.drawPath(angryEyePath, eyePaint);
        } else {
          canvas.drawPath(eyePath, eyeGlowPaint);
          canvas.drawPath(eyePath, eyePaint);
        }
      }

      // Draw furrowed angry eyebrows (\ /) above the eyes when angry
      if (anger > 0.02) {
        final browAlpha = (anger * q).clamp(0.0, 1.0);
        final browStroke = coreRadius * 0.072 * (0.5 + 0.5 * anger);

        final browGlowPaint =
            Paint()
              ..color = primaryColor.withValues(alpha: 0.65 * browAlpha)
              ..style = PaintingStyle.stroke
              ..strokeWidth = browStroke * 1.6
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        final browPaint =
            Paint()
              ..color = Colors.white.withValues(alpha: browAlpha)
              ..style = PaintingStyle.stroke
              ..strokeWidth = browStroke
              ..strokeCap = StrokeCap.round;

        for (final isLeft in [true, false]) {
          final eyeCenter = isLeft ? leftEyeCenter : rightEyeCenter;
          final dir = isLeft ? 1.0 : -1.0;

          final outerBrow = Offset(
            eyeCenter.dx - dir * eyeWidth * 0.68,
            eyeCenter.dy - eyeHeight * (0.64 - 0.12 * anger),
          );
          final innerBrow = Offset(
            eyeCenter.dx + dir * eyeWidth * 0.62,
            eyeCenter.dy - eyeHeight * (0.64 - 0.68 * anger),
          );

          canvas.drawLine(outerBrow, innerBrow, browGlowPaint);
          canvas.drawLine(outerBrow, innerBrow, browPaint);
        }
      }
    }
  }

  /// Draws 3D spherical acoustic wave ribbons rippling across the inside of the orb. Save this Future Use
  void _drawInternalSphericalWaves({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double voiceEnergy,
    required double volume,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
  }) {
    final waveColors = [
      primaryColor,
      secondaryColor,
      accentColor,
      const Color(0xFFEC4899),
    ];

    for (var w = 0; w < 4; w++) {
      final path = Path();
      const steps = 48;
      final waveFreq = 2.0 + w * 0.7;
      final speed = (w.isEven ? 1.0 : -1.0) * (1.0 + w * 0.5);
      final phase = auraPhase * speed + w * 1.4;
      final verticalBias = (w - 1.5) * radius * 0.22;
      final amp = radius * (0.16 + 0.24 * voiceEnergy);

      for (var i = 0; i <= steps; i++) {
        final t = i / steps; // 0.0 -> 1.0 across horizontal diameter
        final nx = (t * 2.0) - 1.0; // -1.0 -> 1.0
        // 3D sphere envelope: tapers wave amplitude naturally at the sphere edges
        final sphereEnvelope = math.sqrt((1.0 - nx * nx).clamp(0.0, 1.0));

        final x = center.dx + nx * radius * 1.08;
        final waveY =
            math.sin(nx * math.pi * waveFreq + phase) * amp * sphereEnvelope +
            math.cos(nx * math.pi * (waveFreq * 1.6) - phase) *
                (amp * 0.45) *
                sphereEnvelope;
        final y = center.dy + verticalBias * sphereEnvelope + waveY;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final waveColor = waveColors[w % waveColors.length];
      final glowPaint =
          Paint()
            ..blendMode = BlendMode.screen
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6.0 + 4.0 * volume
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
            ..color = waveColor.withValues(
              alpha: (0.28 + 0.25 * volume).clamp(0.0, 1.0),
            );
      canvas.drawPath(path, glowPaint);

      final coreLinePaint =
          Paint()
            ..blendMode = BlendMode.screen
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8 + 1.2 * volume
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(
              alpha: (0.26 + 0.28 * volume).clamp(0.0, 1.0),
            );
      canvas.drawPath(path, coreLinePaint);
    }
  }

  /// Builds a rich 3-harmonic closed liquid wave path so the sphere itself ripples organically.
  Path _buildMultiHarmonicWavePath({
    required Offset center,
    required double baseRadius,
    required double amplitude,
    required int freqA,
    required int freqB,
    required int freqC,
    required double phaseA,
    required double phaseB,
    required double phaseC,
  }) {
    const steps = 72;
    final points = List<Offset>.generate(steps, (i) {
      final theta = (i / steps) * 2 * math.pi;
      final wave =
          0.50 * math.sin(theta * freqA + phaseA) +
          0.32 * math.cos(theta * freqB + phaseB) +
          0.18 * math.sin(theta * freqC + phaseC);
      final r = baseRadius + amplitude * wave;
      return Offset(
        center.dx + r * math.cos(theta),
        center.dy + r * math.sin(theta),
      );
    });

    final path = Path();
    final firstMid = Offset(
      (points.last.dx + points.first.dx) * 0.5,
      (points.last.dy + points.first.dy) * 0.5,
    );
    path.moveTo(firstMid.dx, firstMid.dy);

    for (var i = 0; i < steps; i++) {
      final current = points[i];
      final next = points[(i + 1) % steps];
      final mid = Offset(
        (current.dx + next.dx) * 0.5,
        (current.dy + next.dy) * 0.5,
      );
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    path.close();
    return path;
  }

  void _drawSleepingZzz(
    Canvas canvas,
    Offset center,
    double coreRadius,
    double opacityFactor,
  ) {
    if (opacityFactor <= 0.05) return;
    final cycle = (auraPhase / (2 * math.pi)) % 1.0;

    for (var i = 0; i < 2; i++) {
      final progress = (cycle + i * 0.5) % 1.0;
      final fade = math.sin(progress * math.pi) * opacityFactor;
      if (fade <= 0.05) continue;

      final zSize = coreRadius * (0.11 + 0.07 * progress);
      final zCenter = Offset(
        center.dx + coreRadius * (0.36 + 0.22 * progress),
        center.dy - coreRadius * (0.32 + 0.38 * progress),
      );

      final zPaint =
          Paint()
            ..color = Colors.white.withValues(
              alpha: (0.72 * fade).clamp(0.0, 1.0),
            )
            ..style = PaintingStyle.stroke
            ..strokeWidth = coreRadius * 0.032
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;

      final half = zSize * 0.5;
      final zPath =
          Path()
            ..moveTo(zCenter.dx - half, zCenter.dy - half)
            ..lineTo(zCenter.dx + half, zCenter.dy - half)
            ..lineTo(zCenter.dx - half, zCenter.dy + half)
            ..lineTo(zCenter.dx + half, zCenter.dy + half);
      canvas.drawPath(zPath, zPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavyAiTalkingSpherePainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.auraPhase != auraPhase ||
      oldDelegate.shadowVolume != shadowVolume ||
      oldDelegate.awakeFactor != awakeFactor ||
      oldDelegate.angryFactor != angryFactor ||
      oldDelegate.wiggle != wiggle ||
      oldDelegate.wiggleProgress != wiggleProgress ||
      oldDelegate.isDark != isDark;
}

class _WavyLobeSpec {
  const _WavyLobeSpec({
    required this.scale,
    required this.amp,
    required this.freqA,
    required this.freqB,
    required this.freqC,
    required this.speedA,
    required this.speedB,
    required this.speedC,
    required this.phase,
    required this.blur,
    required this.strokeWidth,
    required this.colors,
  });

  final double scale;
  final double amp;
  final int freqA;
  final int freqB;
  final int freqC;
  final double speedA;
  final double speedB;
  final double speedC;
  final double phase;
  final double blur;
  final double strokeWidth;
  final List<Color> colors;
}
