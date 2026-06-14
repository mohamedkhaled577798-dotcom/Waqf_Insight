import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class DashboardSectionState extends Equatable {
  const DashboardSectionState();

  @override
  List<Object?> get props => [];
}

class DashboardSectionInitial extends DashboardSectionState {
  const DashboardSectionInitial();
}

class DashboardSectionLoading extends DashboardSectionState {
  const DashboardSectionLoading({
    required this.section,
    required this.selection,
  });

  final DashboardSectionType section;
  final GeoSelection selection;

  @override
  List<Object?> get props => [section, selection];
}

class DashboardSectionLoaded extends DashboardSectionState {
  const DashboardSectionLoaded({
    required this.section,
    required this.selection,
    required this.data,
  });

  final DashboardSectionType section;
  final GeoSelection selection;
  final Object data;

  @override
  List<Object?> get props => [section, selection, data];
}

class DashboardSectionError extends DashboardSectionState {
  const DashboardSectionError({
    required this.message,
    required this.section,
    required this.selection,
  });

  final String message;
  final DashboardSectionType section;
  final GeoSelection selection;

  @override
  List<Object?> get props => [message, section, selection];
}
