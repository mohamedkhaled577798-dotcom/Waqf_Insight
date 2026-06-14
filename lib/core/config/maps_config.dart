/// Google Maps configuration.
class MapsConfig {
  MapsConfig._();

  static const String apiKey = 'AIzaSyBwKPVu6XJiG6FVdzcvAROW2nOAtGH1caY';

  static const String placeholderKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  static const String dartDefineKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: apiKey,
  );

  static bool get isConfigured =>
      apiKey.isNotEmpty && apiKey != placeholderKey;
}
