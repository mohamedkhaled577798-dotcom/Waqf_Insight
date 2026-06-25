import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_asset_models.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class PropertyAssetListState extends Equatable {
  const PropertyAssetListState();

  @override
  List<Object?> get props => [];
}

class PropertyAssetListInitial extends PropertyAssetListState {
  const PropertyAssetListInitial();
}

class PropertyAssetListLoading extends PropertyAssetListState {
  const PropertyAssetListLoading({
    required this.selection,
    required this.search,
    required this.linkStatus,
  });

  final GeoSelection selection;
  final String search;
  final String linkStatus;

  @override
  List<Object?> get props => [selection, search, linkStatus];
}

class PropertyAssetListLoaded extends PropertyAssetListState {
  const PropertyAssetListLoaded({
    required this.items,
    required this.summary,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    required this.selection,
    required this.search,
    required this.linkStatus,
    this.isLoadingMore = false,
  });

  final List<PropertyAssetListItemModel> items;
  final PropertyAssetSummaryModel summary;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;
  final GeoSelection selection;
  final String search;
  final String linkStatus;
  final bool isLoadingMore;

  @override
  List<Object?> get props => [
        items,
        summary,
        totalCount,
        page,
        hasMore,
        selection,
        search,
        linkStatus,
        isLoadingMore,
      ];
}

class PropertyAssetListError extends PropertyAssetListState {
  const PropertyAssetListError({
    required this.message,
    required this.selection,
    required this.search,
    required this.linkStatus,
  });

  final String message;
  final GeoSelection selection;
  final String search;
  final String linkStatus;

  @override
  List<Object?> get props => [message, selection, search, linkStatus];
}
