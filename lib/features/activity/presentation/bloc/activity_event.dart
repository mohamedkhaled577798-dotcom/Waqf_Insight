import 'package:equatable/equatable.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

class ActivityLoadRequested extends ActivityEvent {
  const ActivityLoadRequested();
}

class ActivityRefreshRequested extends ActivityEvent {
  const ActivityRefreshRequested();
}

class ActivityLoadMoreRequested extends ActivityEvent {
  const ActivityLoadMoreRequested();
}

class ActivityModuleFilterChanged extends ActivityEvent {
  const ActivityModuleFilterChanged(this.module);

  final String? module;

  @override
  List<Object?> get props => [module];
}
