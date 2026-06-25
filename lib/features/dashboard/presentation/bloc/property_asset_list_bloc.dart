import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_asset_list_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_asset_list_state.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

class PropertyAssetListBloc extends Bloc<PropertyAssetListEvent, PropertyAssetListState> {
  PropertyAssetListBloc({required this.repository}) : super(const PropertyAssetListInitial()) {
    on<PropertyAssetListLoadRequested>(_onLoad);
    on<PropertyAssetListSearchSubmitted>(_onSearch);
    on<PropertyAssetListLinkStatusChanged>(_onLinkStatus);
    on<PropertyAssetListFilterChanged>(_onFilterChanged);
    on<PropertyAssetListLoadMoreRequested>(_onLoadMore);
  }

  final DashboardRepository repository;
  GeoSelection _selection = const GeoSelection();
  String _search = '';
  String _linkStatus = 'all';

  Future<void> _onLoad(PropertyAssetListLoadRequested event, Emitter<PropertyAssetListState> emit) async {
    _selection = event.selection;
    _search = event.search;
    _linkStatus = event.linkStatus;
    await _fetch(emit, page: 1, append: false);
  }

  Future<void> _onSearch(PropertyAssetListSearchSubmitted event, Emitter<PropertyAssetListState> emit) async {
    _search = event.search;
    await _fetch(emit, page: 1, append: false);
  }

  Future<void> _onLinkStatus(PropertyAssetListLinkStatusChanged event, Emitter<PropertyAssetListState> emit) async {
    _linkStatus = event.linkStatus;
    await _fetch(emit, page: 1, append: false);
  }

  Future<void> _onFilterChanged(PropertyAssetListFilterChanged event, Emitter<PropertyAssetListState> emit) async {
    _selection = event.selection;
    await _fetch(emit, page: 1, append: false);
  }

  Future<void> _onLoadMore(PropertyAssetListLoadMoreRequested event, Emitter<PropertyAssetListState> emit) async {
    final current = state;
    if (current is! PropertyAssetListLoaded || !current.hasMore || current.isLoadingMore) return;
    emit(PropertyAssetListLoaded(
      items: current.items,
      summary: current.summary,
      totalCount: current.totalCount,
      page: current.page,
      pageSize: current.pageSize,
      hasMore: current.hasMore,
      selection: current.selection,
      search: current.search,
      linkStatus: current.linkStatus,
      isLoadingMore: true,
    ));
    await _fetch(emit, page: current.page + 1, append: true);
  }

  Future<void> _fetch(Emitter<PropertyAssetListState> emit, {required int page, required bool append}) async {
    if (!append) {
      emit(PropertyAssetListLoading(selection: _selection, search: _search, linkStatus: _linkStatus));
    }

    final result = await repository.getPropertyAssetRegistry(
      selection: _selection,
      search: _search,
      linkStatus: _linkStatus,
      page: page,
      pageSize: AppConstants.defaultPageSize,
    );

    result.fold(
      (failure) => emit(PropertyAssetListError(
        message: failure.message,
        selection: _selection,
        search: _search,
        linkStatus: _linkStatus,
      )),
      (response) {
        final data = response.data;
        final previous = state;
        final merged = append && previous is PropertyAssetListLoaded
            ? [...previous.items, ...data.items]
            : data.items;

        emit(PropertyAssetListLoaded(
          items: merged,
          summary: data.summary,
          totalCount: data.totalCount,
          page: data.page,
          pageSize: data.pageSize,
          hasMore: data.hasMore,
          selection: _selection,
          search: _search,
          linkStatus: _linkStatus,
        ));
      },
    );
  }
}
