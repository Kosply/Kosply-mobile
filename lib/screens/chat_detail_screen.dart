/// @title ChatDetailScreen
/// @notice Simple thread: photo plus username, bubbles, and a bottom composer.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../data/placeholder_inbox.dart';
import '../models/conversation.dart';
import '../models/seller.dart';
import '../theme/kosply_colors.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_avatar.dart';

/// @title ChatDetailScreen
/// @notice One conversation opened from Inbox or Chat penjual.
class ChatDetailScreen extends StatelessWidget {
  /// @notice Creates the chat screen.
  /// @param sellerId Identifier of the other student, matching a conversation.
  /// @return A new {ChatDetailScreen} instance.
  const ChatDetailScreen({required this.sellerId, super.key});

  /// @dev Named route for this screen.
  static const routeName = '/chat';

  /// @dev Identifier of the other student.
  final String sellerId;

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @param sellerId Identifier of the other student.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context, String sellerId) {
    return Navigator.of(context).pushNamed(routeName, arguments: sellerId);
  }

  /// @notice Builds the thread.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final Conversation conversation = PlaceholderInbox.byId(sellerId);
    final Seller peer = conversation.peer;
    final List<ChatMessage> messages = PlaceholderInbox.messagesFor(sellerId);

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: SellerAppBar(seller: peer, showActive: true, onMore: () {}),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: messages.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (BuildContext context, int index) {
          return _ChatBubble(message: messages[index], peer: peer);
        },
      ),
      bottomNavigationBar: const _ChatComposer(),
    );
  }
}

/// @title _ChatBubble
/// @notice Profile photo plus a simple rounded bubble.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.peer});

  final ChatMessage message;
  final Seller peer;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.isMine;
    final Widget avatar = SellerAvatar(
      path: mine ? Seller.avatar : peer.avatarPath,
      size: 32,
    );
    final Color bubbleColor = mine
        ? KosplyColors.primary
        : (KosplyColors.isDark(context)
              ? KosplyColors.darkSurface
              : const Color(0xFFF3F4F6));
    final Color textColor = mine
        ? Colors.white
        : KosplyColors.textPrimaryOf(context);

    final Widget bubble = Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(fontSize: 14, height: 1.35, color: textColor),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!mine) ...[avatar, const SizedBox(width: 8)],
        bubble,
        if (mine) ...[const SizedBox(width: 8), avatar],
      ],
    );
  }
}

/// @title _ChatComposer
/// @notice Bottom input with attach, text, and voice.
class _ChatComposer extends StatelessWidget {
  const _ChatComposer();

  @override
  Widget build(BuildContext context) {
    final Color surface = KosplyColors.surfaceOf(context);
    final Color outline = KosplyColors.outlineOf(context);
    final Color iconColor = KosplyColors.textPrimaryOf(context);

    return Material(
      color: surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              _ComposerIcon(
                key: const Key('chat-plus'),
                codePoint: PhosphorCode.plus,
                color: iconColor,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: KosplyColors.backgroundOf(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: outline),
                  ),
                  child: Center(
                    child: TextField(
                      key: const Key('chat-input'),
                      cursorColor: KosplyColors.primary,
                      style: TextStyle(
                        fontSize: 14,
                        color: KosplyColors.textPrimaryOf(context),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Tulis pesan...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: KosplyColors.textSecondaryOf(context),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ComposerIcon(
                key: const Key('chat-voice'),
                codePoint: PhosphorCode.microphone,
                color: iconColor,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// @title _ComposerIcon
/// @notice Circular plus or voice control.
class _ComposerIcon extends StatelessWidget {
  const _ComposerIcon({
    required this.codePoint,
    required this.color,
    required this.onPressed,
    super.key,
  });

  final int codePoint;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KosplyColors.primary.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: PhosphorGlyph(codePoint, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
