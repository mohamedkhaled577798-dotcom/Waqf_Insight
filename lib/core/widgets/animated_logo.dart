import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';

/// Animated official logo with golden rings, shimmer, glow, and rising arrows.
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({
    super.key,
    this.size = 140,
    this.showEntrance = true,
  });

  final double size;
  final bool showEntrance;

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.showEntrance) {
      _entranceController.forward();
    } else {
      _entranceController.value = 1;
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _ringController,
        _shimmerController,
        _pulseController,
        _entranceController,
      ]),
      builder: (context, _) {
        final entrance = Curves.elasticOut.transform(_entranceController.value);
        final opacity = Curves.easeIn.transform(_entranceController.value);
        final rotation = (1 - _entranceController.value) * 0.12;
        final ringRotation = _ringController.value * 2 * math.pi;
        final pulseValue = _pulseController.value;
        final shimmerProgress = _shimmerController.value;
        final logoSize = widget.size;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: entrance,
            child: Transform.rotate(
              angle: rotation,
              child: SizedBox(
                width: logoSize + 48,
                height: logoSize + 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: logoSize + 32 + pulseValue * 14,
                      height: logoSize + 32 + pulseValue * 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: SplashColors.gold
                                .withValues(alpha: 0.2 + pulseValue * 0.15),
                            blurRadius: 32 + pulseValue * 16,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: SplashColors.greenSoft.withValues(alpha: 0.6),
                            blurRadius: 24,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                    Transform.rotate(
                      angle: ringRotation,
                      child: CustomPaint(
                        size: Size(logoSize + 36, logoSize + 36),
                        painter: _GoldenRingPainter(dashOffset: ringRotation * 10),
                      ),
                    ),
                    Transform.rotate(
                      angle: -ringRotation * 0.6,
                      child: CustomPaint(
                        size: Size(logoSize + 18, logoSize + 18),
                        painter: _GoldenRingPainter(
                          dashOffset: -ringRotation * 8,
                          strokeWidth: 1.5,
                          opacity: 0.4,
                        ),
                      ),
                    ),
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: SplashColors.gold.withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                            _ShimmerOverlay(progress: shimmerProgress),
                          ],
                        ),
                      ),
                    ),
                    ...List.generate(3, (i) {
                      final offset = (i - 1) * (logoSize * 0.14);
                      final arrowProgress =
                          ((shimmerProgress * 2 + i * 0.2) % 1.0);
                      return Positioned(
                        bottom: 6 + arrowProgress * 10,
                        left: logoSize / 2 + offset - 7,
                        child: Opacity(
                          opacity: (0.3 + pulseValue * 0.5) *
                              (1 - arrowProgress * 0.5),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            size: logoSize * 0.07,
                            color: SplashColors.textPrimaryLight,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GoldenRingPainter extends CustomPainter {
  _GoldenRingPainter({
    required this.dashOffset,
    this.strokeWidth = 2.5,
    this.opacity = 0.75,
  });

  final double dashOffset;
  final double strokeWidth;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          SplashColors.goldDark.withValues(alpha: opacity * 0.3),
          SplashColors.goldLight.withValues(alpha: opacity),
          SplashColors.gold.withValues(alpha: opacity * 0.6),
          SplashColors.goldDark.withValues(alpha: opacity * 0.3),
        ],
        transform: GradientRotation(dashOffset),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);

    const dotCount = 12;
    for (var i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * math.pi + dashOffset;
      canvas.drawCircle(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        2.5,
        Paint()
          ..color = SplashColors.goldLight.withValues(alpha: opacity * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_GoldenRingPainter oldDelegate) =>
      oldDelegate.dashOffset != dashOffset ||
      oldDelegate.opacity != opacity;
}

class _ShimmerOverlay extends StatelessWidget {
  const _ShimmerOverlay({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final shimmerX = (progress * 2 - 0.5) * width;

        return Stack(
          children: [
            Positioned(
              left: shimmerX - width * 0.3,
              top: 0,
              bottom: 0,
              width: width * 0.35,
              child: Transform.rotate(
                angle: -0.4,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
