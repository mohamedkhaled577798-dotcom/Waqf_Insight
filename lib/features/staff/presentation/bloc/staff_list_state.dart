import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/staff/data/models/staff_models.dart';

abstract class StaffListState extends Equatable {
  const StaffListState();

  @override
  List<Object?> get props => [];
}

class StaffListInitial extends StaffListState {
  const StaffListInitial();
}

class StaffListLoading extends StaffListState {
  const StaffListLoading();
}

class StaffListLoaded extends StaffListState {
  const StaffListLoaded({
    required this.allMembers,
    required this.filteredMembers,
    required this.overview,
    required this.search,
    this.typeFilter,
    required this.activeOnly,
  });

  final List<StaffMemberModel> allMembers;
  final List<StaffMemberModel> filteredMembers;
  final StaffOverviewModel overview;
  final String search;
  final String? typeFilter;
  final bool activeOnly;

  @override
  List<Object?> get props =>
      [allMembers, filteredMembers, overview, search, typeFilter, activeOnly];
}

class StaffListError extends StaffListState {
  const StaffListError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
