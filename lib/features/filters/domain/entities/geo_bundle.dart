import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_option.dart';

class GeoBundle extends Equatable {
  const GeoBundle({
    required this.governorates,
    required this.districts,
    required this.subdistricts,
    required this.neighborhoods,
  });

  final List<GeoOption> governorates;
  final List<GeoOption> districts;
  final List<GeoOption> subdistricts;
  final List<GeoOption> neighborhoods;

  @override
  List<Object?> get props =>
      [governorates, districts, subdistricts, neighborhoods];
}
