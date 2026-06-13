import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/network/network_info.dart';
import 'package:waqf_insight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:waqf_insight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:waqf_insight/features/auth/domain/entities/user_entity.dart';
import 'package:waqf_insight/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت للتحقق من بيانات الدخول'),
      );
    }

    try {
      final session = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.cacheSession(
        user: session.user,
        token: session.token,
        expiration: session.expiration,
      );
      return Right(session.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return const Left(
      ServerFailure(message: 'إنشاء الحساب غير متاح في هذا التطبيق'),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        return const Left(CacheFailure(message: 'لا توجد جلسة نشطة'));
      }

      var expiration = await localDataSource.getTokenExpiration();
      final now = DateTime.now();

      if (expiration != null && !expiration.isAfter(now)) {
        if (!await networkInfo.isConnected) {
          await localDataSource.clearCache();
          return const Left(CacheFailure(message: 'انتهت صلاحية الجلسة'));
        }

        try {
          final refreshed = await remoteDataSource.refreshToken();
          await localDataSource.updateToken(
            token: refreshed.token,
            expiration: refreshed.expiration,
          );
          expiration = refreshed.expiration;
        } on UnauthorizedException {
          await localDataSource.clearCache();
          return const Left(UnauthorizedFailure(message: 'انتهت صلاحية الجلسة'));
        } on ServerException {
          await localDataSource.clearCache();
          return const Left(CacheFailure(message: 'لا توجد جلسة نشطة'));
        }
      }

      if (await networkInfo.isConnected) {
        try {
          final profile = await remoteDataSource.getProfile();
          final cached = await localDataSource.getLastUser();
          final merged = profile.copyWith(
            token: cached.token,
            tokenExpiration: expiration ?? cached.tokenExpiration,
          );

          if (merged.token != null && merged.tokenExpiration != null) {
            await localDataSource.cacheSession(
              user: merged,
              token: merged.token!,
              expiration: merged.tokenExpiration!,
            );
          }

          return Right(merged);
        } on UnauthorizedException {
          await localDataSource.clearCache();
          return const Left(UnauthorizedFailure(message: 'انتهت صلاحية الجلسة'));
        } on ServerException {
          // Use cached profile when profile endpoint is temporarily unavailable.
        }
      }

      return Right(await localDataSource.getLastUser());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.logout();
      } catch (_) {
        // Always clear local session even if server logout fails.
      }
    }

    try {
      await localDataSource.clearCache();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }

    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    }
  }
}
