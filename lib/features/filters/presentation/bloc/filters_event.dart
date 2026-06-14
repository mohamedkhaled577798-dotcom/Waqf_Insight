import 'package:equatable/equatable.dart';

abstract class FiltersEvent extends Equatable {
  const FiltersEvent();

  @override
  List<Object?> get props => [];
}

class FiltersInitialized extends FiltersEvent {
  const FiltersInitialized();
}

class GovernorateSelected extends FiltersEvent {
  const GovernorateSelected(this.governorateId);

  final String? governorateId;

  @override
  List<Object?> get props => [governorateId];
}

class DistrictSelected extends FiltersEvent {
  const DistrictSelected(this.districtId);

  final String? districtId;

  @override
  List<Object?> get props => [districtId];
}

class SubdistrictSelected extends FiltersEvent {
  const SubdistrictSelected(this.subdistrictId);

  final String? subdistrictId;

  @override
  List<Object?> get props => [subdistrictId];
}

class NeighborhoodSelected extends FiltersEvent {
  const NeighborhoodSelected(this.neighborhoodId);

  final String? neighborhoodId;

  @override
  List<Object?> get props => [neighborhoodId];
}

class FiltersReset extends FiltersEvent {
  const FiltersReset();
}
