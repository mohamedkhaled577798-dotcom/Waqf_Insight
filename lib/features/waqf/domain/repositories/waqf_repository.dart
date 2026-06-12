import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/features/waqf/domain/entities/waqf_entity.dart';

/// Abstract repository contract for the Waqf feature.
///
/// Defined in the **domain layer** — implemented in the **data layer**.
/// This inversion of dependency is the core of Clean Architecture:
/// the domain never depends on data/infrastructure.
abstract class WaqfRepository {
  /// Fetches all available Waqf items.
  Future<Either<Failure, List<WaqfEntity>>> getAllWaqfs();

  /// Fetches a single Waqf by its [id].
  Future<Either<Failure, WaqfEntity>> getWaqfById(String id);
}
