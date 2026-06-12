import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/waqf/domain/entities/waqf_entity.dart';

/// States for the Waqf BLoC.
///
/// The UI reacts to these states to show loading, data, or errors.
abstract class WaqfState extends Equatable {
  const WaqfState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class WaqfInitial extends WaqfState {
  const WaqfInitial();
}

/// Loading state — show a progress indicator.
class WaqfLoading extends WaqfState {
  const WaqfLoading();
}

/// Success state with a list of Waqf items.
class WaqfLoaded extends WaqfState {
  final List<WaqfEntity> waqfs;

  const WaqfLoaded({required this.waqfs});

  @override
  List<Object?> get props => [waqfs];
}

/// Success state with a single Waqf detail.
class WaqfDetailLoaded extends WaqfState {
  final WaqfEntity waqf;

  const WaqfDetailLoaded({required this.waqf});

  @override
  List<Object?> get props => [waqf];
}

/// Error state — show error message with optional retry.
class WaqfError extends WaqfState {
  final String message;

  const WaqfError({required this.message});

  @override
  List<Object?> get props => [message];
}
