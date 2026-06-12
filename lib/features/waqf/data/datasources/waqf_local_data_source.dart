import 'package:waqf_insight/features/waqf/data/models/waqf_model.dart';

/// Contract for the Waqf local data source (cache).
abstract class WaqfLocalDataSource {
  /// Returns the last cached list of Waqfs.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<WaqfModel>> getCachedWaqfs();

  /// Caches a list of Waqfs locally.
  Future<void> cacheWaqfs(List<WaqfModel> waqfs);
}

/// Implementation using local storage (e.g., SharedPreferences, Hive).
///
/// TODO: Implement with your preferred local storage solution.
class WaqfLocalDataSourceImpl implements WaqfLocalDataSource {
  @override
  Future<List<WaqfModel>> getCachedWaqfs() async {
    // TODO: Read from local storage
    return [];
  }

  @override
  Future<void> cacheWaqfs(List<WaqfModel> waqfs) async {
    // TODO: Write to local storage
  }
}
