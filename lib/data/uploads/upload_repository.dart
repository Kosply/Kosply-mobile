/// @title UploadRepository
/// @notice Sends a local photo to `POST /api/uploads/images`.
/// @dev The backend stores raw image bytes and answers with the URL every
/// other route expects (`postman/specs/tables/uploads.md`): listing photos,
/// avatars and chat images all travel as URLs, never as bytes.
/// @author Kosply-mobile
library;

import 'dart:io';
import 'dart:typed_data';

import '../../core/network/api_client.dart';
import '../../core/network/json_read.dart';

/// @title UploadRepository
/// @notice Photo uploads.
class UploadRepository {
  /// @notice Creates the repository.
  /// @param api Backend client.
  /// @param readBytes Reads a local file; replaced in tests.
  /// @return A new {UploadRepository} instance.
  UploadRepository({required this.api, Future<Uint8List> Function(String)? readBytes})
    : _readBytes = readBytes ?? ((String path) => File(path).readAsBytes());

  /// @dev Backend client.
  final ApiClient api;

  final Future<Uint8List> Function(String) _readBytes;

  /// @notice Uploads one image file.
  /// @param path Local file path, e.g. a camera capture.
  /// @return The public URL of the stored image.
  Future<String> uploadImage(String path) async {
    final Uint8List bytes = await _readBytes(path);
    final Map<String, dynamic> json = await api.postBytes(
      '/api/uploads/images',
      bytes,
      contentTypeFor(path),
    );
    return (json.object('item') ?? const <String, dynamic>{}).str('url');
  }

  /// @notice Media type from a file extension; camera captures are JPEG.
  /// @param path Local file path.
  /// @return `image/png`, `image/webp`, or `image/jpeg`.
  static String contentTypeFor(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
