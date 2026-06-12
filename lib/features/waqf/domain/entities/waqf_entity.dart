import 'package:equatable/equatable.dart';

/// Waqf domain entity.
///
/// Represents the core business object for a Waqf (Islamic endowment).
/// This is a pure Dart class with no framework dependencies — it lives
/// in the domain layer and is used by use cases and the presentation layer.
class WaqfEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String location;
  final String type;
  final double area;
  final String status;
  final DateTime createdAt;

  const WaqfEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.type,
    required this.area,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        location,
        type,
        area,
        status,
        createdAt,
      ];
}
