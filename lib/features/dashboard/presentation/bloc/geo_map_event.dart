import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class GeoMapEvent extends Equatable {
  const GeoMapEvent();

  @override
  List<Object?> get props => [];
}

class GeoMapLoadRequested extends GeoMapEvent {
  const GeoMapLoadRequested(this.selection);

  final GeoSelection selection;

  @override
  List<Object?> get props => [selection];
}

class GeoMapFilterChanged extends GeoMapEvent {
  const GeoMapFilterChanged(this.selection);

  final GeoSelection selection;

  @override
  List<Object?> get props => [selection];
}
