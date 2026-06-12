import 'package:equatable/equatable.dart';

/// Base class for all failures in the domain layer.
///
/// Failures are returned from repositories using [Either<Failure, T>]
/// instead of throwing exceptions. This makes error handling explicit
/// and type-safe across the domain and presentation layers.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Unauthorized access'});
}
