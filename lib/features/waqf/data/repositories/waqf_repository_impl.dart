import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/network/network_info.dart';
import 'package:waqf_insight/features/waqf/data/datasources/waqf_local_data_source.dart';
import 'package:waqf_insight/features/waqf/data/datasources/waqf_remote_data_source.dart';
import 'package:waqf_insight/features/waqf/domain/entities/waqf_entity.dart';
import 'package:waqf_insight/features/waqf/domain/repositories/waqf_repository.dart';

/// Concrete implementation of [WaqfRepository].
///
/// Coordinates between remote and local data sources:
/// - If online → fetch from API, cache locally, return data.
/// - If offline → return cached data.
/// - Catches all exceptions and converts them to typed [Failure]s.
class WaqfRepositoryImpl implements WaqfRepository {
  final WaqfRemoteDataSource remoteDataSource;
  final WaqfLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WaqfRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<WaqfEntity>>> getAllWaqfs() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteWaqfs = await remoteDataSource.getAllWaqfs();
        await localDataSource.cacheWaqfs(remoteWaqfs);
        return Right(remoteWaqfs);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      }
    } else {
      try {
        final cachedWaqfs = await localDataSource.getCachedWaqfs();
        return Right(cachedWaqfs);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, WaqfEntity>> getWaqfById(String id) async {
    try {
      final waqf = await remoteDataSource.getWaqfById(id);
      return Right(waqf);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    }
  }
}
