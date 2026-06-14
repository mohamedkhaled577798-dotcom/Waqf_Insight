import 'package:equatable/equatable.dart';

class GeoOption extends Equatable {
  const GeoOption({
    required this.id,
    required this.name,
    this.code,
    this.parentId,
    this.propertiesCount = 0,
  });

  final String id;
  final String name;
  final String? code;
  final String? parentId;
  final int propertiesCount;

  String get displayLabel =>
      propertiesCount > 0 ? '$name ($propertiesCount)' : name;

  @override
  List<Object?> get props => [id, name, code, parentId, propertiesCount];
}
