import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/features/waqf/data/models/waqf_model.dart';

/// Contract for the Waqf remote data source.
abstract class WaqfRemoteDataSource {
  /// Fetches all Waqfs from the API.
  ///
  /// Throws [ServerException] on failure.
  Future<List<WaqfModel>> getAllWaqfs();

  /// Fetches a single Waqf by [id] from the API.
  ///
  /// Throws [ServerException] on failure.
  Future<WaqfModel> getWaqfById(String id);
}

/// Implementation of [WaqfRemoteDataSource] using [ApiClient].
class WaqfRemoteDataSourceImpl implements WaqfRemoteDataSource {
  final ApiClient apiClient;

  WaqfRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<WaqfModel>> getAllWaqfs() async {
    try {
      final response = await apiClient.get('/waqfs');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data
          .map((json) => WaqfModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WaqfModel> getWaqfById(String id) async {
    try {
      final response = await apiClient.get('/waqfs/$id');
      return WaqfModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
