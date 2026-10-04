/// @title ChatSellerBar
/// @notice Pinned "Chat penjual" action shared by product and seller detail.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';
import 'phosphor_icons.dart';

/// @title ChatSellerBar
/// @notice Bottom bar that lets a student message the seller.
class ChatSellerBar extends StatelessWidget {
  /// @notice Creates the chat bar.
  /// @param onPressed Tap handler for the chat button.
  /// @return A new {ChatSellerBar} instance.
  const ChatSellerBar({this.onPressed, super.key});

  /// @dev Tap handler for the chat button.
  final VoidCallback? onPressed;

  /// @notice Builds the pinned bar.
  /// @param context The build context.
  /// @return The bar widget.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: KosplyColors.surfaceOf(context),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed ?? () {},
              icon: const PhosphorGlyph(
                PhosphorCode.chatCircle,
                size: 18,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: KosplyColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: const Text(
                'Chat penjual',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
