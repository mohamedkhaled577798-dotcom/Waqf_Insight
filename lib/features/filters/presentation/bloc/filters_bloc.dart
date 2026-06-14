import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/features/filters/data/models/applied_geo_filter_model.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/domain/repositories/filters_repository.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_event.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';

class FiltersBloc extends Bloc<FiltersEvent, FiltersState> {
  FiltersBloc({required this.repository}) : super(const FiltersInitial()) {
    on<FiltersInitialized>(_onInitialized);
    on<GovernorateSelected>(_onGovernorateSelected);
    on<DistrictSelected>(_onDistrictSelected);
    on<SubdistrictSelected>(_onSubdistrictSelected);
    on<NeighborhoodSelected>(_onNeighborhoodSelected);
    on<FiltersReset>(_onReset);
  }

  final FiltersRepository repository;

  Future<void> _onInitialized(
    FiltersInitialized event,
    Emitter<FiltersState> emit,
  ) async {
    emit(const FiltersLoading());

    final governoratesResult = await repository.getGovernorates();
    await governoratesResult.fold(
      (failure) async => emit(FiltersError(failure.message)),
      (governorates) async {
        const selection = GeoSelection();
        final applied = await _loadApplied(selection);

        emit(
          FiltersLoaded(
            selection: selection,
            governorates: governorates,
            districts: const [],
            subdistricts: const [],
            neighborhoods: const [],
            appliedFilter:
                applied ?? const AppliedGeoFilterModel(hasAnyFilter: false),
          ),
        );
      },
    );
  }

  Future<void> _onGovernorateSelected(
    GovernorateSelected event,
    Emitter<FiltersState> emit,
  ) async {
    final current = state;
    if (current is! FiltersLoaded) return;

    final selection = GeoSelection(governorateId: event.governorateId);
    emit(
      current.copyWith(
        selection: selection,
        districts: const [],
        subdistricts: const [],
        neighborhoods: const [],
        isRefreshingLevel: true,
        clearError: true,
      ),
    );

    if (event.governorateId == null) {
      await _emitWithApplied(
        emit,
        current.copyWith(
          selection: const GeoSelection(),
          districts: const [],
          subdistricts: const [],
          neighborhoods: const [],
          isRefreshingLevel: false,
        ),
      );
      return;
    }

    final result = await repository.getDistricts(event.governorateId!);
    await result.fold(
      (failure) async {
        emit(
          current.copyWith(
            errorMessage: failure.message,
            isRefreshingLevel: false,
          ),
        );
      },
      (districts) async {
        await _emitWithApplied(
          emit,
          current.copyWith(
            selection: selection,
            districts: districts,
            subdistricts: const [],
            neighborhoods: const [],
            isRefreshingLevel: false,
          ),
        );
      },
    );
  }

  Future<void> _onDistrictSelected(
    DistrictSelected event,
    Emitter<FiltersState> emit,
  ) async {
    final current = state;
    if (current is! FiltersLoaded) return;

    final selection = GeoSelection(
      governorateId: current.selection.governorateId,
      districtId: event.districtId,
    );

    emit(
      current.copyWith(
        selection: selection,
        subdistricts: const [],
        neighborhoods: const [],
        isRefreshingLevel: true,
        clearError: true,
      ),
    );

    if (event.districtId == null) {
      await _emitWithApplied(
        emit,
        current.copyWith(
          selection: GeoSelection(
            governorateId: current.selection.governorateId,
          ),
          subdistricts: const [],
          neighborhoods: const [],
          isRefreshingLevel: false,
        ),
      );
      return;
    }

    final result = await repository.getSubdistricts(event.districtId!);
    await result.fold(
      (failure) async {
        emit(
          current.copyWith(
            errorMessage: failure.message,
            isRefreshingLevel: false,
          ),
        );
      },
      (subdistricts) async {
        await _emitWithApplied(
          emit,
          current.copyWith(
            selection: selection,
            subdistricts: subdistricts,
            neighborhoods: const [],
            isRefreshingLevel: false,
          ),
        );
      },
    );
  }

  Future<void> _onSubdistrictSelected(
    SubdistrictSelected event,
    Emitter<FiltersState> emit,
  ) async {
    final current = state;
    if (current is! FiltersLoaded) return;

    final selection = GeoSelection(
      governorateId: current.selection.governorateId,
      districtId: current.selection.districtId,
      subdistrictId: event.subdistrictId,
    );

    emit(
      current.copyWith(
        selection: selection,
        neighborhoods: const [],
        isRefreshingLevel: true,
        clearError: true,
      ),
    );

    if (event.subdistrictId == null) {
      await _emitWithApplied(
        emit,
        current.copyWith(
          selection: GeoSelection(
            governorateId: current.selection.governorateId,
            districtId: current.selection.districtId,
          ),
          neighborhoods: const [],
          isRefreshingLevel: false,
        ),
      );
      return;
    }

    final result = await repository.getNeighborhoods(event.subdistrictId!);
    await result.fold(
      (failure) async {
        emit(
          current.copyWith(
            errorMessage: failure.message,
            isRefreshingLevel: false,
          ),
        );
      },
      (neighborhoods) async {
        await _emitWithApplied(
          emit,
          current.copyWith(
            selection: selection,
            neighborhoods: neighborhoods,
            isRefreshingLevel: false,
          ),
        );
      },
    );
  }

  Future<void> _onNeighborhoodSelected(
    NeighborhoodSelected event,
    Emitter<FiltersState> emit,
  ) async {
    final current = state;
    if (current is! FiltersLoaded) return;

    final selection = GeoSelection(
      governorateId: current.selection.governorateId,
      districtId: current.selection.districtId,
      subdistrictId: current.selection.subdistrictId,
      neighborhoodId: event.neighborhoodId,
    );

    emit(current.copyWith(isRefreshingLevel: true, clearError: true));

    await _emitWithApplied(
      emit,
      current.copyWith(
        selection: event.neighborhoodId == null
            ? GeoSelection(
                governorateId: current.selection.governorateId,
                districtId: current.selection.districtId,
                subdistrictId: current.selection.subdistrictId,
              )
            : selection,
        isRefreshingLevel: false,
      ),
    );
  }

  Future<void> _onReset(
    FiltersReset event,
    Emitter<FiltersState> emit,
  ) async {
    add(const FiltersInitialized());
  }

  Future<AppliedGeoFilterModel?> _loadApplied(GeoSelection selection) async {
    final result = await repository.getAppliedFilter(selection);
    return result.fold(
      (_) => null,
      (filter) => filter as AppliedGeoFilterModel,
    );
  }

  Future<void> _emitWithApplied(
    Emitter<FiltersState> emit,
    FiltersLoaded next,
  ) async {
    final appliedResult = await repository.getAppliedFilter(next.selection);
    appliedResult.fold(
      (failure) => emit(next.copyWith(errorMessage: failure.message)),
      (applied) => emit(
        next.copyWith(appliedFilter: applied as AppliedGeoFilterModel),
      ),
    );
  }
}
