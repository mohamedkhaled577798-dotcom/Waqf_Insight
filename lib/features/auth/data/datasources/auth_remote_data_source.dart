import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Mocking or hitting API. Let's provide a mock implementation for demonstration.
      await Future.delayed(const Duration(seconds: 1));
      
      if (email == "demo@waqf.gov.iq" && password == "123456") {
        return const UserModel(
          id: "1",
          email: "demo@waqf.gov.iq",
          name: "أحمد محمد",
          token: "mock_jwt_token",
        );
      } else {
        throw const ServerException(message: "البريد الإلكتروني أو كلمة المرور غير صحيحة");
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        token: "mock_jwt_token",
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
