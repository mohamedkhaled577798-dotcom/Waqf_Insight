import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class PropertyListState extends Equatable {
  const PropertyListState();

  @override
  List<Object?> get props => [];
}

class PropertyListInitial extends PropertyListState {
  const PropertyListInitial();
}

class PropertyListLoading extends PropertyListState {
  const PropertyListLoading({required this.selection, required this.search});

  final GeoSelection selection;
  final String search;

  @override
  List<Object?> get props => [selection, search];
}

class PropertyListLoaded extends PropertyListState {
  const PropertyListLoaded({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    required this.selection,
    required this.search,
    this.isLoadingMore = false,
  });

  final List<PropertyListItemModel> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;
  final GeoSelection selection;
  final String search;
  final bool isLoadingMore;

  @override
  List<Object?> get props =>
      [items, totalCount, page, pageSize, hasMore, selection, search, isLoadingMore];
}

class PropertyListError extends PropertyListState {
  const PropertyListError({
    required this.message,
    required this.selection,
    required this.search,
  });

  final String message;
  final GeoSelection selection;
  final String search;

  @override
  List<Object?> get props => [message, selection, search];
}
