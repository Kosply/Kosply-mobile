/// @title FormActions
/// @notice Bottom action bar shared by the form screens.
/// @dev Renders the pinned Back + primary-action row, or a single full-width
/// primary button when [showBack] is false. Every button uses the shared
/// height, radius, and colours so the bars look identical across screens.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title FormActions
/// @notice Reusable bottom action bar for forms.
class FormActions extends StatelessWidget {
  /// @notice Creates the action bar.
  /// @param onBack Callback for the outlined back button.
  /// @param onContinue Callback for the primary action button.
  /// @param backLabel Label of the back button.
  /// @param continueLabel Label of the primary button.
  /// @param showBack Whether to show the back button.
  /// @return A new {FormActions} instance.
  const FormActions({
    required this.onBack,
    required this.onContinue,
    this.backLabel = 'Back',
    this.continueLabel = 'Continue',
    this.showBack = true,
    super.key,
  });

  /// @dev Height shared by both buttons.
  static const double buttonHeight = 52;

  /// @dev Outer padding around the bar.
  static const EdgeInsets padding = EdgeInsets.fromLTRB(24, 8, 24, 16);

  /// @dev Callback for the outlined back button.
  final VoidCallback onBack;

  /// @dev Callback for the primary action button.
  final VoidCallback onContinue;

  /// @dev Label of the back button.
  final String backLabel;

  /// @dev Label of the primary button.
  final String continueLabel;

  /// @dev Whether to show the back button.
  final bool showBack;

  /// @notice Builds the outlined back button.
  /// @param label Button label.
  /// @param onPressed Tap callback.
  /// @return The outlined button widget.
  Widget _buildBack(String label, VoidCallback onPressed) {
    return SizedBox(
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: KosplyColors.card,
          foregroundColor: Colors.black87,
          side: const BorderSide(color: KosplyColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// @notice Builds the primary filled button.
  /// @param label Button label.
  /// @param onPressed Tap callback.
  /// @return The filled button widget.
  Widget _buildPrimary(String label, VoidCallback onPressed) {
    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: KosplyColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// @notice Builds the action bar.
  /// @param context The build context.
  /// @return The action bar widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: showBack
          ? Row(
              children: [
                Expanded(child: _buildBack(backLabel, onBack)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPrimary(continueLabel, onContinue),
                ),
              ],
            )
          : _buildPrimary(continueLabel, onContinue),
    );
  }
}