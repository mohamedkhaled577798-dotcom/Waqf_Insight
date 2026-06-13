import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/usecases/usecase.dart';
import 'package:waqf_insight/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordUseCase extends UseCase<Unit, ChangePasswordParams> {
  ChangePasswordUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, Unit>> call(ChangePasswordParams params) {
    return repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

class ChangePasswordParams extends Equatable {
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
