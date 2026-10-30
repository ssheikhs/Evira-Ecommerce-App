import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// Single place for reading and writing SharedPreferences.
class PreferenceService {
  final SharedPreferences _prefs;

  PreferenceService(this._prefs);

  static Future<PreferenceService> init() async {
    return PreferenceService(await SharedPreferences.getInstance());
  }

  // Auth session
  String? getAuthToken() => _prefs.getString(StorageKeys.authToken);

  Future<void> saveAuthToken(String token) =>
      _prefs.setString(StorageKeys.authToken, token);

  Map<String, dynamic>? getUser() => _readMap(StorageKeys.authUser);

  Future<void> saveUser(Map<String, dynamic> user) =>
      _prefs.setString(StorageKeys.authUser, jsonEncode(user));

  Future<void> clearSession() async {
    await _prefs.remove(StorageKeys.authToken);
    await _prefs.remove(StorageKeys.authUser);
  }

  // Lists of JSON objects (cart items, orders)
  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> items) =>
      _prefs.setString(key, jsonEncode(items));

  // Simple values
  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Map<String, dynamic>? _readMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }
}
