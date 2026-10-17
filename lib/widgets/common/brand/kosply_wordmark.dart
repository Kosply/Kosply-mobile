/// @title Kosply brand marks
/// @notice Splash icon and wordmark assets used across the app.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';

/// @title KosplyMark
/// @notice The square splash logo (`logo.png`).
class KosplyMark extends StatelessWidget {
  /// @notice Creates the splash mark.
  /// @param size Box size in logical pixels.
  /// @return A new {KosplyMark} instance.
  const KosplyMark({this.size = 36, super.key});

  /// @dev Asset path of the splash logo.
  static const String assetPath = 'assets/images/logo.png';

  /// @dev Box size in logical pixels.
  final double size;

  /// @notice Builds the splash logo.
  /// @param context The build context.
  /// @return The logo image.
  @override
  Widget build(BuildContext context) {
    return Image(
      image: const AssetImage(assetPath),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// @title KosplyWordmark
/// @notice Reusable Kosply logo image.
class KosplyWordmark extends StatelessWidget {
  /// @notice Creates the wordmark image.
  /// @param width Display width; height follows the aspect ratio.
  /// @param height Optional fixed height, overrides the aspect ratio.
  /// @return A new {KosplyWordmark} instance.
  const KosplyWordmark({this.width = 110, this.height, super.key});

  /// @dev Asset path of the wordmark image.
  static const String assetPath = 'assets/images/logo_text.png';

  /// @dev Display width.
  final double width;

  /// @dev Optional fixed height.
  final double? height;

  /// @notice Builds the wordmark image.
  /// @param context The build context.
  /// @return The wordmark image widget.
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage(assetPath),
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
