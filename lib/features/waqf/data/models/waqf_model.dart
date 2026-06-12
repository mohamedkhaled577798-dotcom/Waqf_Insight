import 'package:waqf_insight/features/waqf/domain/entities/waqf_entity.dart';

/// Data model for Waqf, extending the domain entity.
///
/// Adds JSON serialization/deserialization capabilities.
/// The domain layer never knows about JSON — only the data layer does.
class WaqfModel extends WaqfEntity {
  const WaqfModel({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    required super.type,
    required super.area,
    required super.status,
    required super.createdAt,
  });

  /// Creates a [WaqfModel] from a JSON map (API response).
  factory WaqfModel.fromJson(Map<String, dynamic> json) {
    return WaqfModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      area: (json['area'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this model to a JSON map (for API requests or caching).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'type': type,
      'area': area,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
