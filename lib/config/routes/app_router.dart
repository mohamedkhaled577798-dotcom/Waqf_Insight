import 'package:flutter/material.dart';
import 'package:waqf_insight/features/auth/presentation/pages/login_page.dart';
import 'package:waqf_insight/features/home/presentation/pages/main_shell_page.dart';
import 'package:waqf_insight/features/splash/presentation/pages/splash_page.dart';

/// Centralized route management using named routes.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String waqfDetails = '/waqf-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashPage(), settings);

      case auth:
        return _buildRoute(const LoginPage(), settings);

      case home:
        return _buildRoute(const MainShellPage(), settings);

      case waqfDetails:
        return _buildRoute(
          const Scaffold(body: Center(child: Text('Waqf Details'))),
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
