/// @title JSON readers
/// @notice Tolerant field access for backend JSON.
/// @dev MariaDB rows reach the app with nullable columns as `null`, booleans
/// sometimes as `0`/`1`, timestamps as ISO strings, and JSON columns either
/// decoded or still as text. These readers absorb that so mapping code stays
/// one line per field and a missing key never throws.
/// @author Kosply-mobile
library;

import 'dart:convert';

/// @title JsonRead
/// @notice Typed getters with safe defaults on a decoded JSON object.
extension JsonRead on Map<String, dynamic> {
  /// @notice Reads a string, empty when absent or null.
  /// @param key Field name.
  /// @return The string value.
  String str(String key) {
    final Object? value = this[key];
    return value == null ? '' : value.toString();
  }

  /// @notice Reads an integer, 0 when absent or not numeric.
  /// @param key Field name.
  /// @return The integer value.
  int integer(String key) {
    final Object? value = this[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// @notice Reads a double, 0 when absent or null.
  /// @param key Field name.
  /// @return The double value.
  double real(String key) {
    final Object? value = this[key];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// @notice Reads a boolean, accepting `true`/`1`.
  /// @param key Field name.
  /// @return The boolean value.
  bool flag(String key) {
    final Object? value = this[key];
    return value == true || value == 1 || value == '1' || value == 'true';
  }

  /// @notice Reads a nested object.
  /// @param key Field name.
  /// @return The object, or null when absent or not an object.
  Map<String, dynamic>? object(String key) {
    final Object? value = this[key];
    return value is Map<String, dynamic> ? value : null;
  }

  /// @notice Reads a list of objects, skipping anything else.
  /// @param key Field name.
  /// @return The objects in order.
  List<Map<String, dynamic>> objects(String key) {
    final Object? value = this[key];
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }
    return <Map<String, dynamic>>[
      for (final Object? item in value)
        if (item is Map<String, dynamic>) item,
    ];
  }

  /// @notice Reads a list of non-empty strings.
  /// @dev Also accepts a JSON-encoded string, the shape a JSON column takes
  /// when the driver does not decode it.
  /// @param key Field name.
  /// @return The strings in order.
  List<String> strings(String key) {
    Object? value = this[key];
    if (value is String && value.trim().startsWith('[')) {
      try {
        value = jsonDecode(value);
      } on FormatException {
        return const <String>[];
      }
    }
    if (value is! List) {
      return const <String>[];
    }
    return <String>[
      for (final Object? item in value)
        if (item is String && item.isNotEmpty) item,
    ];
  }

  /// @notice Reads an ISO timestamp as UTC milliseconds.
  /// @param key Field name.
  /// @return Milliseconds since epoch, 0 when absent or unparsable.
  int millis(String key) {
    final Object? value = this[key];
    if (value is int) {
      return value;
    }
    final DateTime? parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed?.toUtc().millisecondsSinceEpoch ?? 0;
  }
}
