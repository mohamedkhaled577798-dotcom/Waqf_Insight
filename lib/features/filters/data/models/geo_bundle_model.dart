import 'package:waqf_insight/features/filters/data/models/geo_option_model.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_bundle.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_option.dart';

class GeoBundleModel extends GeoBundle {
  const GeoBundleModel({
    required super.governorates,
    required super.districts,
    required super.subdistricts,
    required super.neighborhoods,
  });

  factory GeoBundleModel.fromJson(Map<String, dynamic> json) {
    List<GeoOption> parseList(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list
          .map((e) => GeoOptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return GeoBundleModel(
      governorates: parseList('governorates'),
      districts: parseList('districts'),
      subdistricts: parseList('subdistricts'),
      neighborhoods: parseList('neighborhoods'),
    );
  }
}
