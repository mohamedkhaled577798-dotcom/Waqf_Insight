import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/dashboard/data/models/executive_models.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class ExecutiveState extends Equatable {
  const ExecutiveState();

  @override
  List<Object?> get props => [];
}

class ExecutiveInitial extends ExecutiveState {
  const ExecutiveInitial();
}

class ExecutiveLoading extends ExecutiveState {
  const ExecutiveLoading({required this.selection});

  final GeoSelection selection;

  @override
  List<Object?> get props => [selection];
}

class ExecutiveLoaded extends ExecutiveState {
  const ExecutiveLoaded({
    required this.overview,
    required this.selection,
  });

  final ExecutiveOverviewModel overview;
  final GeoSelection selection;

  @override
  List<Object?> get props => [overview, selection];
}

class ExecutiveError extends ExecutiveState {
  const ExecutiveError({required this.message, required this.selection});

  final String message;
  final GeoSelection selection;

  @override
  List<Object?> get props => [message, selection];
}

class ExecutiveCalendarLoading extends ExecutiveState {
  const ExecutiveCalendarLoading();
}

class ExecutiveCalendarLoaded extends ExecutiveState {
  const ExecutiveCalendarLoaded({
    required this.calendar,
    required this.selection,
  });

  final ChairmanCalendarModel calendar;
  final GeoSelection selection;

  @override
  List<Object?> get props => [calendar, selection];
}

class ExecutiveCalendarError extends ExecutiveState {
  const ExecutiveCalendarError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
