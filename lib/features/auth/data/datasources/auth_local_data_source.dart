import 'dart:convert';

import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/network/auth_token_holder.dart';
import 'package:waqf_insight/core/storage/key_value_storage.dart';
import 'package:waqf_insight/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> getLastUser();
  Future<String?> getToken();
  Future<DateTime?> getTokenExpiration();
  Future<void> cacheSession({
    required UserModel user,
    required String token,
    required DateTime expiration,
  });
  Future<void> updateToken({
    required String token,
    required DateTime expiration,
  });
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required KeyValueStorage storage,
    required AuthTokenHolder tokenHolder,
  })  : _storage = storage,
        _tokenHolder = tokenHolder;

  final KeyValueStorage _storage;
  final AuthTokenHolder _tokenHolder;

  @override
  Future<UserModel> getLastUser() async {
    final userJson = await _storage.read(AppConstants.userKey);
    if (userJson == null) {
      throw const CacheException(message: 'لا توجد جلسة نشطة');
    }

    final user = UserModel.fromJson(
      json.decode(userJson) as Map<String, dynamic>,
    );
    final token = await _storage.read(AppConstants.tokenKey);
    final expirationRaw = await _storage.read(AppConstants.tokenExpirationKey);

    return user.copyWith(
      token: token,
      tokenExpiration:
          expirationRaw != null ? DateTime.parse(expirationRaw) : null,
    );
  }

  @override
  Future<String?> getToken() async => _storage.read(AppConstants.tokenKey);

  @override
  Future<DateTime?> getTokenExpiration() async {
    final raw = await _storage.read(AppConstants.tokenExpirationKey);
    if (raw == null) return null;
    return DateTime.parse(raw);
  }

  @override
  Future<void> cacheSession({
    required UserModel user,
    required String token,
    required DateTime expiration,
  }) async {
    final cachedUser = user.copyWith(
      token: token,
      tokenExpiration: expiration,
    );

    await _storage.write(
      AppConstants.userKey,
      json.encode(cachedUser.toJson()),
    );
    await _storage.write(AppConstants.tokenKey, token);
    await _storage.write(
      AppConstants.tokenExpirationKey,
      expiration.toIso8601String(),
    );
    _tokenHolder.setToken(token);
  }

  @override
  Future<void> updateToken({
    required String token,
    required DateTime expiration,
  }) async {
    await _storage.write(AppConstants.tokenKey, token);
    await _storage.write(
      AppConstants.tokenExpirationKey,
      expiration.toIso8601String(),
    );
    _tokenHolder.setToken(token);

    final userJson = await _storage.read(AppConstants.userKey);
    if (userJson != null) {
      final user = UserModel.fromJson(
        json.decode(userJson) as Map<String, dynamic>,
      );
      await _storage.write(
        AppConstants.userKey,
        json.encode(
          user.copyWith(token: token, tokenExpiration: expiration).toJson(),
        ),
      );
    }
  }

  @override
  Future<void> clearCache() async {
    await _storage.delete(AppConstants.userKey);
    await _storage.delete(AppConstants.tokenKey);
    await _storage.delete(AppConstants.tokenExpirationKey);
    _tokenHolder.clear();
  }
}
