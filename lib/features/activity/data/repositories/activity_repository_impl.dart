import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/network/network_info.dart';
import 'package:waqf_insight/features/activity/data/datasources/activity_remote_data_source.dart';
import 'package:waqf_insight/features/activity/data/models/activity_model.dart';
import 'package:waqf_insight/features/activity/domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final ActivityRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<ActivityModel>>> getRecentActivity({
    int take = AppConstants.defaultPageSize,
    int skip = 0,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
    try {
      final items = await remoteDataSource.getRecentActivity(
        take: take,
        skip: skip,
      );
      return Right(items);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }
}
