import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardSummaryRequested extends DashboardEvent {
  const DashboardSummaryRequested(this.selection);

  final GeoSelection selection;

  @override
  List<Object?> get props => [selection];
}

class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}
