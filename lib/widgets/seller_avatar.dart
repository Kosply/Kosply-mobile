/// @title SellerAvatar
/// @notice Circular profile photo with a Phosphor user fallback.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/seller.dart';
import '../theme/kosply_colors.dart';
import 'phosphor_icons.dart';

/// @title SellerAvatar
/// @notice Round photo used on identity rows, inbox, and chat bubbles.
class SellerAvatar extends StatelessWidget {
  /// @notice Creates the avatar.
  /// @param path Asset path of the photo.
  /// @param size Diameter in logical pixels.
  /// @return A new {SellerAvatar} instance.
  const SellerAvatar({required this.path, this.size = 44, super.key});

  /// @notice Avatar for a seller profile.
  /// @param seller Profile whose photo to show.
  /// @param size Diameter in logical pixels.
  /// @return A new {SellerAvatar} instance.
  SellerAvatar.seller(Seller seller, {double size = 44, Key? key})
    : this(path: seller.avatarPath, size: size, key: key);

  /// @dev Asset path of the photo.
  final String path;

  /// @dev Diameter in logical pixels.
  final double size;

  /// @notice Builds the circular photo.
  /// @param context The build context.
  /// @return The avatar widget.
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(
                width: size,
                height: size,
                color: KosplyColors.primary.withValues(alpha: 0.12),
                child: Center(
                  child: PhosphorGlyph(
                    PhosphorCode.user,
                    size: size * 0.45,
                    color: KosplyColors.primary,
                  ),
                ),
              );
            },
      ),
    );
  }
}
