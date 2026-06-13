import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';

/// Rising gold particles symbolizing investment growth.
class SplashParticlesPainter extends CustomPainter {
  SplashParticlesPainter({required this.progress, required this.seed});

  final double progress;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    for (var i = 0; i < 48; i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final phase = random.nextDouble();
      final y = size.height - ((progress * speed + phase) % 1.0) * (size.height + 40);
      final radius = 1.2 + random.nextDouble() * 2.8;
      final opacity = (0.2 + random.nextDouble() * 0.45) *
          (1 - ((progress * speed + phase) % 1.0)).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = SplashColors.goldDark.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(Offset(baseX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(SplashParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
