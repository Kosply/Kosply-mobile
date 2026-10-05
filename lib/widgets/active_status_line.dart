/// @title ActiveStatusLine
/// @notice Clock icon plus last-active label under a username.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';
import 'phosphor_icons.dart';

/// @title ActiveStatusLine
/// @notice Compact activity row used on chat and seller identity.
class ActiveStatusLine extends StatelessWidget {
  /// @notice Creates the activity row.
  /// @param label Relative activity copy, e.g. "aktif 5 menit lalu".
  /// @param iconSize Clock size in logical pixels.
  /// @param fontSize Label size in logical pixels.
  /// @return A new {ActiveStatusLine} instance.
  const ActiveStatusLine({
    required this.label,
    this.iconSize = 14,
    this.fontSize = 12,
    super.key,
  });

  /// @dev Relative activity copy.
  final String label;

  /// @dev Clock size in logical pixels.
  final double iconSize;

  /// @dev Label size in logical pixels.
  final double fontSize;

  /// @notice Builds the green clock and label.
  /// @param context The build context.
  /// @return The activity row.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PhosphorGlyph(
          PhosphorCode.clock,
          size: iconSize,
          color: KosplyColors.active,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: KosplyColors.active,
            ),
          ),
        ),
      ],
    );
  }
}
