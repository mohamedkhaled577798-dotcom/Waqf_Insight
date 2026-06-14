import 'package:waqf_insight/features/dashboard/presentation/widgets/property_google_map.dart';

/// Thin wrapper kept for existing imports.
class PropertyMiniMap extends PropertyGoogleMap {
  const PropertyMiniMap({
    super.key,
    required super.latitude,
    required super.longitude,
    super.label,
    super.height = 200,
    super.showSetupHint = true,
  });
}
