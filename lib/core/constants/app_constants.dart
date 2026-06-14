/// Application-wide constants.
///
/// Centralized location for all magic strings, URLs, durations, and keys
/// used across the app. Keeps configuration in one place.
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────
  static const String appName = 'Waqf Insight';
  static const String appVersion = '1.0.0';

  // ── API ───────────────────────────────────────────────────
  /// Override at build time: `--dart-define=API_BASE_URL=http://your-host:5187`
  ///
  /// Backend (WaqfLand.API https profile): `http://localhost:5187` or `https://localhost:7100`
  /// Android emulator → host machine: `http://10.0.2.2:5187`
  /// Flutter Web → use HTTP in dev to avoid self-signed cert + CORS issues
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://localhost:44357',
  );

  static const String loginPath = '/api/chairman/auth/login';
  static const String refreshTokenPath = '/api/chairman/auth/refresh-token';
  static const String profilePath = '/api/chairman/auth/profile';
  static const String changePasswordPath = '/api/chairman/auth/change-password';
  static const String logoutPath = '/api/chairman/auth/logout';

  static const String filtersGovernoratesPath =
      '/api/chairman/filters/governorates';
  static const String filtersDistrictsPath =
      '/api/chairman/filters/districts';
  static const String filtersSubdistrictsPath =
      '/api/chairman/filters/subdistricts';
  static const String filtersNeighborhoodsPath =
      '/api/chairman/filters/neighborhoods';
  static const String filtersGeoPath = '/api/chairman/filters/geo';
  static const String filtersAppliedPath = '/api/chairman/filters/applied';

  static const String dashboardSummaryPath =
      '/api/chairman/dashboard/summary';
  static const String dashboardPropertiesPath =
      '/api/chairman/dashboard/properties';
  static const String dashboardContractsPath =
      '/api/chairman/dashboard/contracts';
  static const String dashboardRevenuePath = '/api/chairman/dashboard/revenue';
  static const String dashboardTenantsPath = '/api/chairman/dashboard/tenants';
  static const String dashboardInvestorsPath =
      '/api/chairman/dashboard/investors';
  static const String dashboardPartnersPath =
      '/api/chairman/dashboard/partners';
  static const String dashboardMutawallisPath =
      '/api/chairman/dashboard/mutawallis';
  static const String dashboardModulesPath = '/api/chairman/dashboard/modules';
  static const String dashboardStaffOverviewPath =
      '/api/chairman/dashboard/staff-overview';

  static const String staffListPath = '/api/chairman/staff';
  static String staffDetailPath(String userId) => '/api/chairman/staff/$userId';

  static const String propertiesDistributionPath =
      '/api/chairman/properties/distribution';
  static const String propertiesListPath = '/api/chairman/properties';
  static const String propertiesMapFocusPath =
      '/api/chairman/properties/map-focus';
  static String propertyDetailPath(String id) => '/api/chairman/properties/$id';

  static const String activityRecentPath = '/api/chairman/activity/recent';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Cache ─────────────────────────────────────────────────
  static const String cacheBoxName = 'waqf_insight_cache';
  static const Duration cacheDuration = Duration(days: 7);

  // ── Pagination ────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Storage Keys ──────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String tokenExpirationKey = 'auth_token_expiration';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String localeKey = 'app_locale';
}
