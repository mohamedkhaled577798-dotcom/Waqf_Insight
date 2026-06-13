import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/network/network_info.dart';
import 'package:waqf_insight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:waqf_insight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:waqf_insight/features/auth/data/models/user_model.dart';
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
      if (!await localDataSource.hasSession()) {
        return const Left(CacheFailure(message: 'لا توجد جلسة نشطة'));
      }

      await localDataSource.syncTokenHolder();

      UserModel user;
      try {
        user = await localDataSource.getLastUser();
      } on CacheException {
        return const Left(CacheFailure(message: 'لا توجد جلسة نشطة'));
      }

      // Restore cached session first — only clear on explicit 401.
      user = await _refreshSessionIfNeeded(user);

      if (await networkInfo.isConnected) {
        user = await _tryRefreshProfile(user);
      }

      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  Future<UserModel> _refreshSessionIfNeeded(UserModel user) async {
    final expiration = user.tokenExpiration;
    final isExpired = expiration != null &&
        !expiration.isAfter(DateTime.now().add(const Duration(minutes: 1)));

    if (!isExpired || !await networkInfo.isConnected) {
      return user;
    }

    try {
      final refreshed = await remoteDataSource.refreshToken();
      await localDataSource.updateToken(
        token: refreshed.token,
        expiration: refreshed.expiration,
      );
      return user.copyWith(
        token: refreshed.token,
        tokenExpiration: refreshed.expiration,
      );
    } on UnauthorizedException {
      await localDataSource.clearCache();
      throw const CacheException(message: 'انتهت صلاحية الجلسة');
    } catch (_) {
      // Keep saved session when refresh fails (network/server down).
      return user;
    }
  }

  Future<UserModel> _tryRefreshProfile(UserModel user) async {
    try {
      final profile = await remoteDataSource.getProfile();
      final token = await localDataSource.getToken();
      final expiration = await localDataSource.getTokenExpiration();

      if (token != null && expiration != null) {
        await localDataSource.cacheSession(
          user: profile,
          token: token,
          expiration: expiration,
        );
      }

      return profile.copyWith(
        token: token ?? user.token,
        tokenExpiration: expiration ?? user.tokenExpiration,
      );
    } on UnauthorizedException {
      await localDataSource.clearCache();
      throw const CacheException(message: 'انتهت صلاحية الجلسة');
    } catch (_) {
      return user;
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
