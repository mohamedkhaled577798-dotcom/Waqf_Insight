import 'package:equatable/equatable.dart';

abstract class StaffListEvent extends Equatable {
  const StaffListEvent();

  @override
  List<Object?> get props => [];
}

class StaffListLoadRequested extends StaffListEvent {
  const StaffListLoadRequested({this.search = ''});

  final String search;

  @override
  List<Object?> get props => [search];
}

class StaffListSearchSubmitted extends StaffListEvent {
  const StaffListSearchSubmitted(this.search);

  final String search;

  @override
  List<Object?> get props => [search];
}

class StaffListTypeFilterChanged extends StaffListEvent {
  const StaffListTypeFilterChanged(this.typeFilter);

  final String? typeFilter;

  @override
  List<Object?> get props => [typeFilter];
}

class StaffListActiveFilterChanged extends StaffListEvent {
  const StaffListActiveFilterChanged(this.activeOnly);

  final bool activeOnly;

  @override
  List<Object?> get props => [activeOnly];
}
