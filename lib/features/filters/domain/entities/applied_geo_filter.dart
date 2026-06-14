import 'package:equatable/equatable.dart';

class AppliedGeoFilter extends Equatable {
  const AppliedGeoFilter({
    this.governorateId,
    this.governorateName,
    this.districtId,
    this.districtName,
    this.subdistrictId,
    this.subdistrictName,
    this.neighborhoodId,
    this.neighborhoodName,
    this.hasAnyFilter = false,
  });

  final String? governorateId;
  final String? governorateName;
  final String? districtId;
  final String? districtName;
  final String? subdistrictId;
  final String? subdistrictName;
  final String? neighborhoodId;
  final String? neighborhoodName;
  final bool hasAnyFilter;

  @override
  List<Object?> get props => [
        governorateId,
        governorateName,
        districtId,
        districtName,
        subdistrictId,
        subdistrictName,
        neighborhoodId,
        neighborhoodName,
        hasAnyFilter,
      ];
}
