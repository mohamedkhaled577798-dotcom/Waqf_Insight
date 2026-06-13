import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqf_insight/core/storage/key_value_storage.dart';

Future<KeyValueStorage> createKeyValueStorage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return _SharedPreferencesStorage(prefs);
  } on MissingPluginException {
    return _InMemoryStorage();
  } on PlatformException {
    return _InMemoryStorage();
  }
}

class _SharedPreferencesStorage implements KeyValueStorage {
  _SharedPreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }
}

class _InMemoryStorage implements KeyValueStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }
}
