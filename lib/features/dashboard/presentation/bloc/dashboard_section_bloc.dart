import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_section_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_section_state.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

class DashboardSectionBloc
    extends Bloc<DashboardSectionEvent, DashboardSectionState> {
  DashboardSectionBloc({required this.repository})
      : super(const DashboardSectionInitial()) {
    on<DashboardSectionLoadRequested>(_onLoad);
    on<DashboardSectionRefreshRequested>(_onRefresh);
  }

  final DashboardRepository repository;
  DashboardSectionType? _section;
  GeoSelection _selection = const GeoSelection();

  Future<void> _onLoad(
    DashboardSectionLoadRequested event,
    Emitter<DashboardSectionState> emit,
  ) async {
    _section = event.section;
    _selection = event.selection;
    emit(DashboardSectionLoading(section: event.section, selection: event.selection));

    final result = await _fetchSection(event.section, event.selection);
    result.fold(
      (failure) => emit(
        DashboardSectionError(
          message: failure.message,
          section: event.section,
          selection: event.selection,
        ),
      ),
      (data) => emit(
        DashboardSectionLoaded(
          section: event.section,
          selection: event.selection,
          data: data,
        ),
      ),
    );
  }

  Future<void> _onRefresh(
    DashboardSectionRefreshRequested event,
    Emitter<DashboardSectionState> emit,
  ) async {
    if (_section == null) return;
    add(DashboardSectionLoadRequested(section: _section!, selection: _selection));
  }

  Future<Either<Failure, Object>> _fetchSection(
    DashboardSectionType section,
    GeoSelection selection,
  ) async {
    switch (section) {
      case DashboardSectionType.properties:
        final r = await repository.getProperties(selection);
        return r.map((res) => res.data);
      case DashboardSectionType.contracts:
        final r = await repository.getContracts(selection);
        return r.map((res) => res.data);
      case DashboardSectionType.revenue:
        final r = await repository.getRevenue(selection);
        return r.map((res) => res.data);
      case DashboardSectionType.tenants:
        final r = await repository.getTenants(selection);
        return r.map((res) => res.data);
      case DashboardSectionType.investors:
        final r = await repository.getInvestors(selection);
        return r.map((res) => res.data);
      case DashboardSectionType.partners:
        final r = await repository.getPartners(selection);
        return r.map((res) => res.data);
      case DashboardSectionType.mutawallis:
        final r = await repository.getMutawallis(selection);
        return r.map((res) => res.data);
      case DashboardSectionType.modules:
        final r = await repository.getModules(selection);
        return r.map((res) => res.data);
      case DashboardSectionType.staff:
        final r = await repository.getStaffOverview();
        return r.map((res) => res.data);
    }
  }
}
