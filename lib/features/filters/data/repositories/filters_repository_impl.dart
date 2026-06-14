import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/network/network_info.dart';
import 'package:waqf_insight/features/filters/data/datasources/filters_remote_data_source.dart';
import 'package:waqf_insight/features/filters/domain/entities/applied_geo_filter.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_option.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/domain/repositories/filters_repository.dart';

class FiltersRepositoryImpl implements FiltersRepository {
  FiltersRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final FiltersRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }

    try {
      return Right(await call());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<GeoOption>>> getGovernorates() {
    return _guard(remoteDataSource.getGovernorates);
  }

  @override
  Future<Either<Failure, List<GeoOption>>> getDistricts(String governorateId) {
    return _guard(() => remoteDataSource.getDistricts(governorateId));
  }

  @override
  Future<Either<Failure, List<GeoOption>>> getSubdistricts(String districtId) {
    return _guard(() => remoteDataSource.getSubdistricts(districtId));
  }

  @override
  Future<Either<Failure, List<GeoOption>>> getNeighborhoods(
    String subdistrictId,
  ) {
    return _guard(() => remoteDataSource.getNeighborhoods(subdistrictId));
  }

  @override
  Future<Either<Failure, AppliedGeoFilter>> getAppliedFilter(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getAppliedFilter(selection));
  }
}
