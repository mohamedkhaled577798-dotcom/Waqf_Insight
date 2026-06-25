import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_state.dart';

class ExecutiveBloc extends Bloc<ExecutiveEvent, ExecutiveState> {
  ExecutiveBloc({required this.repository}) : super(const ExecutiveInitial()) {
    on<ExecutiveOverviewRequested>(_onOverviewRequested);
    on<ExecutiveCalendarRequested>(_onCalendarRequested);
  }

  final DashboardRepository repository;

  Future<void> _onOverviewRequested(
    ExecutiveOverviewRequested event,
    Emitter<ExecutiveState> emit,
  ) async {
    emit(ExecutiveLoading(selection: event.selection));

    final result = await repository.getExecutiveOverview(event.selection);
    result.fold(
      (failure) => emit(
        ExecutiveError(message: failure.message, selection: event.selection),
      ),
      (response) => emit(
        ExecutiveLoaded(overview: response.data, selection: event.selection),
      ),
    );
  }

  Future<void> _onCalendarRequested(
    ExecutiveCalendarRequested event,
    Emitter<ExecutiveState> emit,
  ) async {
    emit(const ExecutiveCalendarLoading());

    final result = await repository.getExecutiveCalendar(
      selection: event.selection,
      year: event.year,
      month: event.month,
    );

    result.fold(
      (failure) => emit(ExecutiveCalendarError(message: failure.message)),
      (response) => emit(
        ExecutiveCalendarLoaded(
          calendar: response.data,
          selection: event.selection,
        ),
      ),
    );
  }
}
