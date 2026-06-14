import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/geo_map_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/geo_map_state.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

class GeoMapBloc extends Bloc<GeoMapEvent, GeoMapState> {
  GeoMapBloc({required this.repository}) : super(const GeoMapInitial()) {
    on<GeoMapLoadRequested>(_onLoad);
    on<GeoMapFilterChanged>(_onFilterChanged);
  }

  final DashboardRepository repository;
  GeoSelection _selection = const GeoSelection();

  Future<void> _onLoad(GeoMapLoadRequested event, Emitter<GeoMapState> emit) async {
    _selection = event.selection;
    await _load(emit);
  }

  Future<void> _onFilterChanged(
    GeoMapFilterChanged event,
    Emitter<GeoMapState> emit,
  ) async {
    _selection = event.selection;
    await _load(emit);
  }

  Future<void> _load(Emitter<GeoMapState> emit) async {
    emit(GeoMapLoading(selection: _selection));
    final result = await repository.getPropertyDistribution(_selection);
    result.fold(
      (failure) => emit(
        GeoMapError(message: failure.message, selection: _selection),
      ),
      (response) => emit(
        GeoMapLoaded(distribution: response.data, selection: _selection),
      ),
    );
  }
}
