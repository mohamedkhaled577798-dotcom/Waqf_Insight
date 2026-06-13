import 'package:flutter/material.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_particles_painter.dart';

/// Branded light background with radial gradient, grid, and rising particles.
class AuthBackground extends StatefulWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_particleController, _pulseController]),
      builder: (context, _) {
        final pulse = _pulseController.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3 + pulse * 0.04),
                  radius: 1.3,
                  colors: [
                    SplashColors.mintLight,
                    SplashColors.backgroundLight,
                    SplashColors.greenSoft.withValues(alpha: 0.35 + pulse * 0.12),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: CustomPaint(
                painter: _GridGlowPainter(pulseValue: pulse),
              ),
            ),
            CustomPaint(
              painter: SplashParticlesPainter(
                progress: _particleController.value,
                seed: 17,
              ),
            ),
            widget.child,
          ],
        );
      },
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
