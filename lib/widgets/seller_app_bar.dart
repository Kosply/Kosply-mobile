/// @title SellerAppBar
/// @notice Back control plus the signed-in seller photo and username.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/seller.dart';
import '../theme/kosply_colors.dart';
import 'active_status_line.dart';
import 'phosphor_icons.dart';
import 'seller_avatar.dart';

/// @title SellerAppBar
/// @notice Shared top bar for seller tools and chat threads.
class SellerAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// @notice Creates the seller top bar.
  /// @param seller Profile shown beside the back control.
  /// @param showActive Whether to show the green last-active line.
  /// @param onMore Optional overflow handler; shows three dots when set.
  /// @return A new {SellerAppBar} instance.
  const SellerAppBar({
    required this.seller,
    this.showActive = false,
    this.onMore,
    super.key,
  });

  /// @dev Profile shown beside the back control.
  final Seller seller;

  /// @dev Whether to show the green last-active line under the username.
  final bool showActive;

  /// @dev Optional overflow action shown as three dots on the trailing side.
  final VoidCallback? onMore;

  /// @notice App-bar height used by [Scaffold].
  /// @return The toolbar size.
  @override
  Size get preferredSize => Size.fromHeight(showActive ? 64 : kToolbarHeight);

  /// @notice Builds the back control, photo, username, and optional active line.
  /// @param context The build context.
  /// @return The app bar.
  @override
  Widget build(BuildContext context) {
    final Color onShell = KosplyColors.textPrimaryOf(context);

    return AppBar(
      backgroundColor: KosplyColors.backgroundOf(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: preferredSize.height,
      leading: IconButton(
        icon: PhosphorGlyph(PhosphorCode.arrowLeft, size: 20, color: onShell),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          SellerAvatar.seller(seller, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  seller.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: onShell,
                  ),
                ),
                if (showActive) ...[
                  const SizedBox(height: 2),
                  ActiveStatusLine(
                    label: seller.activeLabel,
                    iconSize: 12,
                    fontSize: 11,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (onMore != null)
          IconButton(
            key: const Key('chat-more'),
            icon: PhosphorGlyph(
              PhosphorCode.dotsThree,
              weight: PhosphorWeight.bold,
              size: 20,
              color: onShell,
            ),
            onPressed: onMore,
          ),
      ],
    );
  }
}
