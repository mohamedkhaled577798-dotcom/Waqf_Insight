import 'package:flutter/material.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';

/// Three ascending bars representing fund growth and investment returns.
class GrowthBarsPainter extends CustomPainter {
  GrowthBarsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 3;
    const heights = [0.45, 0.72, 1.0];
    final barWidth = size.width / (barCount * 2.2);
    final gap = barWidth * 0.6;

    for (var i = 0; i < barCount; i++) {
      final delay = i * 0.15;
      final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      final eased = Curves.easeOutCubic.transform(t);
      final barHeight = size.height * heights[i] * eased;
      final x = i * (barWidth + gap) + gap / 2;
      final y = size.height - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );

      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          SplashColors.deepGreen,
          SplashColors.gold.withValues(alpha: 0.85),
        ],
      );

      canvas.drawRRect(
        rect,
        Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(x, y, barWidth, barHeight),
          ),
      );

      if (eased > 0.05) {
        canvas.drawRRect(
          rect,
          Paint()
            ..color = SplashColors.goldLight.withValues(alpha: 0.35 * eased)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(GrowthBarsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
