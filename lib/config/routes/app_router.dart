import 'package:flutter/material.dart';
import 'package:waqf_insight/features/auth/presentation/pages/login_page.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/presentation/pages/dashboard_section_page.dart';
import 'package:waqf_insight/features/dashboard/presentation/pages/geo_distribution_map_page.dart';
import 'package:waqf_insight/features/dashboard/presentation/pages/property_detail_page.dart';
import 'package:waqf_insight/features/dashboard/presentation/pages/property_search_page.dart';
import 'package:waqf_insight/features/activity/presentation/pages/recent_activity_page.dart';
import 'package:waqf_insight/features/staff/domain/entities/staff_detail_args.dart';
import 'package:waqf_insight/features/staff/presentation/pages/staff_detail_page.dart';
import 'package:waqf_insight/features/home/presentation/pages/main_shell_page.dart';
import 'package:waqf_insight/features/splash/presentation/pages/splash_page.dart';

/// Centralized route management using named routes.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String waqfDetails = '/waqf-details';
  static const String dashboardSection = '/dashboard-section';
  static const String geoMap = '/geo-map';
  static const String propertyDetail = '/property-detail';
  static const String propertySearch = '/property-search';
  static const String staffDetail = '/staff-detail';
  static const String recentActivity = '/recent-activity';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashPage(), settings);

      case auth:
        return _buildRoute(const LoginPage(), settings);

      case home:
        return _buildRoute(const MainShellPage(), settings);

      case dashboardSection:
        final args = settings.arguments! as DashboardSectionArgs;
        return _buildRoute(DashboardSectionPage(args: args), settings);

      case geoMap:
        final args = settings.arguments as GeoMapArgs? ?? const GeoMapArgs();
        return _buildRoute(GeoDistributionMapPage(args: args), settings);

      case propertyDetail:
        final args = settings.arguments! as PropertyDetailArgs;
        return _buildRoute(PropertyDetailPage(args: args), settings);

      case propertySearch:
        return _buildRoute(const PropertySearchPage(), settings);

      case staffDetail:
        final args = settings.arguments! as StaffDetailArgs;
        return _buildRoute(StaffDetailPage(args: args), settings);

      case recentActivity:
        return _buildRoute(const RecentActivityPage(), settings);

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
