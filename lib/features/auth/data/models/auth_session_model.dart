import 'package:waqf_insight/features/auth/data/models/user_model.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.token,
    required this.expiration,
    required this.user,
  });

  final String token;
  final DateTime expiration;
  final UserModel user;

  factory AuthSessionModel.fromLoginJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: json['token'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
      user: UserModel.fromProfileJson(
        json['user'] as Map<String, dynamic>,
        token: json['token'] as String,
        expiration: DateTime.parse(json['expiration'] as String),
      ),
    );
  }
}

class RefreshTokenModel {
  const RefreshTokenModel({
    required this.token,
    required this.expiration,
  });

  final String token;
  final DateTime expiration;

  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenModel(
      token: json['token'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
    );
  }
}
