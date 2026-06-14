import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class GeoMapState extends Equatable {
  const GeoMapState();

  @override
  List<Object?> get props => [];
}

class GeoMapInitial extends GeoMapState {
  const GeoMapInitial();
}

class GeoMapLoading extends GeoMapState {
  const GeoMapLoading({this.selection = const GeoSelection()});

  final GeoSelection selection;

  @override
  List<Object?> get props => [selection];
}

class GeoMapLoaded extends GeoMapState {
  const GeoMapLoaded({
    required this.distribution,
    required this.selection,
  });

  final PropertyDistributionModel distribution;
  final GeoSelection selection;

  @override
  List<Object?> get props => [distribution, selection];
}

class GeoMapError extends GeoMapState {
  const GeoMapError({required this.message, required this.selection});

  final String message;
  final GeoSelection selection;

  @override
  List<Object?> get props => [message, selection];
}
