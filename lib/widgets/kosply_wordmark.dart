/// @title KosplyWordmark
/// @notice The Kosply wordmark image used in app bars and headers.
/// @dev Single place that owns the logo asset path and its default size, so
/// screens do not repeat the asset string.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';

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