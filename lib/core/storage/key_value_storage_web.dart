import 'package:web/web.dart' as web;

import 'package:waqf_insight/core/storage/key_value_storage.dart';

Future<KeyValueStorage> createKeyValueStorage() async {
  return _WebLocalStorage();
}

class _WebLocalStorage implements KeyValueStorage {
  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async =>
      web.window.localStorage.getItem(key);

  @override
  Future<void> write(String key, String value) async {
    web.window.localStorage.setItem(key, value);
  }

  @override
  Future<void> delete(String key) async {
    web.window.localStorage.removeItem(key);
  }
}
