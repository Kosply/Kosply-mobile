/// @title TicketDetailScreen
/// @notice Support thread: chat like Inbox, with username and active line.
/// @dev The thread refreshes from `GET /api/support/tickets/:id` on open, and
/// the composer replies through `POST /api/support/tickets/:id/messages`.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../models/catalog/seller.dart';
import '../../../models/chat/conversation.dart';
import '../../../providers/support/support_providers.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/chat/chat_composer.dart';
import '../../../widgets/seller/appbar/seller_app_bar.dart';
import '../../../widgets/seller/identity/seller_avatar.dart';

/// @title TicketDetailScreen
/// @notice One ticket opened from Contact support.
class TicketDetailScreen extends ConsumerWidget {
  /// @notice Creates the ticket screen.
  /// @param ticketId Identifier of the ticket to show.
  /// @return A new {TicketDetailScreen} instance.
  const TicketDetailScreen({required this.ticketId, super.key});

  /// @dev Named route for this screen.
  static const routeName = '/ticket';

  /// @dev Identifier of the ticket to show.
  final String ticketId;

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @param ticketId Identifier of the ticket to show.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context, String ticketId) {
    return Navigator.of(context).pushNamed(routeName, arguments: ticketId);
  }

  /// @notice Sends a reply, explaining a refusal (e.g. a closed ticket).
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @param text Reply text.
  /// @return Future completing when the reply is stored.
  Future<void> _reply(BuildContext context, WidgetRef ref, String text) async {
    try {
      await ref.read(supportRepositoryProvider).reply(ticketId, text);
    } on ApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
      rethrow;
    }
  }

  /// @notice Builds the thread.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ticketSyncProvider(ticketId));
    final Seller agent = ref.watch(supportRepositoryProvider).agent;
    final List<ChatMessage> messages =
        ref.watch(ticketMessagesProvider(ticketId)).value ??
        const <ChatMessage>[];

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: SellerAppBar(
        seller: agent,
        showActive: true,
        onMore: () async {
          final bool? close = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Tutup tiket ini?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    key: const Key('ticket-close'),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Tutup'),
                  ),
                ],
              );
            },
          );
          if (close != true || !context.mounted) {
            return;
          }
          try {
            await ref.read(supportRepositoryProvider).close(ticketId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tiket ditutup.')),
              );
            }
          } on ApiException catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.userMessage)),
              );
            }
          }
        },
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: messages.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (BuildContext context, int index) {
          return _TicketBubble(message: messages[index], agent: agent);
        },
      ),
      bottomNavigationBar: ChatComposer(
        onSend: (String text) => _reply(context, ref, text),
      ),
    );
  }
}

/// @title _TicketBubble
/// @notice Profile photo plus a simple rounded bubble.
class _TicketBubble extends StatelessWidget {
  const _TicketBubble({required this.message, required this.agent});

  final ChatMessage message;
  final Seller agent;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.isMine;
    final Widget avatar = SellerAvatar(
      path: mine ? Seller.avatar : agent.avatarPath,
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
