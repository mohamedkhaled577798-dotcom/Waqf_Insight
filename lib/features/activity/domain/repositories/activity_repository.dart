import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/features/activity/data/models/activity_model.dart';

abstract class ActivityRepository {
  Future<Either<Failure, List<ActivityModel>>> getRecentActivity({
    int take = AppConstants.defaultPageSize,
    int skip = 0,
  });
}
