import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class DashboardSectionEvent extends Equatable {
  const DashboardSectionEvent();

  @override
  List<Object?> get props => [];
}

class DashboardSectionLoadRequested extends DashboardSectionEvent {
  const DashboardSectionLoadRequested({
    required this.section,
    required this.selection,
  });

  final DashboardSectionType section;
  final GeoSelection selection;

  @override
  List<Object?> get props => [section, selection];
}

class DashboardSectionRefreshRequested extends DashboardSectionEvent {
  const DashboardSectionRefreshRequested();
}
