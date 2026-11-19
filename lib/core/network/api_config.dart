/// @title ApiConfig
/// @notice Where the Kosply backend lives and how long calls may take.
/// @dev Values come from the bundled `.env` file, loaded by {ApiConfig.load}
/// before the first request. A `--dart-define` of the same name still wins,
/// so one run can point elsewhere without editing the file. The fallback
/// origin is the Android emulator's alias for the host's dev server.
/// @author Kosply-mobile
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// @title ApiConfig
/// @notice Backend origin and call budgets for this build.
abstract final class ApiConfig {
  static const String _asset = '.env';
  static const String _definedBaseUrl = String.fromEnvironment('KOSPLY_API_URL');
  static const String _definedGoogleClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const String _fallbackBaseUrl = 'http://10.0.2.2:3500';

  /// @dev Backend origin without a trailing slash.
  static String baseUrl = _definedBaseUrl.isEmpty
      ? _fallbackBaseUrl
      : _definedBaseUrl;

  /// @dev Budget for an ordinary JSON call.
  static const Duration timeout = Duration(seconds: 20);

  /// @dev Budget for an AI turn. The server waits up to 180 s for the agent,
  /// and a listing turn reads every side photo before it answers.
  static const Duration aiTimeout = Duration(seconds: 190);

  /// @dev Budget for one image upload over a phone connection.
  static const Duration uploadTimeout = Duration(seconds: 60);

  /// @dev Web OAuth client id the backend verifies Google id tokens against.
  /// Empty disables the Google button with an explanation instead of a crash.
  static String googleServerClientId = _definedGoogleClientId;

  /// @notice Reads `.env` from the app bundle into {baseUrl} and
  /// {googleServerClientId}.
  /// @dev A compile-time define is left alone. A missing asset keeps the
  /// fallback, which is what widget tests use.
  /// @return Future completing when the file has been applied or skipped.
  static Future<void> load() async {
    try {
      apply(await rootBundle.loadString(_asset));
    } on FlutterError {
      // The bundle has no `.env`. Keep the fallback or the dart-define.
    }
  }

  /// @notice Applies `KEY=value` lines from [text].
  /// @dev Blank lines and `#` comments are ignored. Surrounding quotes are
  /// removed. A trailing slash on the API origin is dropped.
  /// @param text Raw env file contents.
  /// @return void
  static void apply(String text) {
    final Map<String, String> values = parseEnv(text);
    if (_definedBaseUrl.isEmpty && values['KOSPLY_API_URL'] != null) {
      baseUrl = _origin(values['KOSPLY_API_URL']!);
    }
    if (_definedGoogleClientId.isEmpty &&
        values['GOOGLE_SERVER_CLIENT_ID'] != null) {
      googleServerClientId = values['GOOGLE_SERVER_CLIENT_ID']!;
    }
  }

  static String _origin(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}

/// @notice Parses a dotenv file into a key map.
/// @param text Raw file contents.
/// @return Keys that had a value. Empty values are omitted.
Map<String, String> parseEnv(String text) {
  final Map<String, String> values = <String, String>{};
  for (final String rawLine in text.split('\n')) {
    final String line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }
    final int split = line.indexOf('=');
    if (split <= 0) {
      continue;
    }
    final String key = line.substring(0, split).trim();
    String value = line.substring(split + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }
    if (key.isEmpty || value.isEmpty) {
      continue;
    }
    values[key] = value;
  }
  return values;
}
