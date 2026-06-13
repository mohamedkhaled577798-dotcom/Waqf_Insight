/// Platform-agnostic key-value persistence for auth session data.
abstract class KeyValueStorage {
  Future<void> init();
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}
