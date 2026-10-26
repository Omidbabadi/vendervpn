import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:vendervpn/core/res/styles/colors.dart';

enum OrbMood { disconnected, connecting, connected, error }

/// Preserves exact animation progress across route transitions (HomeView <-> Hero <-> StatusScreen)
/// so the user sees one continuous, uninterrupted face mood transformation.
class _OrbSharedTimeline {
  static OrbMood currentMood = OrbMood.disconnected;
  static double awakeValue = 0.0;
  static double volumeValue = 0.25;
  static double angryValue = 0.0;
  static double strainValue = 0.0;
  static double happyValue = 0.0;
  static DateTime? connectingStartedAt;
  static DateTime? wiggleStartedAt;

  static Color primaryColor = Colours.orbCoral;
  static Color secondaryColor = Colours.orbViolet;
  static Color accentColor = const Color(0xFFF43F5E);

  static Duration get remainingStrainDuration {
    final started = connectingStartedAt;
    if (started == null) return Duration.zero;
    final elapsed = DateTime.now().difference(started);
    const total = Duration(seconds: 3);
    return elapsed < total ? total - elapsed : Duration.zero;
  }
}

class OrbFaceWidget extends StatefulWidget {
  const OrbFaceWidget({
    super.key,
    required this.mood,
    this.size = 210,
    this.onTap,
    this.showSatellites = true,
    this.heroTag = 'vender_orb_face_hero',
  });

  final OrbMood mood;
  final double size;
  final VoidCallback? onTap;
  final bool showSatellites;
  final Object? heroTag;

  /// Remaining time in the 3-second strained connecting animation, if active.
  static Duration get remainingStrainDuration =>
      _OrbSharedTimeline.remainingStrainDuration;

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
  late final AnimationController _strainController;
  late final AnimationController _happyController;
  late final AnimationController _colorController;

  late Color _fromPrimary;
  late Color _fromSecondary;
  late Color _fromAccent;
  late Color _toPrimary;
  late Color _toSecondary;
  late Color _toAccent;

  /// Ensures the 3-second strained connecting animation plays to completion
  /// visually even if the underlying tunnel/ad flow finishes faster than 3s,
  /// without blocking or delaying the connection or ad flow itself.
  bool _isHoldingConnectingStrain = false;

  double _targetVolumeForMood(OrbMood mood) {
    return switch (mood) {
      OrbMood.connected => 1.0,
      OrbMood.connecting => 0.92,
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

  double _targetHappyForMood(OrbMood mood) {
    return mood == OrbMood.connected ? 1.0 : 0.0;
  }

  (Color, Color, Color) _paletteForMood(OrbMood mood) {
    return switch (mood) {
      OrbMood.connected => (
        Colours.orbCyan,
        Colours.orbAzure,
        Colours.orbViolet,
      ),
      OrbMood.connecting => (
        Colours.orbViolet,
        Colours.orbMagenta,
        const Color(0xFF6366F1),
      ),
      OrbMood.error => (
        Colours.orbRose,
        const Color(0xFFFF4D6D),
        const Color(0xFFFF9E00),
      ),
      OrbMood.disconnected => (
        Colours.orbCoral,
        Colours.orbViolet,
        const Color(0xFFF43F5E),
      ),
    };
  }

  @override
  void initState() {
    super.initState();
    // Lock wave phase to wall-clock time so Hero transitions never jump a single frame
    final initialPhase =
        (DateTime.now().millisecondsSinceEpoch % 4200) / 4200.0;
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
      value: initialPhase,
    )..repeat();

    // Wiggle animation controller — continues seamlessly if triggered just before route transition
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    final wiggleStarted = _OrbSharedTimeline.wiggleStartedAt;
    if (wiggleStarted != null) {
      final elapsedMs = DateTime.now().difference(wiggleStarted).inMilliseconds;
      if (elapsedMs >= 0 && elapsedMs < 720) {
        _wiggleController.forward(from: elapsedMs / 720.0);
      }
    }

    // Initialize controllers from shared timeline so mood changes animate smoothly across screens
    _volumeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      value: _OrbSharedTimeline.volumeValue,
    );

    _awakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: _OrbSharedTimeline.awakeValue,
    );

