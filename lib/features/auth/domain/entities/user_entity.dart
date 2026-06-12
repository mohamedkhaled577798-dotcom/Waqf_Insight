import 'package:equatable/equatable.dart';

/// User Entity representing the authenticated user.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? token;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.token,
  });

  @override
  List<Object?> get props => [id, email, name, token];
}
