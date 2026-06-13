import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/growth_bars_painter.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_particles_painter.dart';

class SplashAnimatedContent extends StatelessWidget {
  const SplashAnimatedContent({
    super.key,
    required this.masterProgress,
    required this.particleProgress,
    required this.ringRotation,
    required this.shimmerProgress,
    required this.pulseValue,
  });

  final double masterProgress;
  final double particleProgress;
  final double ringRotation;
  final double shimmerProgress;
  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    final titleOpacity = _interval(masterProgress, 0.35, 0.65);
    final titleSlide = 1 - _interval(masterProgress, 0.35, 0.65);
    final subtitleOpacity = _interval(masterProgress, 0.50, 0.78);
    final subtitleSlide = 1 - _interval(masterProgress, 0.50, 0.78);
    final taglineOpacity = _interval(masterProgress, 0.62, 0.88);
    final barsProgress = _interval(masterProgress, 0.55, 0.95);
    final logoScale = Curves.elasticOut.transform(
      _interval(masterProgress, 0.08, 0.55).clamp(0.0, 1.0),
    );
    final logoOpacity = _interval(masterProgress, 0.0, 0.18);
    final logoRotation = (1 - _interval(masterProgress, 0.08, 0.45)) * 0.15;

    return Stack(
      fit: StackFit.expand,
      children: [
        _AnimatedBackground(pulseValue: pulseValue),
        CustomPaint(
          painter: SplashParticlesPainter(
            progress: particleProgress,
            seed: 42,
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              _LogoSection(
                logoScale: logoScale,
                logoOpacity: logoOpacity,
                logoRotation: logoRotation,
                ringRotation: ringRotation,
                shimmerProgress: shimmerProgress,
                pulseValue: pulseValue,
              ),
              const SizedBox(height: 36),
              Transform.translate(
                offset: Offset(0, 30 * titleSlide),
                child: Opacity(
                  opacity: titleOpacity,
                  child: Text(
                    'ديوان الوقف السني العراقي',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: SplashColors.textPrimaryLight,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: SplashColors.gold.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Transform.translate(
                offset: Offset(0, 24 * subtitleSlide),
                child: Opacity(
                  opacity: subtitleOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      'هيئة إدارة واستثمار أموال الوقف السني',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: SplashColors.textSecondaryLight.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Opacity(
                opacity: taglineOpacity,
                child: _AnimatedTagline(progress: masterProgress),
              ),
              const Spacer(),
              Opacity(
                opacity: taglineOpacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 36,
                        child: CustomPaint(
                          painter: GrowthBarsPainter(progress: barsProgress),
                          size: const Size(double.infinity, 36),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _GoldProgressBar(progress: masterProgress),
                      const SizedBox(height: 12),
                      Text(
                        'جاري التحميل...',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: SplashColors.textSecondaryLight.withValues(alpha: 0.75),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  double _interval(double t, double begin, double end) {
    if (t <= begin) return 0;
    if (t >= end) return 1;
    return (t - begin) / (end - begin);
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({required this.pulseValue});

  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2 + pulseValue * 0.05),
          radius: 1.2,
          colors: [
            SplashColors.mintLight,
            SplashColors.backgroundLight,
            SplashColors.greenSoft.withValues(alpha: 0.35 + pulseValue * 0.15),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _GridGlowPainter(pulseValue: pulseValue),
      ),
    );
  }
}

class _GridGlowPainter extends CustomPainter {
  _GridGlowPainter({required this.pulseValue});

  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SplashColors.gold.withValues(alpha: 0.06 + pulseValue * 0.04)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridGlowPainter oldDelegate) =>
      oldDelegate.pulseValue != pulseValue;
}

class _LogoSection extends StatelessWidget {
  const _LogoSection({
    required this.logoScale,
    required this.logoOpacity,
    required this.logoRotation,
    required this.ringRotation,
    required this.shimmerProgress,
    required this.pulseValue,
  });

  final double logoScale;
  final double logoOpacity;
  final double logoRotation;
  final double ringRotation;
  final double shimmerProgress;
  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    const logoSize = 200.0;

    return Opacity(
      opacity: logoOpacity,
      child: Transform.scale(
        scale: logoScale,
        child: Transform.rotate(
          angle: logoRotation,
          child: SizedBox(
            width: logoSize + 60,
            height: logoSize + 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing glow
                Container(
                  width: logoSize + 40 + pulseValue * 20,
                  height: logoSize + 40 + pulseValue * 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SplashColors.gold.withValues(alpha: 0.2 + pulseValue * 0.15),
                        blurRadius: 36 + pulseValue * 16,
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
                // Rotating golden ring
                Transform.rotate(
                  angle: ringRotation,
                  child: CustomPaint(
                    size: Size(logoSize + 48, logoSize + 48),
                    painter: _GoldenRingPainter(
                      dashOffset: ringRotation * 10,
                    ),
                  ),
                ),
                // Counter-rotating inner ring
                Transform.rotate(
                  angle: -ringRotation * 0.6,
                  child: CustomPaint(
                    size: Size(logoSize + 24, logoSize + 24),
                    painter: _GoldenRingPainter(
                      dashOffset: -ringRotation * 8,
                      strokeWidth: 1.5,
                      opacity: 0.4,
                    ),
                  ),
                ),
                // Logo with shimmer
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SplashColors.gold.withValues(alpha: 0.25),
                        blurRadius: 16,
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
                // Rising arrows accent
                ...List.generate(3, (i) {
                  final offset = (i - 1) * 28.0;
                  final arrowProgress = ((shimmerProgress * 2 + i * 0.2) % 1.0);
                  return Positioned(
                    bottom: 8 + arrowProgress * 12,
                    left: logoSize / 2 + offset - 8,
                    child: Opacity(
                      opacity: (0.3 + pulseValue * 0.5) * (1 - arrowProgress * 0.5),
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        size: 14,
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

    // Decorative dots on ring
    const dotCount = 12;
    for (var i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * math.pi + dashOffset;
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);
      canvas.drawCircle(
        Offset(dotX, dotY),
        2.5,
        Paint()..color = SplashColors.goldLight.withValues(alpha: opacity * 0.8),
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

class _AnimatedTagline extends StatelessWidget {
  const _AnimatedTagline({required this.progress});

  final double progress;

  static const _tags = ['إدارة', 'استثمار', 'تنمية'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _tags.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.circle,
                size: 5,
                color: SplashColors.gold.withValues(
                  alpha: 0.5 + 0.5 * math.sin(progress * math.pi * 2 + i),
                ),
              ),
            ),
          _TagChip(
            label: _tags[i],
            opacity: _chipOpacity(i),
          ),
        ],
      ],
    );
  }

  double _chipOpacity(int index) {
    final start = 0.62 + index * 0.08;
    final end = start + 0.18;
    if (progress <= start) return 0;
    if (progress >= end) return 1;
    return (progress - start) / (end - start);
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.opacity});

  final String label;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: SplashColors.gold.withValues(alpha: 0.55),
            width: 1,
          ),
          color: SplashColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: SplashColors.greenSoft.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: SplashColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}

class _GoldProgressBar extends StatelessWidget {
  const _GoldProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final fillProgress = Curves.easeInOut.transform(
      progress.clamp(0.0, 1.0),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            Container(color: SplashColors.greenSoft.withValues(alpha: 0.7)),
            FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: fillProgress,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SplashColors.deepGreen,
                      SplashColors.gold,
                      SplashColors.goldLight,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
