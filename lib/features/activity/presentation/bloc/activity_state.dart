import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/activity/data/models/activity_model.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {
  const ActivityInitial();
}

class ActivityLoading extends ActivityState {
  const ActivityLoading();
}

class ActivityLoaded extends ActivityState {
  const ActivityLoaded({
    required this.allItems,
    required this.filteredItems,
    required this.hasMore,
    required this.pageSize,
    this.selectedModule,
    this.isLoadingMore = false,
  });

  final List<ActivityModel> allItems;
  final List<ActivityModel> filteredItems;
  final bool hasMore;
  final int pageSize;
  final String? selectedModule;
  final bool isLoadingMore;

  @override
  List<Object?> get props => [
        allItems,
        filteredItems,
        hasMore,
        pageSize,
        selectedModule,
        isLoadingMore,
      ];
}

class ActivityError extends ActivityState {
  const ActivityError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