    _angryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: _OrbSharedTimeline.angryValue,
    );

    _happyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: _OrbSharedTimeline.happyValue,
    );

    _fromPrimary = _OrbSharedTimeline.primaryColor;
    _fromSecondary = _OrbSharedTimeline.secondaryColor;
    _fromAccent = _OrbSharedTimeline.accentColor;
    final targetPalette = _paletteForMood(widget.mood);
    _toPrimary = targetPalette.$1;
    _toSecondary = targetPalette.$2;
    _toAccent = targetPalette.$3;

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
      value: _OrbSharedTimeline.currentMood == widget.mood ? 1.0 : 0.0,
    );

    // 3-second strained expression & color-shift animation while connecting
    _strainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      reverseDuration: const Duration(milliseconds: 520),
      value: _OrbSharedTimeline.strainValue,
    )..addStatusListener(_onStrainStatusChanged);

    _applyMoodTransition(widget.mood, isInit: true);
  }

  void _startColorTweenTo(OrbMood targetMood) {
    final t = Curves.easeInOutCubic.transform(_colorController.value);
    _fromPrimary = Color.lerp(_fromPrimary, _toPrimary, t)!;
    _fromSecondary = Color.lerp(_fromSecondary, _toSecondary, t)!;
    _fromAccent = Color.lerp(_fromAccent, _toAccent, t)!;

    final targetPalette = _paletteForMood(targetMood);
    _toPrimary = targetPalette.$1;
    _toSecondary = targetPalette.$2;
    _toAccent = targetPalette.$3;
    _colorController.forward(from: 0.0);
  }

  void _applyMoodTransition(OrbMood newMood, {bool isInit = false}) {
    final prevMood = _OrbSharedTimeline.currentMood;
    _OrbSharedTimeline.currentMood = newMood;

    if (newMood == OrbMood.connecting) {
      _isHoldingConnectingStrain = true;
      if (prevMood != OrbMood.connecting ||
          _OrbSharedTimeline.connectingStartedAt == null) {
        _OrbSharedTimeline.connectingStartedAt = DateTime.now();
      }
      final elapsedMs =
          DateTime.now()
              .difference(_OrbSharedTimeline.connectingStartedAt!)
              .inMilliseconds;
      final progress = (elapsedMs / 3000.0).clamp(0.0, 1.0);

      _startColorTweenTo(OrbMood.connecting);
      _awakeController.animateTo(1.0, curve: Curves.easeOutCubic);
      _angryController.animateTo(0.0, curve: Curves.easeOutCubic);
      _happyController.animateTo(0.0, curve: Curves.easeOutCubic);
      _volumeController.animateTo(
        _targetVolumeForMood(OrbMood.connecting),
        duration: Duration(milliseconds: math.max(300, 3000 - elapsedMs)),
        curve: Curves.easeInCubic,
      );
      _strainController.forward(from: progress);
    } else if (newMood == OrbMood.connected &&
        (_OrbSharedTimeline.remainingStrainDuration > Duration.zero ||
            (_strainController.isAnimating &&
                _strainController.status == AnimationStatus.forward))) {
      // Connection finished in < 3s: let the 3s visual strain animation finish
      // without interrupting connection or ad flow, then transition on completion.
      _isHoldingConnectingStrain = true;
      final remainingMs =
          _OrbSharedTimeline.remainingStrainDuration.inMilliseconds;
      final progress = ((3000 - remainingMs) / 3000.0).clamp(0.0, 1.0);
      if (!_strainController.isAnimating) {
        _strainController.forward(from: progress);
      }
      _awakeController.animateTo(1.0, curve: Curves.easeInOutCubic);
      _angryController.animateTo(0.0, curve: Curves.easeOutBack);
    } else {
      _isHoldingConnectingStrain = false;
      _OrbSharedTimeline.connectingStartedAt = null;
      _startColorTweenTo(newMood);
      _strainController.reverse();
      _volumeController.animateTo(
        _targetVolumeForMood(newMood),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutBack,
      );
      _awakeController.animateTo(
        _targetAwakeForMood(newMood),
        curve: Curves.easeInOutCubic,
      );
      _angryController.animateTo(
        _targetAngryForMood(newMood),
        curve: Curves.easeOutBack,
      );
      _happyController.animateTo(
        _targetHappyForMood(newMood),
        curve: Curves.easeOutBack,
      );
      if (newMood == OrbMood.error && !isInit) {
        triggerWiggle();
      }
    }
  }

  void _onStrainStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      // Once the full 3s strain animation has finished, if the connection has
      // already succeeded in the background, smoothly release into connected.
      if (widget.mood != OrbMood.connecting) {
        setState(() {
          _isHoldingConnectingStrain = false;
        });
        _OrbSharedTimeline.connectingStartedAt = null;
        _startColorTweenTo(widget.mood);
        _strainController.reverse();
        _volumeController.animateTo(
          _targetVolumeForMood(widget.mood),
          curve: Curves.easeOutBack,
        );
        _happyController.animateTo(
          _targetHappyForMood(widget.mood),
          curve: Curves.easeOutBack,
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant OrbFaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _applyMoodTransition(widget.mood);
    }
  }

  void triggerWiggle() {
    HapticFeedback.lightImpact();
    _OrbSharedTimeline.wiggleStartedAt = DateTime.now();
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
    _strainController.dispose();
    _happyController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Widget _buildOrbContent(BuildContext context, bool isDark) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final effectiveSize =
                constraints.hasBoundedWidth &&
                        constraints.hasBoundedHeight &&
                        constraints.maxWidth > 0 &&
                        constraints.maxHeight > 0
                    ? math.min(constraints.maxWidth, constraints.maxHeight)
                    : widget.size;

            return AnimatedBuilder(
              animation: Listenable.merge([
                _auraController,
                _wiggleController,
                _volumeController,
                _awakeController,
                _angryController,
                _strainController,
                _happyController,
                _colorController,
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

                final strain = Curves.easeInOutCubic.transform(
                  _strainController.value.clamp(0.0, 1.0),
                );
                final happy = Curves.easeOutCubic.transform(
                  _happyController.value.clamp(0.0, 1.0),
                );
                final auraPhase = _auraController.value * 2 * math.pi;

                final colorT = Curves.easeInOutCubic.transform(
                  _colorController.value.clamp(0.0, 1.0),
                );
                final currentPrimary =
                    Color.lerp(_fromPrimary, _toPrimary, colorT)!;
                final currentSecondary =
                    Color.lerp(_fromSecondary, _toSecondary, colorT)!;
                final currentAccent =
                    Color.lerp(_fromAccent, _toAccent, colorT)!;

                // Keep shared timeline updated every frame for seamless Hero transitions
                _OrbSharedTimeline.awakeValue = _awakeController.value;
                _OrbSharedTimeline.volumeValue = _volumeController.value;
                _OrbSharedTimeline.angryValue = _angryController.value;
                _OrbSharedTimeline.strainValue = _strainController.value;
                _OrbSharedTimeline.happyValue = _happyController.value;
                _OrbSharedTimeline.primaryColor = currentPrimary;
                _OrbSharedTimeline.secondaryColor = currentSecondary;
                _OrbSharedTimeline.accentColor = currentAccent;

                // High-frequency effort shiver & muscular compression while straining
                final strainShiverX =
                    strain > 0.01
                        ? math.sin(auraPhase * 28.0) * 3.2 * strain
                        : 0.0;
                final strainShiverY =
                    strain > 0.01
                        ? math.cos(auraPhase * 23.0) * 2.0 * strain
                        : 0.0;
                final effortPulse = 0.5 + 0.5 * math.sin(auraPhase * 5.0);
                final strainScaleX =
                    1.0 + strain * (0.045 + 0.022 * effortPulse);
                final strainScaleY =
                    1.0 - strain * (0.060 + 0.025 * effortPulse);

                final effectiveMood =
                    _isHoldingConnectingStrain
                        ? OrbMood.connecting
                        : widget.mood;

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Wavy AI Talking Sphere + Face
                    Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..translateByDouble(
                              wiggle * 10.0 + strainShiverX,
                              strainShiverY,
                              0.0,
                              1.0,
                            )
                            ..rotateZ(wiggle * 0.16 + strainShiverX * 0.008)
                            ..scaleByDouble(
                              (bounceScale + wiggle.abs() * 0.06) *
                                  strainScaleX,
                              (bounceScale - wiggle.abs() * 0.05) *
                                  strainScaleY,
                              1.0,
                              1.0,
                            ),
                      child: CustomPaint(
                        size: Size.square(effectiveSize),
                        painter: _WavyAiTalkingSpherePainter(
                          mood: effectiveMood,
                          basePrimary: currentPrimary,
                          baseSecondary: currentSecondary,
                          baseAccent: currentAccent,
                          auraPhase: auraPhase,
                          shadowVolume: _volumeController.value.clamp(
                            0.0,
                            1.25,
                          ),
                          awakeFactor: _awakeController.value.clamp(0.0, 1.0),
                          angryFactor: _angryController.value.clamp(0.0, 1.2),
                          strainFactor: strain,
                          happyFactor: happy,
                          wiggle: wiggle,
                          wiggleProgress: isWiggling ? t : 0.0,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    // Two floating glass satellite bubbles on bottom-right
                    if (widget.showSatellites) ...[
                      Positioned(
                        bottom:
                            effectiveSize * 0.06 -
                            (wiggle * 5) -
                            (strainShiverY * 0.8),
                        right:
                            effectiveSize * 0.28 +
                            (wiggle * 4) +
                            (strainShiverX * 0.8),
                        child: _GlassSatelliteBubble(
                          diameter: effectiveSize * 0.13,
                          isDark: isDark,
                        ),
                      ),
                      Positioned(
                        bottom:
                            effectiveSize * 0.10 +
                            (wiggle * 6) +
                            (strainShiverY * 0.9),
                        right:
                            effectiveSize * 0.08 -
                            (wiggle * 5) -
                            (strainShiverX * 0.9),
                        child: _GlassSatelliteBubble(
                          diameter: effectiveSize * 0.16,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final content = _buildOrbContent(context, isDark);

    if (widget.heroTag == null) {
      return content;
    }

    return Hero(
      tag: widget.heroTag!,
      createRectTween: (begin, end) => MaterialRectCenterArcTween(
        begin: begin,
        end: end,
      ),
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        final targetHero = toHeroContext.widget as Hero;
        final targetOrb = targetHero.child;
        OrbMood shuttleMood = widget.mood;
        bool shuttleSatellites = widget.showSatellites;
        if (targetOrb is OrbFaceWidget) {
          shuttleMood = targetOrb.mood;
          shuttleSatellites = targetOrb.showSatellites;
        }
        return Material(
          type: MaterialType.transparency,
          child: OrbFaceWidget(
            mood: shuttleMood,
            size: widget.size,
            showSatellites: shuttleSatellites,
            heroTag: null,
          ),
        );
      },
      child: content,
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
    required this.basePrimary,
    required this.baseSecondary,
    required this.baseAccent,
    required this.auraPhase,
    required this.shadowVolume,
    required this.awakeFactor,
    required this.angryFactor,
    required this.strainFactor,
    required this.happyFactor,
    required this.wiggle,
    required this.wiggleProgress,
    required this.isDark,
  });

  final OrbMood mood;
  final Color basePrimary;
  final Color baseSecondary;
  final Color baseAccent;
  final double auraPhase;
  final double shadowVolume;
  final double awakeFactor;
  final double angryFactor;
  final double strainFactor;
  final double happyFactor;
  final double wiggle;
  final double wiggleProgress;
  final bool isDark;

  Color _multiStageLerp(Color a, Color b, Color c, double t) {
    final clamped = t.clamp(0.0, 1.0);
    if (clamped < 0.5) {
      return Color.lerp(a, b, clamped * 2.0)!;
    } else {
      return Color.lerp(b, c, (clamped - 0.5) * 2.0)!;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.32;
    final v = shadowVolume; // 0.25 when disconnected -> 1.0 when connected
    final anger = angryFactor.clamp(0.0, 1.0);
    final strain = strainFactor.clamp(0.0, 1.0);
    final happy = (happyFactor * (1.0 - strain) * (1.0 - anger)).clamp(
      0.0,
      1.0,
    );

    // Dynamic AI speech envelope (syllable-like modulation, faster/agitated when angry or straining)
    final syllableEnvelope =
        0.55 +
        0.28 * math.sin(auraPhase * (2.0 + strain * 2.0)) +
        0.22 * math.cos(auraPhase * 5.0 - 0.7) +
        0.15 * math.sin(auraPhase * 7.0 + 1.2);
    final voiceEnergy =
        (0.28 + 0.92 * v) * (0.58 + 0.48 * syllableEnvelope) +
        wiggle.abs() * 0.65 +
        anger * 0.22 +
        strain * 0.32;

    // Over 3 seconds of connecting strain, progressively turn the orb's color
    // from cool Violet/Magenta -> Hot Rose-Coral -> Flushed Fiery Crimson/Amber
    final strainedPrimary = _multiStageLerp(
      Colours.orbViolet,
      const Color(0xFFF43F5E),
      const Color(0xFFFF2442),
      strain,
    );
    final strainedSecondary = _multiStageLerp(
      Colours.orbMagenta,
      const Color(0xFFFF5E3A),
      const Color(0xFFFF7B00),
      strain,
    );
    final strainedAccent = _multiStageLerp(
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
      const Color(0xFFFFBE0B),
      strain,
    );

    final primaryColor =
        strain > 0.001
            ? Color.lerp(basePrimary, strainedPrimary, strain)!
            : basePrimary;
    final secondaryColor =
        strain > 0.001
            ? Color.lerp(baseSecondary, strainedSecondary, strain)!
            : baseSecondary;
    final accentColor =
        strain > 0.001
            ? Color.lerp(baseAccent, strainedAccent, strain)!
            : baseAccent;

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
          accentColor,
          primaryColor,
          secondaryColor,
          accentColor,
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

    // 3a. Deep 3D Spherical Liquid Base (flushes warmer/crimson when straining)
    final baseSpherePaint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.28, -0.32),
            radius: 1.15,
            colors: [
              Color.lerp(
                const Color(0xFF1B1F32),
                primaryColor,
                (0.24 + 0.20 * v + 0.18 * anger + 0.34 * strain).clamp(
                  0.0,
                  0.92,
                ),
              )!,
              Color.lerp(
                const Color(0xFF10131E),
                secondaryColor,
                (0.26 * strain).clamp(0.0, 0.6),
              )!,
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
              Color.lerp(
                const Color(0xFF090B12),
                const Color(0xFF2B0918),
                strain * 0.55,
              )!.withValues(alpha: 0.76),
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
          ..strokeWidth = 2.2 + 1.4 * v + 0.8 * strain
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
          ..shader = SweepGradient(
            colors: [
              Colors.white.withValues(alpha: 0.70 + 0.25 * v),
              primaryColor.withValues(alpha: 0.85),
              secondaryColor.withValues(alpha: 0.80),
              accentColor.withValues(alpha: 0.78),
              Colors.white.withValues(alpha: 0.70 + 0.25 * v),
            ],
            transform: GradientRotation(auraPhase),
          ).createShader(coreBounds);
    canvas.drawPath(wavyCorePath, wavyCoreRimPaint);

    // 4. THE FACE: Sleeping eyes when idle -> Awake pill eyes -> Strained (> <) when connecting -> Angry glare when error
    final sleepAmount = 1.0 - awakeFactor;
    // Eyes pinch slightly closer together when angry or straining with effort
    final eyeSpacing = coreRadius * (0.34 - 0.03 * anger - 0.045 * strain);
    // Gentle breathing vertical movement while sleeping
    final sleepBreathingY =
        sleepAmount *
        (coreRadius * 0.06 + math.sin(auraPhase) * coreRadius * 0.035);

    // Subtle high-frequency tension tremor when angry or straining
    final tremorIntensity = math.max(anger, strain * 1.15);
    final angryTremorX =
        tremorIntensity > 0.01
            ? math.sin(auraPhase * 22.0) *
                coreRadius *
                0.018 *
                tremorIntensity
            : 0.0;
    final angryTremorY =
        tremorIntensity > 0.01
            ? math.cos(auraPhase * 17.0) *
                coreRadius *
                0.012 *
                tremorIntensity
            : 0.0;

    final faceOffset = Offset(
      center.dx + wiggle * coreRadius * 0.18 + angryTremorX,
      center.dy -
          coreRadius * 0.02 +
          sleepBreathingY +
          angryTremorY +
          anger * coreRadius * 0.025 +
          strain * coreRadius * 0.03,
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
      final q = ((awakeFactor - 0.35) / 0.65).clamp(0.0, 1.0);
      final squintFactor =
          wiggleProgress > 0
              ? (1.0 - 0.38 * math.sin(wiggleProgress * math.pi))
              : 1.0;

      // If straining while connecting, draw the strained face (> < eyes, flushed cheeks, gritted mouth, sweat)
      if (strain > 0.12 && anger < 0.1) {
        _drawStrainedFace(
          canvas: canvas,
          faceOffset: faceOffset,
          leftEyeCenter: leftEyeCenter,
          rightEyeCenter: rightEyeCenter,
          coreRadius: coreRadius,
          strain: strain,
          awakeQ: q,
          volume: v,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          accentColor: accentColor,
        );
      } else {
        // Happy joyful bounce when connected
        final happyBobY =
            happy > 0.01
                ? math.sin(auraPhase * 2.0) * coreRadius * 0.032 * happy
                : 0.0;
        final adjFaceOffset = Offset(
          faceOffset.dx,
          faceOffset.dy + happyBobY - happy * coreRadius * 0.03,
        );
        final adjLeftEye = Offset(
          leftEyeCenter.dx,
          leftEyeCenter.dy + happyBobY - happy * coreRadius * 0.03,
        );
        final adjRightEye = Offset(
          rightEyeCenter.dx,
          rightEyeCenter.dy + happyBobY - happy * coreRadius * 0.03,
        );

        // Awake vertical rounded pill eyes (| |) with smooth Angry Glare or Happy Joyful Eyes
        final strainSquint = (1.0 - strain * 4.5).clamp(0.25, 1.0);
        final eyeWidth =
            coreRadius *
            (0.26 * (1.0 - q) +
                (0.175 + 0.035 * anger + 0.025 * happy) * q);
        final eyeHeight =
            coreRadius *
            (0.115 * (1.0 - q) +
                (0.38 - 0.04 * anger + 0.02 * happy) * q) *
            squintFactor.clamp(0.35, 1.0) *
            strainSquint;

        final eyeGlowPaint =
            Paint()
              ..color = Color.lerp(
                Colors.white,
                anger > 0.05 ? const Color(0xFFFFB3C1) : primaryColor,
                (anger * 0.45 + happy * 0.35).clamp(0.0, 1.0),
              )!.withValues(
                alpha: (0.35 + 0.25 * v + 0.20 * anger + 0.18 * happy).clamp(
                  0.0,
                  1.0,
                ),
              )
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                5 + 3 * anger + 2 * happy,
              );

        final eyePaint =
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill;

        for (final isLeft in [true, false]) {
          final eyeCenter = isLeft ? adjLeftEye : adjRightEye;
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

            final outerCutY =
                eyeCenter.dy - eyeHeight * (0.58 - 0.10 * anger);
            final innerCutY =
                eyeCenter.dy - eyeHeight * (0.58 - 0.82 * anger);

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
          } else if (happy > 0.01) {
            // Happy upward cheek-squint cutout at the bottom of each eye (^ ^ crescent / smiling eyes)
            final cutoutRadius = eyeWidth * (0.95 + 0.25 * happy);
            final cutoutCenter = Offset(
              eyeCenter.dx,
              eyeCenter.dy + eyeHeight * (0.92 - 0.36 * happy),
            );
            final cutoutPath =
                Path()..addOval(
                  Rect.fromCircle(center: cutoutCenter, radius: cutoutRadius),
                );
            final happyEyePath = Path.combine(
              PathOperation.difference,
              eyePath,
              cutoutPath,
            );
            canvas.drawPath(happyEyePath, eyeGlowPaint);
            canvas.drawPath(happyEyePath, eyePaint);
          } else {
            canvas.drawPath(eyePath, eyeGlowPaint);
            canvas.drawPath(eyePath, eyePaint);
          }
        }

        // Draw joyful rosy cheeks & a warm happy smile when connected!
        if (happy > 0.02 && anger < 0.05) {
          final happyAlpha = (happy * q).clamp(0.0, 1.0);

          // 1. Soft rosy-peach happy cheeks below the eyes
          final cheekPaint =
              Paint()
                ..color = const Color(
                  0xFFFF758F,
                ).withValues(alpha: 0.34 * happyAlpha)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

          for (final isLeft in [true, false]) {
            final eyeCenter = isLeft ? adjLeftEye : adjRightEye;
            final dir = isLeft ? -1.0 : 1.0;
            final cheekRect = Rect.fromCenter(
              center: Offset(
                eyeCenter.dx + dir * coreRadius * 0.11,
                eyeCenter.dy + coreRadius * 0.19,
              ),
              width: coreRadius * 0.23 * happyAlpha,
              height: coreRadius * 0.12 * happyAlpha,
            );
            canvas.drawOval(cheekRect, cheekPaint);
          }

          // 2. Cheerful upward curved smile arc (◡) between and below the eyes
          final smileWidth = coreRadius * (0.14 + 0.11 * happyAlpha);
          final smileDepth = coreRadius * (0.04 + 0.10 * happyAlpha);
          final smileY = adjFaceOffset.dy + coreRadius * 0.18;
          final smileStroke = coreRadius * 0.082;

          final smilePath =
              Path()
                ..moveTo(adjFaceOffset.dx - smileWidth, smileY)
                ..quadraticBezierTo(
                  adjFaceOffset.dx,
                  smileY + smileDepth * 1.65,
                  adjFaceOffset.dx + smileWidth,
                  smileY,
                );

          final smileGlowPaint =
              Paint()
                ..color = primaryColor.withValues(alpha: 0.55 * happyAlpha)
                ..style = PaintingStyle.stroke
                ..strokeWidth = smileStroke * 1.65
                ..strokeCap = StrokeCap.round
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

          final smilePaint =
              Paint()
                ..color = Colors.white.withValues(alpha: happyAlpha)
                ..style = PaintingStyle.stroke
                ..strokeWidth = smileStroke
                ..strokeCap = StrokeCap.round;

          canvas.drawPath(smilePath, smileGlowPaint);
          canvas.drawPath(smilePath, smilePaint);
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
  }

  /// Draws the strained connecting expression: flushed cheeks, tightly clenched (> <) eyes,
  /// tense furrowed brows, forehead effort creases, gritted wavy mouth, and sweat/strain marks.
  void _drawStrainedFace({
    required Canvas canvas,
    required Offset faceOffset,
    required Offset leftEyeCenter,
    required Offset rightEyeCenter,
    required double coreRadius,
    required double strain,
    required double awakeQ,
    required double volume,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
  }) {
    final s = ((strain - 0.12) / 0.88).clamp(0.0, 1.0);
    final strokeW = coreRadius * (0.095 + 0.018 * s);

    // 1. Flushed Crimson-Coral Cheeks under the eyes as the face turns color
    final blushAlpha = (0.18 + 0.42 * s).clamp(0.0, 1.0);
    final blushPaint =
        Paint()
          ..color = Color.lerp(
            const Color(0xFFFF4D6D),
            const Color(0xFFFF2442),
            s,
          )!.withValues(alpha: blushAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (final isLeft in [true, false]) {
      final eyeCenter = isLeft ? leftEyeCenter : rightEyeCenter;
      final dir = isLeft ? -1.0 : 1.0;
      final cheekRect = Rect.fromCenter(
        center: Offset(
          eyeCenter.dx + dir * coreRadius * 0.08,
          eyeCenter.dy + coreRadius * 0.17,
        ),
        width: coreRadius * (0.22 + 0.06 * s),
        height: coreRadius * (0.12 + 0.03 * s),
      );
      canvas.drawOval(cheekRect, blushPaint);
    }

    // 2. Tightly Squeezed (> <) Strained Chevron Eyes
    final eyeGlowPaint =
        Paint()
          ..color = Color.lerp(
            Colors.white,
            accentColor,
            0.35 * s,
          )!.withValues(alpha: (0.45 + 0.35 * s).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW * 1.55
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final eyeStrokePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final spanX = coreRadius * (0.135 + 0.025 * s);
    final spanY = coreRadius * (0.085 + 0.045 * s);

    for (final isLeft in [true, false]) {
      final eyeCenter = isLeft ? leftEyeCenter : rightEyeCenter;
      // dir = 1.0 for left eye (> points right/inward), -1.0 for right eye (< points left/inward)
      final dir = isLeft ? 1.0 : -1.0;

      final outerTop = Offset(
        eyeCenter.dx - dir * spanX * 0.95,
        eyeCenter.dy - spanY,
      );
      final innerApex = Offset(
        eyeCenter.dx + dir * spanX * 0.85,
        eyeCenter.dy + spanY * 0.08,
      );
      final outerBottom = Offset(
        eyeCenter.dx - dir * spanX * 0.95,
        eyeCenter.dy + spanY,
      );

      final chevronPath =
          Path()
            ..moveTo(outerTop.dx, outerTop.dy)
            ..lineTo(innerApex.dx, innerApex.dy)
            ..lineTo(outerBottom.dx, outerBottom.dy);

      canvas.drawPath(chevronPath, eyeGlowPaint);
      canvas.drawPath(chevronPath, eyeStrokePaint);

      // Outer squint wrinkle line extending from the pinched apex
      if (s > 0.25) {
        final creaseAlpha = ((s - 0.25) / 0.75).clamp(0.0, 1.0);
        final creasePaint =
            Paint()
              ..color = Colors.white.withValues(alpha: 0.75 * creaseAlpha)
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeW * 0.55
              ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(
            eyeCenter.dx - dir * spanX * 1.15,
            eyeCenter.dy + spanY * 0.06,
          ),
          Offset(
            eyeCenter.dx - dir * spanX * 0.45,
            eyeCenter.dy + spanY * 0.06,
          ),
          creasePaint,
        );
      }
    }

    // 3. Tense Furrowed Strained Eyebrows + Glabella Effort Wrinkles
    final browStroke = coreRadius * 0.068 * (0.65 + 0.35 * s);
    final browGlowPaint =
        Paint()
          ..color = primaryColor.withValues(alpha: 0.70 * s)
          ..style = PaintingStyle.stroke
          ..strokeWidth = browStroke * 1.6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final browPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: (0.75 + 0.25 * s) * awakeQ)
          ..style = PaintingStyle.stroke
          ..strokeWidth = browStroke
          ..strokeCap = StrokeCap.round;

    for (final isLeft in [true, false]) {
      final eyeCenter = isLeft ? leftEyeCenter : rightEyeCenter;
      final dir = isLeft ? 1.0 : -1.0;

      final outerBrow = Offset(
        eyeCenter.dx - dir * coreRadius * 0.15,
        eyeCenter.dy - coreRadius * (0.22 - 0.03 * s),
      );
      final innerBrow = Offset(
        eyeCenter.dx + dir * coreRadius * 0.13,
        eyeCenter.dy - coreRadius * (0.14 - 0.03 * s),
      );

      final browPath =
          Path()
            ..moveTo(outerBrow.dx, outerBrow.dy)
            ..quadraticBezierTo(
              eyeCenter.dx,
              eyeCenter.dy - coreRadius * (0.21 - 0.02 * s),
              innerBrow.dx,
              innerBrow.dy,
            );
      canvas.drawPath(browPath, browGlowPaint);
      canvas.drawPath(browPath, browPaint);
    }

    // Vertical forehead tension lines between the eyebrows (||)
    if (s > 0.30) {
      final wrinkleAlpha = ((s - 0.30) / 0.70).clamp(0.0, 1.0);
      final wrinklePaint =
          Paint()
            ..color = Colors.white.withValues(alpha: 0.70 * wrinkleAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = coreRadius * 0.036
            ..strokeCap = StrokeCap.round;

      for (final side in [-1.0, 1.0]) {
        final wx = faceOffset.dx + side * coreRadius * 0.055;
        final wyTop = faceOffset.dy - coreRadius * 0.23;
        final wyBot = faceOffset.dy - coreRadius * 0.14;
        canvas.drawLine(Offset(wx, wyTop), Offset(wx, wyBot), wrinklePaint);
      }
    }

    // 4. Gritted / Wavy Clenched Grimace Mouth (〰)
    final mouthY = faceOffset.dy + coreRadius * (0.24 + 0.02 * s);
    final mouthHalfWidth = coreRadius * (0.16 + 0.07 * s);
    final waveAmp = coreRadius * (0.022 + 0.024 * s);
    final mouthPath = Path();
    const mouthSteps = 28;
    for (var i = 0; i <= mouthSteps; i++) {
      final t = i / mouthSteps; // 0.0 -> 1.0
      final nx = (t * 2.0) - 1.0; // -1.0 -> 1.0
      final envelope = math.sin(t * math.pi);
      final x = faceOffset.dx + nx * mouthHalfWidth;
      // 2.5 tight clenched waves trembling slightly with auraPhase
      final y =
          mouthY +
          math.sin(t * math.pi * 5.0 + math.sin(auraPhase * 12.0) * 0.5) *
              waveAmp *
              envelope;
      if (i == 0) {
        mouthPath.moveTo(x, y);
      } else {
        mouthPath.lineTo(x, y);
      }
    }

    final mouthGlowPaint =
        Paint()
          ..color = secondaryColor.withValues(alpha: 0.65 * s)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW * 1.25
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final mouthStrokePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: (0.82 + 0.18 * s) * awakeQ)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW * 0.76
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(mouthPath, mouthGlowPaint);
    canvas.drawPath(mouthPath, mouthStrokePaint);

    // 5. Animated Sweat Bead trickling down the temple as strain builds
    if (s > 0.20) {
      final dropProgress = ((s - 0.20) / 0.80).clamp(0.0, 1.0);
      final dropCenter = Offset(
        faceOffset.dx - coreRadius * 0.48,
        faceOffset.dy - coreRadius * (0.30 - 0.16 * dropProgress),
      );
      final dropRadius = coreRadius * (0.048 + 0.018 * math.sin(dropProgress * math.pi));
      final dropPath =
          Path()
            ..moveTo(dropCenter.dx, dropCenter.dy - dropRadius * 1.8)
            ..quadraticBezierTo(
              dropCenter.dx + dropRadius * 1.15,
              dropCenter.dy - dropRadius * 0.2,
              dropCenter.dx + dropRadius * 0.85,
              dropCenter.dy + dropRadius * 0.55,
            )
            ..arcToPoint(
              Offset(
                dropCenter.dx - dropRadius * 0.85,
                dropCenter.dy + dropRadius * 0.55,
              ),
              radius: Radius.circular(dropRadius * 0.9),
              clockwise: true,
            )
            ..quadraticBezierTo(
              dropCenter.dx - dropRadius * 1.15,
              dropCenter.dy - dropRadius * 0.2,
              dropCenter.dx,
              dropCenter.dy - dropRadius * 1.8,
            )
            ..close();

      final dropPaint =
          Paint()
            ..color = const Color(
              0xFF7DD3FC,
            ).withValues(alpha: (0.85 * math.sin(dropProgress * math.pi * 0.85 + 0.15)).clamp(0.0, 1.0))
            ..style = PaintingStyle.fill;
      canvas.drawPath(dropPath, dropPaint);
    }

    // 6. Pulsing High-Effort Strain Vein Mark (💢) on upper-right forehead
    if (s > 0.45) {
      final veinAlpha = ((s - 0.45) / 0.55).clamp(0.0, 1.0);
      final pulse = 1.0 + 0.18 * math.sin(auraPhase * 10.0);
      final veinCenter = Offset(
        faceOffset.dx + coreRadius * 0.42,
        faceOffset.dy - coreRadius * 0.34,
      );
      final r = coreRadius * 0.085 * pulse;
      final gap = r * 0.28;

      final veinPaint =
          Paint()
            ..color = Color.lerp(
              Colors.white,
              const Color(0xFFFFBE0B),
              0.45,
            )!.withValues(alpha: 0.90 * veinAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = coreRadius * 0.032
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;

      for (final dx in [-1.0, 1.0]) {
        for (final dy in [-1.0, 1.0]) {
          final p =
              Path()
                ..moveTo(veinCenter.dx + dx * r, veinCenter.dy + dy * gap)
                ..lineTo(veinCenter.dx + dx * gap, veinCenter.dy + dy * gap)
                ..lineTo(veinCenter.dx + dx * gap, veinCenter.dy + dy * r);
          canvas.drawPath(p, veinPaint);
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
      oldDelegate.basePrimary != basePrimary ||
      oldDelegate.baseSecondary != baseSecondary ||
      oldDelegate.baseAccent != baseAccent ||
      oldDelegate.auraPhase != auraPhase ||
      oldDelegate.shadowVolume != shadowVolume ||
      oldDelegate.awakeFactor != awakeFactor ||
      oldDelegate.angryFactor != angryFactor ||
      oldDelegate.strainFactor != strainFactor ||
      oldDelegate.happyFactor != happyFactor ||
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
