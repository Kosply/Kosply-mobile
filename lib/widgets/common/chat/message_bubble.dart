/// @title Message bubble
/// @notice One chat or ticket bubble, the student on the right and the
/// other person on the left.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../../../theme/colors/kosply_colors.dart';
import '../icons/phosphor_icons.dart';
import '../images/kosply_image.dart';
import '../../seller/identity/seller_avatar.dart';

/// @title MessageBubble
/// @notice Avatar plus a rounded text, photo, or location bubble.
class MessageBubble extends StatelessWidget {
  /// @notice Creates the bubble.
  /// @param text Message body. Empty hides the caption.
  /// @param mine True when the signed-in student sent it.
  /// @param avatarPath Photo shown beside the bubble.
  /// @param imageUrl Uploaded photo. Empty means this is not a photo bubble.
  /// @param locationLabel Place name. Empty means this is not a location bubble.
  /// @return A new {MessageBubble} instance.
  const MessageBubble({
    required this.text,
    required this.mine,
    required this.avatarPath,
    this.imageUrl = '',
    this.locationLabel = '',
    this.bubbleId = '',
    super.key,
  });

  /// @dev Message body.
  final String text;

  /// @dev True when the signed-in student sent it.
  final bool mine;

  /// @dev Photo shown beside the bubble.
  final String avatarPath;

  /// @dev Uploaded photo URL.
  final String imageUrl;

  /// @dev Place name for a location bubble.
  final String locationLabel;

  /// @dev Stable id used to key photo and location content.
  final String bubbleId;

  /// @notice Builds the row on the right for the student and the left for
  /// the other person.
  /// @param context The build context.
  /// @return The bubble row.
  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = mine
        ? KosplyColors.primary
        : (KosplyColors.isDark(context)
              ? KosplyColors.darkSurface
              : const Color(0xFFF3F4F6));
    final Color textColor = mine
        ? Colors.white
        : KosplyColors.textPrimaryOf(context);
    final Widget avatar = SellerAvatar(path: avatarPath, size: 32);
    // Avatar and the gap sit inside this cap, so the label wraps before
    // the row runs past the screen edge.
    final double maxWidth = MediaQuery.sizeOf(context).width * 0.78;
    final double contentWidth = (maxWidth - 32 - 8 - 24 - 4).clamp(96.0, 280.0);

    final List<Widget> body = <Widget>[];
    if (imageUrl.isNotEmpty) {
      final double photoWidth = contentWidth.clamp(96.0, 220.0);
      body.add(
        ClipRRect(
          key: Key('chat-photo-$imageUrl'),
          borderRadius: BorderRadius.circular(12),
          child: KosplyImage(imageUrl, width: photoWidth, height: 180),
        ),
      );
    }
    if (locationLabel.isNotEmpty) {
      body.add(
        SizedBox(
          width: contentWidth,
          child: Row(
            key: Key(
              bubbleId.isEmpty ? 'chat-location' : 'chat-location-$bubbleId',
            ),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhosphorGlyph(PhosphorCode.mapPin, size: 16, color: textColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationLabel,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (text.isNotEmpty || body.isEmpty) {
      if (body.isNotEmpty) {
        body.add(const SizedBox(height: 8));
      }
      body.add(
        Text(
          text,
          style: TextStyle(fontSize: 14, height: 1.35, color: textColor),
        ),
      );
    }
    final Widget bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: body.length == 1
          ? body.first
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: body,
            ),
    );

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!mine) ...[avatar, const SizedBox(width: 8)],
            Flexible(child: bubble),
            if (mine) ...[const SizedBox(width: 8), avatar],
          ],
        ),
      ),
    );
  }
}
