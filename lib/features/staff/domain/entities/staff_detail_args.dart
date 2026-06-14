import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/staff/data/models/staff_models.dart';

class StaffDetailArgs extends Equatable {
  const StaffDetailArgs({
    required this.userId,
    this.preview,
  });

  final String userId;
  final StaffMemberModel? preview;

  @override
  List<Object?> get props => [userId, preview];
}
