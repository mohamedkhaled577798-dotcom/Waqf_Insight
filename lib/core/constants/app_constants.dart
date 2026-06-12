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
  static const String baseUrl = 'https://api.example.com/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Cache ─────────────────────────────────────────────────
  static const String cacheBoxName = 'waqf_insight_cache';
  static const Duration cacheDuration = Duration(days: 7);

  // ── Pagination ────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Storage Keys ──────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String localeKey = 'app_locale';
}
