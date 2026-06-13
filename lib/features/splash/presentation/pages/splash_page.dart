import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_event.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_state.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_animated_content.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const _minSplashDuration = Duration(seconds: 5);

  late AnimationController _masterController;
  late AnimationController _particleController;
  late AnimationController _ringController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  bool _hasNavigated = false;
  bool _minDurationElapsed = false;
  bool _authResolved = false;
  AuthState? _pendingAuthState;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

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

    _masterController.forward();

    // Paint splash first, then check auth in background.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const CheckAuthSessionEvent());
    });

    Future.delayed(_minSplashDuration, () {
      if (!mounted) return;
      _minDurationElapsed = true;
      _tryNavigate();
    });
  }

  void _tryNavigate() {
    if (!mounted || _hasNavigated) return;
    if (!_minDurationElapsed || !_authResolved) return;

    final state = _pendingAuthState;
    if (state is Authenticated) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else if (state is Unauthenticated) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacementNamed(AppRouter.auth);
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _particleController.dispose();
    _ringController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated || state is Unauthenticated) {
          _pendingAuthState = state;
          _authResolved = true;
          _tryNavigate();
        }
      },
      child: Scaffold(
        backgroundColor: SplashColors.backgroundLight,
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _masterController,
            _particleController,
            _ringController,
            _shimmerController,
            _pulseController,
          ]),
          builder: (context, _) {
            return SplashAnimatedContent(
              masterProgress: _masterController.value,
              particleProgress: _particleController.value,
              ringRotation: _ringController.value * 2 * 3.14159,
              shimmerProgress: _shimmerController.value,
              pulseValue: _pulseController.value,
            );
          },
        ),
      ),
    );
  }
}
