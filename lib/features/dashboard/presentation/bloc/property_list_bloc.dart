import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_list_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_list_state.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

class PropertyListBloc extends Bloc<PropertyListEvent, PropertyListState> {
  PropertyListBloc({required this.repository}) : super(const PropertyListInitial()) {
    on<PropertyListLoadRequested>(_onLoad);
    on<PropertyListSearchSubmitted>(_onSearch);
    on<PropertyListFilterChanged>(_onFilterChanged);
    on<PropertyListLoadMoreRequested>(_onLoadMore);
  }

  final DashboardRepository repository;
  GeoSelection _selection = const GeoSelection();
  String _search = '';

  Future<void> _onLoad(
    PropertyListLoadRequested event,
    Emitter<PropertyListState> emit,
  ) async {
    _selection = event.selection;
    _search = event.search;
    await _fetch(emit, page: 1, append: false);
  }

  Future<void> _onSearch(
    PropertyListSearchSubmitted event,
    Emitter<PropertyListState> emit,
  ) async {
    _search = event.search;
    await _fetch(emit, page: 1, append: false);
  }

  Future<void> _onFilterChanged(
    PropertyListFilterChanged event,
    Emitter<PropertyListState> emit,
  ) async {
    _selection = event.selection;
    await _fetch(emit, page: 1, append: false);
  }

  Future<void> _onLoadMore(
    PropertyListLoadMoreRequested event,
    Emitter<PropertyListState> emit,
  ) async {
    final current = state;
    if (current is! PropertyListLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    await _fetch(emit, page: current.page + 1, append: true);
  }

  Future<void> _fetch(
    Emitter<PropertyListState> emit, {
    required int page,
    required bool append,
  }) async {
    if (!append) {
      emit(PropertyListLoading(selection: _selection, search: _search));
    }

    final result = await repository.getPropertyList(
      selection: _selection,
      search: _search,
      page: page,
      pageSize: AppConstants.defaultPageSize,
    );

    result.fold(
      (failure) => emit(
        PropertyListError(
          message: failure.message,
          selection: _selection,
          search: _search,
        ),
      ),
      (response) {
        final data = response.data;
        final previous = state;
        final merged = append && previous is PropertyListLoaded
            ? [...previous.items, ...data.items]
            : data.items;

        emit(
          PropertyListLoaded(
            items: merged,
            totalCount: data.totalCount,
            page: data.pageNumber,
            pageSize: data.pageSize,
            hasMore: data.hasMore,
            selection: _selection,
            search: _search,
          ),
        );
      },
    );
  }
}

extension on PropertyListLoaded {
  PropertyListLoaded copyWith({bool? isLoadingMore}) {
    return PropertyListLoaded(
      items: items,
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
      selection: selection,
      search: search,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
