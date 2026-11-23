/// @title ApiClient
/// @notice One HTTP client for every call the app makes to the backend.
/// @dev Owns the envelope (`{status: ok, ...}` in, {ApiException} out), the
/// bearer header, and the one retry after a silent token refresh. Screens and
/// repositories never touch `package:http` directly, so tests swap the whole
/// network for an in-memory backend by overriding one provider.
/// @author Kosply-mobile
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'sse.dart';

/// @title ApiTokens
/// @notice Where the client reads and renews the access token.
/// @dev Implemented by the session layer, so the client never imports it.
abstract interface class ApiTokens {
  /// @notice The current access token, null when signed out.
  String? get accessToken;

  /// @notice Exchanges the refresh token for a new access token.
  /// @return True when a fresh access token is now available.
  Future<bool> refresh();
}

/// @title ApiClient
/// @notice JSON over HTTP with auth, refresh-and-retry, and error mapping.
class ApiClient {
  /// @notice Creates the client.
  /// @param transport HTTP transport, replaced by a mock in tests.
  /// @param baseUrl Backend origin without a trailing slash.
  /// @param tokens Session token source; null for anonymous-only use.
  /// @return A new {ApiClient} instance.
  ApiClient({
    required this._transport,
    required this.baseUrl,
    this.tokens,
  });

  final http.Client _transport;

  /// @dev Backend origin without a trailing slash.
  final String baseUrl;

  /// @dev Session token source; null for anonymous-only use.
  final ApiTokens? tokens;

