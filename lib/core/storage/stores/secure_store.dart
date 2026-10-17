/// @title SecureStore
/// @notice Secret storage backed by FlutterSecureStorage.
/// @dev Only tokens and credentials belong here. Reads degrade to null and
/// writes become no-ops when the platform keystore is unavailable, so widget
/// tests and unsupported platforms keep working.
/// @author Kosply-mobile
library;

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// @title SecureStore
/// @notice Typed wrapper around {FlutterSecureStorage}.
class SecureStore {
  /// @notice Creates a keystore-backed store.
  /// @return A new {SecureStore} instance.
  SecureStore()
      : _storage = const FlutterSecureStorage(),
        _memory = null;

  /// @notice Creates a store that only lives in memory.
  /// @dev Used by tests and as the safe default provider value.
  /// @return A new {SecureStore} instance.
  SecureStore.memory() : _storage = null, _memory = <String, String>{};

  final FlutterSecureStorage? _storage;
  final Map<String, String>? _memory;

  /// @notice Reads a secret.
  /// @param key Key from {StorageKeys}.
  /// @return The stored value, or null when unset or unavailable.
  Future<String?> read(String key) async {
    final Map<String, String>? memory = _memory;
    if (memory != null) {
      return memory[key];
    }
    try {
      return await _storage!.read(key: key);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// @notice Writes a secret.
  /// @param key Key from {StorageKeys}.
  /// @param value Secret to persist.
  /// @return Future completing when the write is durable.
  Future<void> write(String key, String value) async {
    final Map<String, String>? memory = _memory;
    if (memory != null) {
      memory[key] = value;
      return;
    }
    try {
      await _storage!.write(key: key, value: value);
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  /// @notice Removes a secret.
  /// @param key Key from {StorageKeys}.
  /// @return Future completing when the removal is durable.
  Future<void> delete(String key) async {
    final Map<String, String>? memory = _memory;
    if (memory != null) {
      memory.remove(key);
      return;
    }
    try {
      await _storage!.delete(key: key);
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
