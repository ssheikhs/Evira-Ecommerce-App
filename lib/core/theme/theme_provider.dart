import 'package:flutter/material.dart';

import '../constants/storage_keys.dart';
import '../storage/preference_service.dart';

/// Remembers whether the user picked light, dark or system theme.
class ThemeProvider extends ChangeNotifier {
  final PreferenceService preferenceService;
  ThemeMode _themeMode;

  ThemeProvider({required this.preferenceService})
    : _themeMode = _parse(preferenceService.getString(StorageKeys.themeMode));

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await preferenceService.setString(StorageKeys.themeMode, mode.name);
  }

  static ThemeMode _parse(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
