/// @title PreferencesStore
/// @notice Small, non-sensitive app settings backed by SharedPreferences.
/// @dev Used for values such as theme mode, account mode and notification
/// flags. Never store tokens or credentials here; use {SecureStore} instead.
/// @author Kosply-mobile
library;

import 'package:shared_preferences/shared_preferences.dart';

/// @title PreferencesStore
/// @notice Typed wrapper around {SharedPreferences}.
/// @dev Falls back to an in-memory map when the platform plugin is missing
/// (for example in widget tests) so callers never have to special-case it.
class PreferencesStore {
  PreferencesStore._(this._prefs) : _memory = null;

  /// @notice Creates a store that only lives in memory.
  /// @dev Used by tests and as the safe default provider value.
  /// @return A new {PreferencesStore} instance.
  PreferencesStore.memory() : _prefs = null, _memory = <String, Object>{};

  final SharedPreferences? _prefs;
  final Map<String, Object>? _memory;

  /// @notice Opens the platform-backed preferences.
  /// @dev Degrades to {PreferencesStore.memory} when the plugin cannot load.
  /// @return The opened store.
  static Future<PreferencesStore> open() async {
    try {
      return PreferencesStore._(await SharedPreferences.getInstance());
    } catch (_) {
      return PreferencesStore.memory();
    }
  }

  /// @notice Reads a stored boolean.
  /// @param key Key from {StorageKeys}.
  /// @return The stored value, or null when unset.
  bool? readBool(String key) {
    final SharedPreferences? prefs = _prefs;
    if (prefs != null) {
      return prefs.getBool(key);
    }
    return _memory![key] as bool?;
  }

  /// @notice Reads a stored string.
  /// @param key Key from {StorageKeys}.
  /// @return The stored value, or null when unset.
  String? readString(String key) {
    final SharedPreferences? prefs = _prefs;
    if (prefs != null) {
      return prefs.getString(key);
    }
    return _memory![key] as String?;
  }

  /// @notice Reads a stored integer.
  /// @param key Key from {StorageKeys}.
  /// @return The stored value, or null when unset.
  int? readInt(String key) {
    final SharedPreferences? prefs = _prefs;
    if (prefs != null) {
      return prefs.getInt(key);
    }
    return _memory![key] as int?;
  }

  /// @notice Writes a boolean.
  /// @param key Key from {StorageKeys}.
  /// @param value Value to persist.
  /// @return Future completing when the write is durable.
  Future<void> writeBool(String key, bool value) async {
    final SharedPreferences? prefs = _prefs;
    if (prefs != null) {
      await prefs.setBool(key, value);
      return;
    }
    _memory![key] = value;
  }

  /// @notice Writes a string.
  /// @param key Key from {StorageKeys}.
  /// @param value Value to persist.
  /// @return Future completing when the write is durable.
  Future<void> writeString(String key, String value) async {
    final SharedPreferences? prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(key, value);
      return;
    }
    _memory![key] = value;
  }

  /// @notice Writes an integer.
  /// @param key Key from {StorageKeys}.
  /// @param value Value to persist.
  /// @return Future completing when the write is durable.
  Future<void> writeInt(String key, int value) async {
    final SharedPreferences? prefs = _prefs;
    if (prefs != null) {
      await prefs.setInt(key, value);
      return;
    }
    _memory![key] = value;
  }

  /// @notice Removes a stored value.
  /// @param key Key from {StorageKeys}.
  /// @return Future completing when the removal is durable.
  Future<void> remove(String key) async {
    final SharedPreferences? prefs = _prefs;
    if (prefs != null) {
      await prefs.remove(key);
      return;
    }
    _memory!.remove(key);
  }
}
