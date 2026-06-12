import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/usecases/usecase.dart';
import 'package:waqf_insight/features/waqf/domain/entities/waqf_entity.dart';
import 'package:waqf_insight/features/waqf/domain/repositories/waqf_repository.dart';

/// Use case: Get all Waqf items.
///
/// Takes [NoParams] and returns a list of [WaqfEntity].
class GetAllWaqfs extends UseCase<List<WaqfEntity>, NoParams> {
  final WaqfRepository repository;

  GetAllWaqfs(this.repository);

  @override
  Future<Either<Failure, List<WaqfEntity>>> call(NoParams params) {
    return repository.getAllWaqfs();
  }
}
