/// @title SellerIdentity
/// @notice Profile photo, username, and active line shared by product and
/// seller screens.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/seller.dart';
import '../theme/kosply_colors.dart';
import 'active_status_line.dart';
import 'phosphor_icons.dart';

/// @title SellerIdentity
/// @notice Compact seller row copied across product and seller detail.
class SellerIdentity extends StatelessWidget {
  /// @notice Creates the identity row.
  /// @param seller Profile to render.
  /// @param onTap Optional tap handler; shows a chevron when set.
  /// @param avatarSize Photo diameter.
  /// @return A new {SellerIdentity} instance.
  const SellerIdentity({
    required this.seller,
    this.onTap,
    this.avatarSize = 44,
    super.key,
  });

  /// @dev Profile to render.
  final Seller seller;

  /// @dev Optional tap handler.
  final VoidCallback? onTap;

  /// @dev Photo diameter.
  final double avatarSize;

  /// @notice Builds the photo, username, and active line.
  /// @param context The build context.
  /// @return The identity row.
  @override
  Widget build(BuildContext context) {
    final Widget row = Row(
      children: [
        ClipOval(
          child: Image.asset(
            seller.avatarPath,
            width: avatarSize,
            height: avatarSize,
            fit: BoxFit.cover,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Container(
                    width: avatarSize,
                    height: avatarSize,
                    color: KosplyColors.primary.withValues(alpha: 0.12),
                    child: const Center(
                      child: PhosphorGlyph(
                        PhosphorCode.user,
                        size: 20,
                        color: KosplyColors.primary,
                      ),
                    ),
                  );
                },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seller.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: KosplyColors.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: 4),
              ActiveStatusLine(label: seller.activeLabel),
            ],
          ),
        ),
        if (onTap != null)
          PhosphorGlyph(
            PhosphorCode.caretRight,
            size: 16,
            color: KosplyColors.textSecondaryOf(context),
          ),
      ],
    );

    if (onTap == null) {
      return row;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: row,
    );
  }
}
