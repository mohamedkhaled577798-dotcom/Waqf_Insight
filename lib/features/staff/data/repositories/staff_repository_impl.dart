import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/network/network_info.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/staff/data/datasources/staff_remote_data_source.dart';
import 'package:waqf_insight/features/staff/data/models/staff_models.dart';
import 'package:waqf_insight/features/staff/domain/repositories/staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  StaffRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final StaffRemoteDataSource remoteDataSource;
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
  Future<Either<Failure, StaffOverviewModel>> getOverview() {
    return _guard(remoteDataSource.getOverview);
  }

  @override
  Future<Either<Failure, List<StaffMemberModel>>> getStaffList({String? search}) {
    return _guard(() => remoteDataSource.getStaffList(search: search));
  }

  @override
  Future<Either<Failure, StaffDetailModel>> getStaffDetail(String userId) {
    return _guard(() => remoteDataSource.getStaffDetail(userId));
  }
}
