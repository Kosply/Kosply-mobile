/// @title API providers
/// @notice The app-wide backend client and its transport.
/// @dev Widget tests override {httpClientProvider} with an in-memory backend,
/// so every repository runs its real HTTP and mapping code against fixtures.
/// The client reads the session lazily through {ApiTokens}, which keeps the
/// session notifier (which itself calls the auth API) out of a provider cycle.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../account/session_provider.dart';

/// @dev Raw HTTP transport. Overridden with a mock backend in tests.
final httpClientProvider = Provider<http.Client>((ref) {
  final http.Client client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// @dev Backend origin. Overridable for staging or tests.
final apiBaseUrlProvider = Provider<String>((ref) => ApiConfig.baseUrl);

/// @title _SessionTokens
/// @notice {ApiTokens} backed by the session notifier.
class _SessionTokens implements ApiTokens {
  _SessionTokens(this._ref);

  final Ref _ref;

  @override
  String? get accessToken => _ref.read(sessionProvider)?.accessToken;

  @override
  Future<bool> refresh() => _ref.read(sessionProvider.notifier).refreshTokens();
}

/// @dev The one client every repository calls the backend through.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    transport: ref.watch(httpClientProvider),
    baseUrl: ref.watch(apiBaseUrlProvider),
    tokens: _SessionTokens(ref),
  ),
);
