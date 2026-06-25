import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class ExecutiveEvent extends Equatable {
  const ExecutiveEvent();

  @override
  List<Object?> get props => [];
}

class ExecutiveOverviewRequested extends ExecutiveEvent {
  const ExecutiveOverviewRequested(this.selection);

  final GeoSelection selection;

  @override
  List<Object?> get props => [selection];
}

class ExecutiveCalendarRequested extends ExecutiveEvent {
  const ExecutiveCalendarRequested({
    required this.selection,
    required this.year,
    required this.month,
  });

  final GeoSelection selection;
  final int year;
  final int month;

  @override
  List<Object?> get props => [selection, year, month];
}
