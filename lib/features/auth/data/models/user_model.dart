import 'package:waqf_insight/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.jobTitle,
    super.department,
    super.roles = const [],
    super.token,
    super.tokenExpiration,
  });

  factory UserModel.fromProfileJson(
    Map<String, dynamic> json, {
    String? token,
    DateTime? expiration,
  }) {
    return UserModel(
      id: json['userId'] as String,
      email: json['email'] as String,
      name: json['fullName'] as String,
      phone: json['phone'] as String?,
      jobTitle: json['jobTitle'] as String?,
      department: json['department'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          const [],
      token: token,
      tokenExpiration: expiration,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      jobTitle: json['jobTitle'] as String?,
      department: json['department'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          const [],
      token: json['token'] as String?,
      tokenExpiration: json['tokenExpiration'] != null
          ? DateTime.parse(json['tokenExpiration'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'jobTitle': jobTitle,
      'department': department,
      'roles': roles,
      'token': token,
      'tokenExpiration': tokenExpiration?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? jobTitle,
    String? department,
    List<String>? roles,
    String? token,
    DateTime? tokenExpiration,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      roles: roles ?? this.roles,
      token: token ?? this.token,
      tokenExpiration: tokenExpiration ?? this.tokenExpiration,
    );
  }
}
