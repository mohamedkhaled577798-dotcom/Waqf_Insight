import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class PropertyAssetListEvent extends Equatable {
  const PropertyAssetListEvent();

  @override
  List<Object?> get props => [];
}

class PropertyAssetListLoadRequested extends PropertyAssetListEvent {
  const PropertyAssetListLoadRequested({
    required this.selection,
    this.search = '',
    this.linkStatus = 'all',
    this.aqarId = '',
  });

  final GeoSelection selection;
  final String search;
  final String linkStatus;
  final String aqarId;

  @override
  List<Object?> get props => [selection, search, linkStatus, aqarId];
}

class PropertyAssetListSearchSubmitted extends PropertyAssetListEvent {
  const PropertyAssetListSearchSubmitted(this.search);
  final String search;
  @override
  List<Object?> get props => [search];
}

class PropertyAssetListLinkStatusChanged extends PropertyAssetListEvent {
  const PropertyAssetListLinkStatusChanged(this.linkStatus);
  final String linkStatus;
  @override
  List<Object?> get props => [linkStatus];
}

class PropertyAssetListFilterChanged extends PropertyAssetListEvent {
  const PropertyAssetListFilterChanged(this.selection);
  final GeoSelection selection;
  @override
  List<Object?> get props => [selection];
}

class PropertyAssetListLoadMoreRequested extends PropertyAssetListEvent {
  const PropertyAssetListLoadMoreRequested();
}
