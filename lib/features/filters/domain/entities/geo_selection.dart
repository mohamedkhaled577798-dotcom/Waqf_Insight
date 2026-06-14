import 'package:equatable/equatable.dart';

class GeoSelection extends Equatable {
  const GeoSelection({
    this.governorateId,
    this.districtId,
    this.subdistrictId,
    this.neighborhoodId,
  });

  final String? governorateId;
  final String? districtId;
  final String? subdistrictId;
  final String? neighborhoodId;

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (governorateId != null) params['governorateId'] = governorateId!;
    if (districtId != null) params['districtId'] = districtId!;
    if (subdistrictId != null) params['subdistrictId'] = subdistrictId!;
    if (neighborhoodId != null) params['neighborhoodId'] = neighborhoodId!;
    return params;
  }

  GeoSelection clearFromLevel(int level) {
    switch (level) {
      case 0:
        return const GeoSelection();
      case 1:
        return GeoSelection(governorateId: governorateId);
      case 2:
        return GeoSelection(
          governorateId: governorateId,
          districtId: districtId,
        );
      case 3:
        return GeoSelection(
          governorateId: governorateId,
          districtId: districtId,
          subdistrictId: subdistrictId,
        );
      default:
        return this;
    }
  }

  @override
  List<Object?> get props =>
      [governorateId, districtId, subdistrictId, neighborhoodId];
}
