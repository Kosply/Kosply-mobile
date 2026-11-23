/// @title Server-sent events
/// @notice Parses an SSE byte stream into named events.
/// @dev Chat and AI streams use `event:` / `data:` frames. Comment lines
/// (`: ping`) are heartbeats and are dropped.
/// @author Kosply-mobile
library;

import 'dart:async';
import 'dart:convert';

/// @title SseEvent
/// @notice One SSE frame.
class SseEvent {
  /// @notice Creates a frame.
  /// @param name Event name, `message` when the frame omitted `event:`.
  /// @param data Raw data payload, usually one JSON object.
  /// @return A new {SseEvent} instance.
  const SseEvent({required this.name, required this.data});

  /// @dev Event name.
  final String name;

  /// @dev Raw data payload.
  final String data;

  /// @notice Decodes [data] as a JSON object.
  /// @return The object, or an empty map when the payload is not an object.
  Map<String, dynamic> get json {
    try {
      final Object? decoded = jsonDecode(data);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }
}

/// @notice Yields SSE frames from a UTF-8 byte stream.
/// @param bytes Response body.
/// @return Frames in arrival order. A trailing frame without a blank line
/// is still emitted.
Stream<SseEvent> parseSse(Stream<List<int>> bytes) async* {
  String name = 'message';
  final StringBuffer data = StringBuffer();
  final Stream<String> lines = bytes
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  await for (final String line in lines) {
    if (line.isEmpty) {
      if (data.isNotEmpty) {
        yield SseEvent(name: name, data: data.toString());
        name = 'message';
        data.clear();
      }
      continue;
    }
    if (line.startsWith(':')) {
      continue;
    }
    if (line.startsWith('event:')) {
      name = line.substring(6).trim();
      continue;
    }
    if (line.startsWith('data:')) {
      if (data.isNotEmpty) {
        data.write('\n');
      }
      data.write(line.substring(5).trim());
    }
  }
  if (data.isNotEmpty) {
    yield SseEvent(name: name, data: data.toString());
  }
}
