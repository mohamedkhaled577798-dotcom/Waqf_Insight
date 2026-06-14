import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required this.repository}) : super(const DashboardInitial()) {
    on<DashboardSummaryRequested>(_onSummaryRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  final DashboardRepository repository;
  GeoSelection _lastSelection = const GeoSelection();

  Future<void> _onSummaryRequested(
    DashboardSummaryRequested event,
    Emitter<DashboardState> emit,
  ) async {
    _lastSelection = event.selection;
    emit(DashboardLoading(selection: event.selection));

    final result = await repository.getSummary(event.selection);
    result.fold(
      (failure) => emit(
        DashboardError(message: failure.message, selection: event.selection),
      ),
      (response) => emit(
        DashboardLoaded(
          summary: response.data,
          selection: event.selection,
          serverFilter: response.filter,
          generatedAt: response.data.generatedAt,
        ),
      ),
    );
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    add(DashboardSummaryRequested(_lastSelection));
  }
}
