import 'package:flutter/material.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/theme/app_theme.dart';

/// Root widget of the application.
///
/// Configures theme, routing, and global providers.
/// BLoC providers are wrapped at the top level or per-feature as needed.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waqf Insight',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routing
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
