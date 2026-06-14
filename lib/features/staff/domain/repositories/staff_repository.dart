import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/staff/data/models/staff_models.dart';

abstract class StaffRepository {
  Future<Either<Failure, StaffOverviewModel>> getOverview();
  Future<Either<Failure, List<StaffMemberModel>>> getStaffList({String? search});
  Future<Either<Failure, StaffDetailModel>> getStaffDetail(String userId);
}
