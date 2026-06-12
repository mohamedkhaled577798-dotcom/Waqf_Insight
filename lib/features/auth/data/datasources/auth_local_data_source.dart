import 'dart:convert';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> getLastUser();
  Future<void> cacheUser(UserModel userToCache);
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // Normally using SharedPreferences or secure storage.
  // We can mock it using a local map or mock storage for demonstration.
  static String? _cachedUserJson;

  @override
  Future<UserModel> getLastUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_cachedUserJson != null) {
      return UserModel.fromJson(json.decode(_cachedUserJson!) as Map<String, dynamic>);
    }
    throw const CacheException(message: "لا توجد جلسة نشطة");
  }

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _cachedUserJson = json.encode(userToCache.toJson());
  }

  @override
  Future<void> clearCache() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _cachedUserJson = null;
  }
}
