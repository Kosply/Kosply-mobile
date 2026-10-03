/// @title EmailCodeVerification
/// @notice Email verification block: four digit boxes, a short reminder of
/// where the code was sent, a resend link, and the error state.
/// @dev Shared by the registration form and the forgot-password flow so the
/// verification experience is identical in both places.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';
import 'code_verification_row.dart';

/// @title EmailCodeVerification
/// @notice Reusable email verification block.
class EmailCodeVerification extends StatelessWidget {
  /// @notice Creates the verification block.
  /// @param controllers One controller per code box.
  /// @param focusNodes One focus node per code box.
  /// @param email Email the code was sent to; falls back to a sample address.
  /// @param helper Extra help text under the reminder line.
  /// @param error Validation message, or null when valid.
  /// @param onChanged Called when any box value changes.
  /// @param onResend Called when the resend link is tapped.
  /// @return A new {EmailCodeVerification} instance.
  const EmailCodeVerification({
    required this.controllers,
    required this.focusNodes,
    required this.email,
    required this.helper,
    required this.error,
    required this.onChanged,
    required this.onResend,
    super.key,
  });

  /// @dev Email shown when the field is still empty.
  static const String placeholderEmail = 'name@kampus.ac.id';

  /// @dev Label of the resend link.
  static const String resendLabel = 'Resend code';

  /// @dev One controller per code box.
  final List<TextEditingController> controllers;

  /// @dev One focus node per code box.
  final List<FocusNode> focusNodes;

  /// @dev Email the code was sent to.
  final String email;

  /// @dev Extra help text under the reminder line.
  final String helper;

  /// @dev Validation message, or null when valid.
  final String? error;

  /// @dev Called when any box value changes.
  final VoidCallback onChanged;

  /// @dev Called when the resend link is tapped.
  final VoidCallback onResend;

  /// @notice Builds the verification block.
  /// @param context The build context.
  /// @return The verification block widget.
  @override
  Widget build(BuildContext context) {
    final target = email.trim().isEmpty ? placeholderEmail : email.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CodeVerificationRow(
          controllers: controllers,
          focusNodes: focusNodes,
          hasError: error != null,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a 4-digit code to $target.',
          style: const TextStyle(
            fontSize: 12,
            height: 1.3,
            color: KosplyColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: onResend,
          style: TextButton.styleFrom(
            foregroundColor: KosplyColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            resendLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KosplyColors.primary,
            ),
          ),
        ),
        if (helper.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            helper,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              color: KosplyColors.textSecondary,
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              color: KosplyColors.error,
            ),
          ),
        ],
      ],
    );
  }
}