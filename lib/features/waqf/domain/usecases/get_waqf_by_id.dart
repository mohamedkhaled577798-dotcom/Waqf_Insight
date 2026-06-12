import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/usecases/usecase.dart';
import 'package:waqf_insight/features/waqf/domain/entities/waqf_entity.dart';
import 'package:waqf_insight/features/waqf/domain/repositories/waqf_repository.dart';

/// Use case: Get a single Waqf by ID.
class GetWaqfById extends UseCase<WaqfEntity, WaqfByIdParams> {
  final WaqfRepository repository;

  GetWaqfById(this.repository);

  @override
  Future<Either<Failure, WaqfEntity>> call(WaqfByIdParams params) {
    return repository.getWaqfById(params.id);
  }
}

/// Parameters for [GetWaqfById].
class WaqfByIdParams extends Equatable {
  final String id;

  const WaqfByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
