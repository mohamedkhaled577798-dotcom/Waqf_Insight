import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/features/filters/domain/entities/applied_geo_filter.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_option.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class FiltersRepository {
  Future<Either<Failure, List<GeoOption>>> getGovernorates();
  Future<Either<Failure, List<GeoOption>>> getDistricts(String governorateId);
  Future<Either<Failure, List<GeoOption>>> getSubdistricts(String districtId);
  Future<Either<Failure, List<GeoOption>>> getNeighborhoods(String subdistrictId);
  Future<Either<Failure, AppliedGeoFilter>> getAppliedFilter(GeoSelection selection);
}
