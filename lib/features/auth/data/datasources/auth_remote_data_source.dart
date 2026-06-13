import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/features/auth/data/models/auth_session_model.dart';
import 'package:waqf_insight/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<RefreshTokenModel> refreshToken();

  Future<UserModel> getProfile();

  Future<void> logout();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        AppConstants.loginPath,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException(message: 'استجابة غير متوقعة من الخادم');
      }

      return AuthSessionModel.fromLoginJson(data);
    } on UnauthorizedException {
      throw const ServerException(
        message:
            'بيانات الدخول غير صحيحة، أو الحساب ليس له دور رئيس الهيئة',
        statusCode: 401,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<RefreshTokenModel> refreshToken() async {
    final response = await apiClient.post(AppConstants.refreshTokenPath);
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw const ServerException(message: 'استجابة غير متوقعة من الخادم');
    }

    return RefreshTokenModel.fromJson(data);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await apiClient.get(AppConstants.profilePath);
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw const ServerException(message: 'استجابة غير متوقعة من الخادم');
    }

    return UserModel.fromProfileJson(data);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(AppConstants.logoutPath);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.post(
      AppConstants.changePasswordPath,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
