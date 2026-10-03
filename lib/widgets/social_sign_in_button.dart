/// @title SocialSignInButton
/// @notice Outlined social sign-in button with a grey border.
/// @dev White card, grey border, radius 12, height 52, with a leading brand
/// icon and a centered label.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title SocialSignInButton
/// @notice Reusable Google/Apple style sign-in button.
class SocialSignInButton extends StatelessWidget {
  /// @notice Creates a social sign-in button.
  /// @param label Button text.
  /// @param asset Icon asset path.
  /// @param onTap Tap callback.
  /// @return A new {SocialSignInButton} instance.
  const SocialSignInButton({
    required this.label,
    required this.asset,
    required this.onTap,
    super.key,
  });

  /// @dev Height of the button.
  static const double buttonHeight = 52;

  /// @dev Icon size inside the button.
  static const double iconSize = 22;

  /// @dev Button text.
  final String label;

  /// @dev Icon asset path.
  final String asset;

  /// @dev Tap callback.
  final VoidCallback onTap;

  /// @notice Builds the outlined social button.
  /// @param context The build context.
  /// @return The outlined button widget.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: KosplyColors.card,
          foregroundColor: Colors.black87,
          side: const BorderSide(color: KosplyColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(asset),
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}