import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/filters/data/models/chairman_filter_response.dart';
import 'package:waqf_insight/features/staff/data/models/staff_models.dart';

abstract class StaffRemoteDataSource {
  Future<StaffOverviewModel> getOverview();
  Future<List<StaffMemberModel>> getStaffList({String? search});
  Future<StaffDetailModel> getStaffDetail(String userId);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  StaffRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  T _unwrap<T>(dynamic raw, T Function(Object? json) fromJsonT) {
    if (raw is! Map<String, dynamic>) {
      throw const ServerException(message: 'استجابة غير متوقعة من الخادم');
    }
    final wrapper = ChairmanFilterResponse<T>.fromJson(raw, fromJsonT);
    if (!wrapper.success) {
      throw ServerException(message: wrapper.message ?? 'فشل تحميل البيانات');
    }
    if (wrapper.data == null) {
      throw const ServerException(message: 'لا توجد بيانات في الاستجابة');
    }
    return wrapper.data as T;
  }

  @override
  Future<StaffOverviewModel> getOverview() async {
    final response = await apiClient.get(AppConstants.dashboardStaffOverviewPath);
    return _unwrap(
      response.data,
      (data) => StaffOverviewModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<List<StaffMemberModel>> getStaffList({String? search}) async {
    final params = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    final response = await apiClient.get(
      AppConstants.staffListPath,
      queryParameters: params.isEmpty ? null : params,
    );
    final list = _unwrap(
      response.data,
      (data) => (data as List<dynamic>)
          .map((e) => StaffMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return list;
  }

  @override
  Future<StaffDetailModel> getStaffDetail(String userId) async {
    final encodedId = Uri.encodeComponent(userId);
    final response = await apiClient.get(AppConstants.staffDetailPath(encodedId));
    return _unwrap(
      response.data,
      (data) => StaffDetailModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
