import 'package:waqf_insight/features/filters/data/models/applied_geo_filter_model.dart';

class ChairmanFilterResponse<T> {
  const ChairmanFilterResponse({
    required this.success,
    this.message,
    this.filter,
    this.data,
  });

  final bool success;
  final String? message;
  final AppliedGeoFilterModel? filter;
  final T? data;

  factory ChairmanFilterResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ChairmanFilterResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      filter: json['filter'] != null
          ? AppliedGeoFilterModel.fromJson(
              json['filter'] as Map<String, dynamic>,
            )
          : null,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
