import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/features/filters/data/models/applied_geo_filter_model.dart';
import 'package:waqf_insight/features/filters/data/models/chairman_filter_response.dart';
import 'package:waqf_insight/features/filters/data/models/geo_bundle_model.dart';
import 'package:waqf_insight/features/filters/data/models/geo_option_model.dart';
import 'package:waqf_insight/features/filters/domain/entities/applied_geo_filter.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_bundle.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_option.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class FiltersRemoteDataSource {
  Future<List<GeoOption>> getGovernorates();
  Future<List<GeoOption>> getDistricts(String governorateId);
  Future<List<GeoOption>> getSubdistricts(String districtId);
  Future<List<GeoOption>> getNeighborhoods(String subdistrictId);
  Future<GeoBundle> getGeo(GeoSelection selection);
  Future<AppliedGeoFilter> getAppliedFilter(GeoSelection selection);
}

class FiltersRemoteDataSourceImpl implements FiltersRemoteDataSource {
  FiltersRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  T _unwrap<T>(
    dynamic raw,
    T Function(Object? json) fromJsonT,
  ) {
    if (raw is! Map<String, dynamic>) {
      throw const ServerException(message: 'استجابة غير متوقعة من الخادم');
    }

    final wrapper = ChairmanFilterResponse<T>.fromJson(raw, fromJsonT);
    if (!wrapper.success) {
      throw ServerException(
        message: wrapper.message ?? 'فشل تحميل الفلاتر',
      );
    }

    if (wrapper.data == null) {
      throw const ServerException(message: 'لا توجد بيانات في الاستجابة');
    }

    return wrapper.data as T;
  }

  List<GeoOption> _parseOptions(dynamic raw) {
    return _unwrap<List<GeoOption>>(
      raw,
      (data) => (data as List<dynamic>)
          .map((e) => GeoOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<List<GeoOption>> getGovernorates() async {
    final response = await apiClient.get(AppConstants.filtersGovernoratesPath);
    return _parseOptions(response.data);
  }

  @override
  Future<List<GeoOption>> getDistricts(String governorateId) async {
    final response = await apiClient.get(
      AppConstants.filtersDistrictsPath,
      queryParameters: {'governorateId': governorateId},
    );
    return _parseOptions(response.data);
  }

  @override
  Future<List<GeoOption>> getSubdistricts(String districtId) async {
    final response = await apiClient.get(
      AppConstants.filtersSubdistrictsPath,
      queryParameters: {'districtId': districtId},
    );
    return _parseOptions(response.data);
  }

  @override
  Future<List<GeoOption>> getNeighborhoods(String subdistrictId) async {
    final response = await apiClient.get(
      AppConstants.filtersNeighborhoodsPath,
      queryParameters: {'subdistrictId': subdistrictId},
    );
    return _parseOptions(response.data);
  }

  @override
  Future<GeoBundle> getGeo(GeoSelection selection) async {
    final response = await apiClient.get(
      AppConstants.filtersGeoPath,
      queryParameters: selection.toQueryParams(),
    );

    return _unwrap<GeoBundle>(
      response.data,
      (data) => GeoBundleModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<AppliedGeoFilter> getAppliedFilter(GeoSelection selection) async {
    final response = await apiClient.get(
      AppConstants.filtersAppliedPath,
      queryParameters: selection.toQueryParams(),
    );

    return _unwrap<AppliedGeoFilter>(
      response.data,
      (data) => AppliedGeoFilterModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
