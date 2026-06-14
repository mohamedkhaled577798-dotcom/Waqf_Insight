import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/features/activity/data/models/activity_model.dart';
import 'package:waqf_insight/features/filters/data/models/chairman_filter_response.dart';

abstract class ActivityRemoteDataSource {
  Future<List<ActivityModel>> getRecentActivity({
    int take = AppConstants.defaultPageSize,
    int skip = 0,
  });
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  ActivityRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  List<ActivityModel> _unwrapList(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const ServerException(message: 'استجابة غير متوقعة من الخادم');
    }
    final wrapper = ChairmanFilterResponse<List<ActivityModel>>.fromJson(
      raw,
      (data) => (data as List<dynamic>)
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (!wrapper.success) {
      throw ServerException(message: wrapper.message ?? 'فشل تحميل سجل العمليات');
    }
    return wrapper.data ?? [];
  }

  @override
  Future<List<ActivityModel>> getRecentActivity({
    int take = AppConstants.defaultPageSize,
    int skip = 0,
  }) async {
    final clampedTake = take.clamp(1, 200);
    final clampedSkip = skip < 0 ? 0 : skip;
    final response = await apiClient.get(
      AppConstants.activityRecentPath,
      queryParameters: {
        'take': '$clampedTake',
        'skip': '$clampedSkip',
      },
    );
    return _unwrapList(response.data);
  }
}
