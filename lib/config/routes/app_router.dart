import 'package:flutter/material.dart';
import 'package:waqf_insight/features/auth/presentation/pages/auth_page.dart';
import 'package:waqf_insight/features/splash/presentation/pages/splash_page.dart';

/// Centralized route management using named routes.
///
/// All route names are defined as constants to avoid typos.
/// The [onGenerateRoute] callback handles navigation and
/// passes arguments to destination pages.
class AppRouter {
  AppRouter._();

  // ── Route Names ───────────────────────────────────────────
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String waqfDetails = '/waqf-details';

  // ── Route Generator ───────────────────────────────────────
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(
          const SplashPage(),
          settings,
        );

      case auth:
        return _buildRoute(
          const AuthPage(),
          settings,
        );

      case home:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('الصفحة الرئيسية')),
          ),
          settings,
        );

      case waqfDetails:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Waqf Details')),
          ),
          settings,
        );

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  /// Creates a [MaterialPageRoute] with a smooth slide transition.
  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