  /// @notice Sends a GET.
  /// @param path Path starting with `/api`.
  /// @param query Optional query parameters; empty values are dropped.
  /// @param auth Whether to attach the bearer token.
  /// @return The decoded response body.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
    Duration? timeout,
  }) {
    return _send('GET', path, query: query, auth: auth, timeout: timeout);
  }

  /// @notice Sends a POST with a JSON body.
  /// @param path Path starting with `/api`.
  /// @param body JSON-encodable body.
  /// @param auth Whether to attach the bearer token.
  /// @param timeout Optional budget overriding {ApiConfig.timeout}.
  /// @return The decoded response body.
  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    Duration? timeout,
  }) {
    return _send(
      'POST',
      path,
      body: body,
      query: query,
      auth: auth,
      timeout: timeout,
    );
  }

  /// @notice Opens an SSE response and yields its frames.
  /// @dev Used by chat (`GET /conversations/:id/stream`) and AI
  /// (`POST /ai/chat/stream`). A non-2xx body is an {ApiException}, same as
  /// the JSON methods. One silent refresh is attempted on 401.
  /// @param method HTTP verb.
  /// @param path Path starting with `/api`.
  /// @param body JSON body for POST streams.
  /// @param query Query parameters.
  /// @param auth Whether to attach the bearer token.
  /// @param timeout Budget for the whole stream.
  /// @return Frames in arrival order.
  Stream<SseEvent> openSse(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    Duration? timeout,
  }) async* {
    final Duration budget = timeout ?? ApiConfig.timeout;
    final String? token = auth ? tokens?.accessToken : null;
    http.StreamedResponse streamed = await _open(
      method,
      path,
      body: body,
      query: query,
      token: token,
      timeout: budget,
    );
    if (streamed.statusCode == 401 && token != null) {
      await streamed.stream.drain<void>();
      final ApiTokens? source = tokens;
      if (source != null && await source.refresh()) {
        streamed = await _open(
          method,
          path,
          body: body,
          query: query,
          token: source.accessToken,
          timeout: budget,
        );
      }
    }
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      final String text = await streamed.stream.bytesToString();
      throw _errorFrom(streamed.statusCode, text);
    }
    // Idle timeout lives on an async controller. A synchronous timeout
    // pauses the parser while the first frame is painted, and thinking,
    // tokens, interrupt, and done after that frame never arrive.
    yield* _idleSse(parseSse(streamed.stream), budget);
  }

  /// @notice Forwards SSE frames and ends the stream when it goes quiet.
  /// @dev The source keeps being read while the listener paints, so a
  /// multi-frame turn is delivered whole. The timer is cancelled when the
  /// server closes the stream or the listener cancels.
  /// @param source Parsed frames.
  /// @param budget Idle time allowed between frames.
  /// @return The same frames, or a network error once [budget] passes in silence.
  Stream<SseEvent> _idleSse(Stream<SseEvent> source, Duration budget) {
    late final StreamController<SseEvent> controller;
    StreamSubscription<SseEvent>? subscription;
    Timer? timer;
    var stopped = false;

    void stopTimer() {
      timer?.cancel();
      timer = null;
    }

    void arm() {
      stopTimer();
      timer = Timer(budget, () {
        if (stopped || controller.isClosed) {
          return;
        }
        stopped = true;
        stopTimer();
        controller.addError(
          const ApiException(
            statusCode: 0,
            code: ApiException.network,
            message: 'timeout',
          ),
        );
        controller.close();
        subscription?.cancel();
      });
    }

    controller = StreamController<SseEvent>(
      onListen: () {
        arm();
        subscription = source.listen(
          (SseEvent event) {
            if (stopped || controller.isClosed) {
              return;
            }
            arm();
            controller.add(event);
          },
          onError: (Object error, StackTrace stackTrace) {
            if (stopped || controller.isClosed) {
              return;
            }
            stopped = true;
            stopTimer();
            controller.addError(error, stackTrace);
            controller.close();
          },
          onDone: () {
            if (stopped || controller.isClosed) {
              return;
            }
            stopped = true;
            stopTimer();
            controller.close();
          },
        );
      },
      onCancel: () {
        stopped = true;
        stopTimer();
        final StreamSubscription<SseEvent>? current = subscription;
        subscription = null;
        if (current == null) {
          return null;
        }
        // Cancel after this event returns. Awaiting cancel from inside the
        // event that is being cancelled never completes.
        scheduleMicrotask(() {
          current.cancel();
        });
        return null;
      },
    );
    return controller.stream;
  }

  /// @notice Sends a PUT with an optional JSON body.
  /// @param path Path starting with `/api`.
  /// @param body JSON-encodable body.
  /// @return The decoded response body.
  Future<Map<String, dynamic>> put(String path, {Object? body}) {
    return _send('PUT', path, body: body);
  }

  /// @notice Sends a PATCH with a JSON body.
  /// @param path Path starting with `/api`.
  /// @param body JSON-encodable body.
  /// @return The decoded response body.
  Future<Map<String, dynamic>> patch(String path, {Object? body}) {
    return _send('PATCH', path, body: body);
  }

  /// @notice Sends a DELETE.
  /// @param path Path starting with `/api`.
  /// @return The decoded response body.
  Future<Map<String, dynamic>> delete(String path) {
    return _send('DELETE', path);
  }

  /// @notice Uploads raw bytes, e.g. one photo to `/api/uploads/images`.
  /// @param path Path starting with `/api`.
  /// @param bytes File content.
  /// @param contentType Media type, e.g. `image/jpeg`.
  /// @return The decoded response body.
  Future<Map<String, dynamic>> postBytes(
    String path,
    Uint8List bytes,
    String contentType,
  ) {
    return _send(
      'POST',
      path,
      bytes: bytes,
      contentType: contentType,
      timeout: ApiConfig.uploadTimeout,
    );
  }

  /// @notice Builds an absolute URI for [path].
  /// @param path Path starting with `/`.
  /// @param query Optional query parameters; empty values are dropped.
  /// @return The URI.
  Uri uri(String path, [Map<String, String>? query]) {
    final Map<String, String> params = <String, String>{
      for (final MapEntry<String, String> entry
          in (query ?? const <String, String>{}).entries)
        if (entry.value.isNotEmpty) entry.key: entry.value,
    };
    return Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: params.isEmpty ? null : params);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    Uint8List? bytes,
    String? contentType,
    bool auth = true,
    Duration? timeout,
  }) async {
    final String? token = auth ? tokens?.accessToken : null;
    http.Response response = await _request(
      method,
      path,
      query: query,
      body: body,
      bytes: bytes,
      contentType: contentType,
      token: token,
      timeout: timeout,
    );
    // An expired access token is renewed once, silently; a second 401 means
    // the session itself is gone and surfaces to the caller.
    if (response.statusCode == 401 && token != null) {
      final ApiTokens? source = tokens;
      if (source != null && await source.refresh()) {
        response = await _request(
          method,
          path,
          query: query,
          body: body,
          bytes: bytes,
          contentType: contentType,
          token: source.accessToken,
          timeout: timeout,
        );
      }
    }
    return _decode(response);
  }

  Future<http.StreamedResponse> _open(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    String? token,
    required Duration timeout,
  }) async {
    final http.Request request = http.Request(method, uri(path, query));
    request.headers['accept'] = 'text/event-stream';
    if (token != null && token.isNotEmpty) {
      request.headers['authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.headers['content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    try {
      return await _transport.send(request).timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        statusCode: 0,
        code: ApiException.network,
        message: 'timeout',
      );
    } on SocketException catch (error) {
      throw ApiException(
        statusCode: 0,
        code: ApiException.network,
        message: error.message,
      );
    } on http.ClientException catch (error) {
      throw ApiException(
        statusCode: 0,
        code: ApiException.network,
        message: error.message,
      );
    }
  }

  ApiException _errorFrom(int statusCode, String text) {
    Object? decoded;
    try {
      decoded = text.isEmpty ? null : jsonDecode(text);
    } on FormatException {
      decoded = null;
    }
    final Map<String, dynamic> json = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    return ApiException(
      statusCode: statusCode,
      code: json['code']?.toString() ?? 'HTTP_$statusCode',
      message: json['message']?.toString() ?? '',
      details: json['details'] ?? json,
    );
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    Uint8List? bytes,
    String? contentType,
    String? token,
    Duration? timeout,
  }) async {
    final http.Request request = http.Request(method, uri(path, query));
    request.headers['accept'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      request.headers['authorization'] = 'Bearer $token';
    }
    if (bytes != null) {
      request.headers['content-type'] = contentType ?? 'application/octet-stream';
      request.bodyBytes = bytes;
    } else if (body != null) {
      request.headers['content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    try {
      final http.StreamedResponse streamed = await _transport
          .send(request)
          .timeout(timeout ?? ApiConfig.timeout);
      return await http.Response.fromStream(
        streamed,
      ).timeout(timeout ?? ApiConfig.timeout);
    } on TimeoutException {
      throw const ApiException(
        statusCode: 0,
        code: ApiException.network,
        message: 'timeout',
      );
    } on SocketException catch (error) {
      throw ApiException(
        statusCode: 0,
        code: ApiException.network,
        message: error.message,
      );
    } on http.ClientException catch (error) {
      throw ApiException(
        statusCode: 0,
        code: ApiException.network,
        message: error.message,
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Object? decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      decoded = null;
    }
    final Map<String, dynamic> json = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }
    throw ApiException(
      statusCode: response.statusCode,
      code: json['code']?.toString() ?? 'HTTP_${response.statusCode}',
      message: json['message']?.toString() ?? '',
      details: json['details'],
    );
  }
}
