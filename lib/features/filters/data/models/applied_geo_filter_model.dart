import 'package:waqf_insight/features/filters/domain/entities/applied_geo_filter.dart';

class AppliedGeoFilterModel extends AppliedGeoFilter {
  const AppliedGeoFilterModel({
    super.governorateId,
    super.governorateName,
    super.districtId,
    super.districtName,
    super.subdistrictId,
    super.subdistrictName,
    super.neighborhoodId,
    super.neighborhoodName,
    super.hasAnyFilter = false,
  });

  factory AppliedGeoFilterModel.fromJson(Map<String, dynamic> json) {
    return AppliedGeoFilterModel(
      governorateId: json['governorateId'] as String?,
      governorateName: json['governorateName'] as String?,
      districtId: json['districtId'] as String?,
      districtName: json['districtName'] as String?,
      subdistrictId: json['subdistrictId'] as String?,
      subdistrictName: json['subdistrictName'] as String?,
      neighborhoodId: json['neighborhoodId'] as String?,
      neighborhoodName: json['neighborhoodName'] as String?,
      hasAnyFilter: json['hasAnyFilter'] as bool? ?? false,
    );
  }

  String get displayLabel {
    if (!hasAnyFilter) return 'كل العراق';

    final parts = <String>[
      if (governorateName != null && governorateName!.isNotEmpty)
        governorateName!,
      if (districtName != null && districtName!.isNotEmpty) districtName!,
      if (subdistrictName != null && subdistrictName!.isNotEmpty)
        subdistrictName!,
      if (neighborhoodName != null && neighborhoodName!.isNotEmpty)
        neighborhoodName!,
    ];

    return parts.isEmpty ? 'كل العراق' : parts.join(' › ');
  }
}
