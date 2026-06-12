import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:waqf_insight/core/errors/failures.dart';

/// Base class for all use cases in the domain layer.
///
/// Each use case represents a single business action. It takes [Params]
/// and returns [Either<Failure, Type>] — a success value or a failure.
///
/// Usage:
/// ```dart
/// class GetWaqfDetails extends UseCase<WaqfEntity, WaqfParams> {
///   @override
///   Future<Either<Failure, WaqfEntity>> call(WaqfParams params) async { ... }
/// }
/// ```
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use [NoParams] when a use case doesn't require any input parameters.
///
/// Example:
/// ```dart
/// class GetAllWaqfs extends UseCase<List<WaqfEntity>, NoParams> { ... }
/// ```
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
