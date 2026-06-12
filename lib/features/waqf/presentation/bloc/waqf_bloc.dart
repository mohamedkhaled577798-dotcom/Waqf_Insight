import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/core/usecases/usecase.dart';
import 'package:waqf_insight/features/waqf/domain/usecases/get_all_waqfs.dart';
import 'package:waqf_insight/features/waqf/domain/usecases/get_waqf_by_id.dart';
import 'package:waqf_insight/features/waqf/presentation/bloc/waqf_event.dart';
import 'package:waqf_insight/features/waqf/presentation/bloc/waqf_state.dart';

/// BLoC for the Waqf feature.
///
/// Receives [WaqfEvent]s, calls the appropriate use case,
/// and emits [WaqfState]s for the UI to react to.
class WaqfBloc extends Bloc<WaqfEvent, WaqfState> {
  final GetAllWaqfs getAllWaqfs;
  final GetWaqfById getWaqfById;

  WaqfBloc({
    required this.getAllWaqfs,
    required this.getWaqfById,
  }) : super(const WaqfInitial()) {
    on<GetAllWaqfsEvent>(_onGetAllWaqfs);
    on<GetWaqfByIdEvent>(_onGetWaqfById);
    on<RefreshWaqfsEvent>(_onRefreshWaqfs);
  }

  Future<void> _onGetAllWaqfs(
    GetAllWaqfsEvent event,
    Emitter<WaqfState> emit,
  ) async {
    emit(const WaqfLoading());

    final result = await getAllWaqfs(const NoParams());

    result.fold(
      (failure) => emit(WaqfError(message: failure.message)),
      (waqfs) => emit(WaqfLoaded(waqfs: waqfs)),
    );
  }

  Future<void> _onGetWaqfById(
    GetWaqfByIdEvent event,
    Emitter<WaqfState> emit,
  ) async {
    emit(const WaqfLoading());

    final result = await getWaqfById(WaqfByIdParams(id: event.id));

    result.fold(
      (failure) => emit(WaqfError(message: failure.message)),
      (waqf) => emit(WaqfDetailLoaded(waqf: waqf)),
    );
  }

  Future<void> _onRefreshWaqfs(
    RefreshWaqfsEvent event,
    Emitter<WaqfState> emit,
  ) async {
    final result = await getAllWaqfs(const NoParams());

    result.fold(
      (failure) => emit(WaqfError(message: failure.message)),
      (waqfs) => emit(WaqfLoaded(waqfs: waqfs)),
    );
  }
}
