/// @title FormHeading
/// @notice Left-aligned screen heading shared by every form screen.
/// @dev Owns the 22px bold heading style so titles match across the app.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title FormHeading
/// @notice Reusable form screen heading.
class FormHeading extends StatelessWidget {
  /// @notice Creates a heading.
  /// @param text Heading text.
  /// @param topGap Space above the heading.
  /// @return A new {FormHeading} instance.
  const FormHeading(this.text, {this.topGap = 20, super.key});

  /// @dev Heading text.
  final String text;

  /// @dev Space above the heading.
  final double topGap;

  /// @notice Builds the heading.
  /// @param context The build context.
  /// @return The heading widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topGap),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: KosplyColors.textPrimary,
        ),
      ),
    );
  }
}