import 'package:equatable/equatable.dart';

/// Events for the Waqf BLoC.
///
/// Each event represents a user action or system trigger.
/// BLoC receives events and emits corresponding states.
abstract class WaqfEvent extends Equatable {
  const WaqfEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the waqf list page is opened.
class GetAllWaqfsEvent extends WaqfEvent {
  const GetAllWaqfsEvent();
}

/// Triggered when a specific waqf is selected for details.
class GetWaqfByIdEvent extends WaqfEvent {
  final String id;

  const GetWaqfByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Triggered when the user pulls to refresh.
class RefreshWaqfsEvent extends WaqfEvent {
  const RefreshWaqfsEvent();
}
