/// Builds dashboard API query params from the finest selected geo level.
Map<String, String> buildDashboardQuery({
  String? governorateId,
  String? districtId,
  String? subdistrictId,
  String? neighborhoodId,
}) {
  final params = <String, String>{};
  if (governorateId != null) params['governorateId'] = governorateId;
  if (districtId != null) params['districtId'] = districtId;
  if (subdistrictId != null) params['subdistrictId'] = subdistrictId;
  if (neighborhoodId != null) params['neighborhoodId'] = neighborhoodId;
  return params;
}
