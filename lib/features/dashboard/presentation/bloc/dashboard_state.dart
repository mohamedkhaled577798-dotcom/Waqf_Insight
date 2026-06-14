import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/filters/data/models/applied_geo_filter_model.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading({this.selection = const GeoSelection()});

  final GeoSelection selection;

  @override
  List<Object?> get props => [selection];
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.summary,
    required this.selection,
    this.serverFilter,
    this.generatedAt,
  });

  final DashboardSummaryModel summary;
  final GeoSelection selection;
  final AppliedGeoFilterModel? serverFilter;
  final DateTime? generatedAt;

  @override
  List<Object?> get props => [summary, selection, serverFilter, generatedAt];
}

class DashboardError extends DashboardState {
  const DashboardError({
    required this.message,
    this.selection = const GeoSelection(),
  });

  final String message;
  final GeoSelection selection;

  @override
  List<Object?> get props => [message, selection];
}
