/// @title SectionHeading
/// @notice Home section title with an optional trailing action on the far side.
/// @dev Owns the section title style and the "see all" row so every home
/// section lines up and stays tappable-ready.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title SectionHeading
/// @notice Reusable home section heading.
class SectionHeading extends StatelessWidget {
  /// @notice Creates a section heading.
  /// @param text Section title.
  /// @param actionLabel Optional trailing label, hidden when null.
  /// @param onTap Called when the trailing affordance is tapped.
  /// @return A new {SectionHeading} instance.
  const SectionHeading(this.text, {this.actionLabel, this.onTap, super.key});

  /// @dev Section title.
  final String text;

  /// @dev Optional trailing label shown on the far right.
  final String? actionLabel;

  /// @dev Called when the trailing affordance is tapped.
  final VoidCallback? onTap;

  /// @notice Builds the heading row.
  /// @param context The build context.
  /// @return The heading widget.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KosplyColors.textPrimaryOf(context),
            ),
          ),
        ),
        if (onTap != null || actionLabel != null)
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: actionLabel == null
                ? const SizedBox.shrink()
                : Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: KosplyColors.primary,
                    ),
                  ),
          ),
      ],
    );
  }
}
