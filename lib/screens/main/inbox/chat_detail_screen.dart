/// @title ChatDetailScreen
/// @notice Simple thread: photo plus username, bubbles, and a bottom composer.
/// @dev Keyed by the backend room id. Opening the screen pulls the room and
/// its thread (`GET /api/conversations/:id`), which also marks the other
/// side's bubbles read. While it stays open the thread follows
/// `GET /api/conversations/:id/stream`, and falls back to
/// `GET /api/conversations/:id/wait` when the stream cannot be opened.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../models/catalog/seller.dart';
import '../../../models/chat/conversation.dart';
import '../../../data/inbox/inbox_repository.dart';
import '../../../providers/inbox/inbox_providers.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../core/ui_bridge/ui_bridge_scope.dart';
import '../../../widgets/ai/overlay/ai_overlay_layer.dart';
import '../../../widgets/common/chat/chat_composer.dart';
import '../../../widgets/seller/appbar/seller_app_bar.dart';
import '../../../widgets/seller/identity/seller_avatar.dart';

/// @title ChatDetailScreen
/// @notice One conversation opened from Inbox, a product, or a seller.
class ChatDetailScreen extends ConsumerStatefulWidget {
  /// @notice Creates the chat screen.
  /// @param conversationId Backend room id.
  /// @return A new {ChatDetailScreen} instance.
  const ChatDetailScreen({required this.conversationId, super.key});

  /// @dev Named route for this screen.
  static const routeName = '/chat';

  /// @dev Pause between one finished stream and the next.
  static const Duration pollInterval = Duration(seconds: 5);

  /// @dev Backend room id.
  final String conversationId;

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @param conversationId Backend room id.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context, String conversationId) {
    return Navigator.of(context)
        .pushNamed(routeName, arguments: conversationId);
  }

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

/// @title _ChatDetailScreenState
/// @notice Loads the room, polls the thread, and sends bubbles.
class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  bool _closed = false;
  Timer? _retry;
  Completer<void>? _gate;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    unawaited(_follow());
  }

  @override
  void dispose() {
    _closed = true;
    _retry?.cancel();
    final Completer<void>? gate = _gate;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
    super.dispose();
  }

  /// @notice Follows the room until the screen closes.
  /// @return Future that ends when the screen is disposed.
  Future<void> _follow() async {
    final InboxRepository repo = ref.read(inboxRepositoryProvider);
    while (mounted && !_closed) {
      try {
        await repo.pullStream(widget.conversationId);
      } on ApiException {
        if (!mounted || _closed) {
          return;
        }
        try {
          await repo.waitForMessages(widget.conversationId);
        } on ApiException {
          // The next pass tries the stream again.
        }
      }
      if (!mounted || _closed) {
        return;
      }
      final Completer<void> gate = Completer<void>();
      _gate = gate;
      _retry = Timer(ChatDetailScreen.pollInterval, () {
        if (!gate.isCompleted) {
          gate.complete();
        }
      });
      await gate.future;
      _retry = null;
      _gate = null;
    }
  }

  Future<void> _load() async {
    try {
      await ref
          .read(inboxRepositoryProvider)
          .refreshRoom(widget.conversationId);
    } on ApiException {
      // Offline: the cached room and bubbles stay on screen.
    }
  }

  Future<void> _send(String text) async {
    try {
      await ref
          .read(inboxRepositoryProvider)
          .sendText(widget.conversationId, text);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
      rethrow;
    }
  }

  /// @notice Builds the thread.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final Seller? peer = ref
        .watch(chatPeerProvider(widget.conversationId))
        .value;
    final List<ChatMessage> messages =
        ref.watch(chatMessagesProvider(widget.conversationId)).value ??
        const <ChatMessage>[];
    if (peer == null) {
      return Scaffold(
        backgroundColor: KosplyColors.backgroundOf(context),
        appBar: AppBar(backgroundColor: KosplyColors.backgroundOf(context)),
      );
    }

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: SellerAppBar(seller: peer, showActive: true, onMore: () {}),
      body: AiOverlayLayer(
        child: UiBridgeScope(
          screen: 'chat',
          selection: <String, Object?>{'conversationId': widget.conversationId},
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 72),
            itemCount: messages.length,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (BuildContext context, int index) {
              return _ChatBubble(message: messages[index], peer: peer);
            },
          ),
        ),
      ),
      bottomNavigationBar: ChatComposer(onSend: _send),
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
