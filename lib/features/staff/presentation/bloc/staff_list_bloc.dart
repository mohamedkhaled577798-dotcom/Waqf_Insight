import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/staff/data/models/staff_models.dart';
import 'package:waqf_insight/features/staff/domain/repositories/staff_repository.dart';
import 'package:waqf_insight/features/staff/presentation/bloc/staff_list_event.dart';
import 'package:waqf_insight/features/staff/presentation/bloc/staff_list_state.dart';

class StaffListBloc extends Bloc<StaffListEvent, StaffListState> {
  StaffListBloc({required this.repository}) : super(const StaffListInitial()) {
    on<StaffListLoadRequested>(_onLoad);
    on<StaffListSearchSubmitted>(_onSearch);
    on<StaffListTypeFilterChanged>(_onTypeFilter);
    on<StaffListActiveFilterChanged>(_onActiveFilter);
  }

  final StaffRepository repository;
  String _search = '';
  String? _typeFilter;
  bool _activeOnly = false;
  List<StaffMemberModel> _allMembers = [];
  StaffOverviewModel? _overview;

  Future<void> _onLoad(
    StaffListLoadRequested event,
    Emitter<StaffListState> emit,
  ) async {
    _search = event.search;
    await _fetch(emit);
  }

  Future<void> _onSearch(
    StaffListSearchSubmitted event,
    Emitter<StaffListState> emit,
  ) async {
    _search = event.search;
    await _fetch(emit);
  }

  void _onTypeFilter(
    StaffListTypeFilterChanged event,
    Emitter<StaffListState> emit,
  ) {
    _typeFilter = event.typeFilter;
    _emitFiltered(emit);
  }

  void _onActiveFilter(
    StaffListActiveFilterChanged event,
    Emitter<StaffListState> emit,
  ) {
    _activeOnly = event.activeOnly;
    _emitFiltered(emit);
  }

  Future<void> _fetch(Emitter<StaffListState> emit) async {
    emit(const StaffListLoading());

    final overviewResult = await repository.getOverview();
    final listResult = await repository.getStaffList(search: _search);

    StaffOverviewModel overview = StaffOverviewModel.empty();
    overviewResult.fold((_) {}, (value) => overview = value);

    listResult.fold(
      (failure) => emit(StaffListError(message: failure.message)),
      (members) {
        _allMembers = members;
        _overview = overview;
        _emitFiltered(emit);
      },
    );
  }

  void _emitFiltered(Emitter<StaffListState> emit) {
    var filtered = _allMembers;

    if (_typeFilter != null && _typeFilter!.isNotEmpty) {
      filtered = filtered.where((m) => m.staffType == _typeFilter).toList();
    }

    if (_activeOnly) {
      filtered = filtered.where((m) => m.isActive).toList();
    }

    emit(
      StaffListLoaded(
        allMembers: _allMembers,
        filteredMembers: filtered,
        overview: _overview ?? StaffOverviewModel.empty(),
        search: _search,
        typeFilter: _typeFilter,
        activeOnly: _activeOnly,
      ),
    );
  }
}
