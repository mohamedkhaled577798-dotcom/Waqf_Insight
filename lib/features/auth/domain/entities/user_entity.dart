import 'package:equatable/equatable.dart';

/// Authenticated chairman user profile.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? jobTitle;
  final String? department;
  final List<String> roles;
  final String? token;
  final DateTime? tokenExpiration;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.jobTitle,
    this.department,
    this.roles = const [],
    this.token,
    this.tokenExpiration,
  });

  bool get isChairman => roles.contains('CommitteeChairman');

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        jobTitle,
        department,
        roles,
        token,
        tokenExpiration,
      ];
}
