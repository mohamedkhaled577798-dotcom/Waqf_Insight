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
  /// Override at build time: `--dart-define=API_BASE_URL=https://your-host`
  ///
  /// Android emulator → host machine: `http://10.0.2.2:5000`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://localhost:7100',
  );

  static const String loginPath = '/api/chairman/auth/login';
  static const String refreshTokenPath = '/api/chairman/auth/refresh-token';
  static const String profilePath = '/api/chairman/auth/profile';
  static const String changePasswordPath = '/api/chairman/auth/change-password';
  static const String logoutPath = '/api/chairman/auth/logout';

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
