import 'package:waqf_insight/features/filters/domain/entities/geo_option.dart';

class GeoOptionModel extends GeoOption {
  const GeoOptionModel({
    required super.id,
    required super.name,
    super.code,
    super.parentId,
    super.propertiesCount,
  });

  factory GeoOptionModel.fromJson(Map<String, dynamic> json) {
    return GeoOptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      parentId: json['parentId'] as String?,
      propertiesCount: json['propertiesCount'] as int? ?? 0,
    );
  }
}
