import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class PropertyListEvent extends Equatable {
  const PropertyListEvent();

  @override
  List<Object?> get props => [];
}

class PropertyListLoadRequested extends PropertyListEvent {
  const PropertyListLoadRequested({
    required this.selection,
    this.search = '',
  });

  final GeoSelection selection;
  final String search;

  @override
  List<Object?> get props => [selection, search];
}

class PropertyListSearchSubmitted extends PropertyListEvent {
  const PropertyListSearchSubmitted(this.search);

  final String search;

  @override
  List<Object?> get props => [search];
}

class PropertyListFilterChanged extends PropertyListEvent {
  const PropertyListFilterChanged(this.selection);

  final GeoSelection selection;

  @override
  List<Object?> get props => [selection];
}

class PropertyListLoadMoreRequested extends PropertyListEvent {
  const PropertyListLoadMoreRequested();
}
