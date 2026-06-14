import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/features/activity/data/models/activity_model.dart';
import 'package:waqf_insight/features/activity/domain/repositories/activity_repository.dart';
import 'package:waqf_insight/features/activity/presentation/bloc/activity_event.dart';
import 'package:waqf_insight/features/activity/presentation/bloc/activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc({required this.repository}) : super(const ActivityInitial()) {
    on<ActivityLoadRequested>(_onLoad);
    on<ActivityRefreshRequested>(_onRefresh);
    on<ActivityLoadMoreRequested>(_onLoadMore);
    on<ActivityModuleFilterChanged>(_onModuleFilter);
  }

  final ActivityRepository repository;

  static const int _pageSize = AppConstants.defaultPageSize;

  List<ActivityModel> _allItems = [];
  bool _hasMore = true;
  String? _selectedModule;

  Future<void> _onLoad(
    ActivityLoadRequested event,
    Emitter<ActivityState> emit,
  ) async {
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    ActivityRefreshRequested event,
    Emitter<ActivityState> emit,
  ) async {
    await _fetch(emit, silent: state is ActivityLoaded);
  }

  Future<void> _onLoadMore(
    ActivityLoadMoreRequested event,
    Emitter<ActivityState> emit,
  ) async {
    final current = state;
    if (current is! ActivityLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    await _fetch(emit, append: true, silent: true);
  }

  void _onModuleFilter(
    ActivityModuleFilterChanged event,
    Emitter<ActivityState> emit,
  ) {
    _selectedModule = event.module;
    _emitFiltered(emit);
  }

  Future<void> _fetch(
    Emitter<ActivityState> emit, {
    bool append = false,
    bool silent = false,
  }) async {
    if (!silent && !append) emit(const ActivityLoading());

    final skip = append ? _allItems.length : 0;
    final result = await repository.getRecentActivity(
      take: _pageSize,
      skip: skip,
    );

    result.fold(
      (failure) {
        final current = state;
        if (append && current is ActivityLoaded) {
          emit(current.copyWith(isLoadingMore: false));
          return;
        }
        emit(ActivityError(message: failure.message));
      },
      (items) {
        if (append) {
          _allItems = [..._allItems, ...items];
        } else {
          _allItems = items;
        }
        _hasMore = items.length >= _pageSize;
        _emitFiltered(emit);
      },
    );
  }

  void _emitFiltered(Emitter<ActivityState> emit) {
    var filtered = _allItems;
    if (_selectedModule != null && _selectedModule!.isNotEmpty) {
      filtered = filtered
          .where((item) => item.moduleLabel == _selectedModule)
          .toList();
    }

    emit(
      ActivityLoaded(
        allItems: _allItems,
        filteredItems: filtered,
        hasMore: _hasMore,
        pageSize: _pageSize,
        selectedModule: _selectedModule,
      ),
    );
  }
}

extension on ActivityLoaded {
  ActivityLoaded copyWith({bool? isLoadingMore}) {
    return ActivityLoaded(
      allItems: allItems,
      filteredItems: filteredItems,
      hasMore: hasMore,
      pageSize: pageSize,
      selectedModule: selectedModule,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
