import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/storage/key_value_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  final KeyValueStorage _storage;

  Future<void> _loadSavedTheme() async {
    final saved = await _storage.read(AppConstants.themeKey);
    if (saved == 'dark') {
      emit(ThemeMode.dark);
    } else if (saved == 'light') {
      emit(ThemeMode.light);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await _storage.write(
      AppConstants.themeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> toggleTheme() async {
    await setTheme(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDark => state == ThemeMode.dark;
}
