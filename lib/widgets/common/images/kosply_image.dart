/// @title KosplyImage
/// @notice One image widget for every source a path can be.
/// @dev Listing photos and avatars come from the backend as `http(s)` URLs
/// (`POST /api/uploads/images`), fresh camera captures are local files, and
/// placeholders are bundled assets. Picking by prefix keeps every caller a
/// single line, and a broken URL falls back to [fallbackAsset] instead of the
/// red error box.
/// @author Kosply-mobile
library;

import 'dart:io';

import 'package:flutter/material.dart';

/// @title KosplyImage
/// @notice Network, file, or asset image chosen from [path].
class KosplyImage extends StatelessWidget {
  /// @notice Creates the image.
  /// @param path URL, absolute file path, or asset path.
  /// @param fit How the image fills its box.
  /// @param width Optional width.
  /// @param height Optional height.
  /// @param fallbackAsset Asset shown when [path] is empty or fails to load.
  /// @return A new {KosplyImage} instance.
  const KosplyImage(
    this.path, {
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackAsset = placeholder,
    super.key,
  });

  /// @dev Default fallback: the catalogue placeholder.
  static const String placeholder = 'assets/images/placeholder_catalog.png';

  /// @dev URL, absolute file path, or asset path.
  final String path;

  /// @dev How the image fills its box.
  final BoxFit fit;

  /// @dev Optional width.
  final double? width;

  /// @dev Optional height.
  final double? height;

  /// @dev Asset shown when [path] is empty or fails to load.
  final String fallbackAsset;

  /// @notice Whether [value] is a remote URL.
  /// @param value Image path.
  /// @return True for `http://` and `https://`.
  static bool isRemote(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  /// @notice Image provider for [value], for widgets that take one.
  /// @param value URL, absolute file path, or asset path.
  /// @return The matching provider.
  static ImageProvider<Object> providerFor(String value) {
    if (isRemote(value)) {
      return NetworkImage(value);
    }
    if (value.startsWith('/')) {
      return FileImage(File(value));
    }
    return AssetImage(value.isEmpty ? placeholder : value);
  }

  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext context, Object error, StackTrace? stack) {
      return Image.asset(fallbackAsset, fit: fit, width: width, height: height);
    }

    if (path.isEmpty) {
      return Image.asset(fallbackAsset, fit: fit, width: width, height: height);
    }
    if (isRemote(path)) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: fallback,
      );
    }
    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: fallback,
      );
    }
    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: fallback,
    );
  }
}
