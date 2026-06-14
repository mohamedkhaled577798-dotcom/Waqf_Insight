import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/filters/data/models/applied_geo_filter_model.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_option.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class FiltersState extends Equatable {
  const FiltersState();

  @override
  List<Object?> get props => [];
}

class FiltersInitial extends FiltersState {
  const FiltersInitial();
}

class FiltersLoading extends FiltersState {
  const FiltersLoading({this.selection = const GeoSelection()});

  final GeoSelection selection;

  @override
  List<Object?> get props => [selection];
}

class FiltersLoaded extends FiltersState {
  const FiltersLoaded({
    required this.selection,
    required this.governorates,
    required this.districts,
    required this.subdistricts,
    required this.neighborhoods,
    required this.appliedFilter,
    this.isRefreshingLevel = false,
    this.errorMessage,
  });

  final GeoSelection selection;
  final List<GeoOption> governorates;
  final List<GeoOption> districts;
  final List<GeoOption> subdistricts;
  final List<GeoOption> neighborhoods;
  final AppliedGeoFilterModel appliedFilter;
  final bool isRefreshingLevel;
  final String? errorMessage;

  Map<String, String> get dashboardQuery => selection.toQueryParams();

  String get filterChipLabel => appliedFilter.displayLabel;

  FiltersLoaded copyWith({
    GeoSelection? selection,
    List<GeoOption>? governorates,
    List<GeoOption>? districts,
    List<GeoOption>? subdistricts,
    List<GeoOption>? neighborhoods,
    AppliedGeoFilterModel? appliedFilter,
    bool? isRefreshingLevel,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FiltersLoaded(
      selection: selection ?? this.selection,
      governorates: governorates ?? this.governorates,
      districts: districts ?? this.districts,
      subdistricts: subdistricts ?? this.subdistricts,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      appliedFilter: appliedFilter ?? this.appliedFilter,
      isRefreshingLevel: isRefreshingLevel ?? this.isRefreshingLevel,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selection,
        governorates,
        districts,
        subdistricts,
        neighborhoods,
        appliedFilter,
        isRefreshingLevel,
        errorMessage,
      ];
}

class FiltersError extends FiltersState {
  const FiltersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
