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

import '../../../core/location/device_location.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/catalog/seller.dart';
import '../../../models/chat/conversation.dart';
import '../../../data/inbox/inbox_repository.dart';
import '../../../providers/catalog/listing_draft_provider.dart';
import '../../../providers/inbox/inbox_providers.dart';
import '../../../providers/location/location_label_provider.dart';
import '../../settings/verification/ktm_camera_screen.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../core/ui_bridge/ui_bridge_scope.dart';
import '../../../widgets/ai/overlay/ai_overlay_layer.dart';
import '../../../widgets/common/chat/chat_composer.dart';
import '../../../widgets/common/chat/message_bubble.dart';
import '../../../widgets/seller/appbar/seller_app_bar.dart';

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
      _tell(error.userMessage);
      rethrow;
    }
  }

  /// @notice Reads the current pin and posts it. Nothing is staged in the field.
  /// @return Future completing when the bubble is stored, or the snackbar shows.
  Future<void> _sendLocation() async {
    final DeviceFix? fix = await ref.read(deviceLocationProvider).currentFix();
    if (!mounted) {
      return;
    }
    if (fix == null || !fix.hasPin) {
      _tell('Lokasi saat ini belum bisa diambil.');
      return;
    }
    try {
      await ref
          .read(inboxRepositoryProvider)
          .sendLocation(
            widget.conversationId,
            latitude: fix.latitude,
            longitude: fix.longitude,
            label: fix.label,
          );
    } on ApiException catch (error) {
      _tell(error.userMessage);
      rethrow;
    }
  }

  /// @notice Takes one photo and posts its uploaded URL. The shutter returns
  /// the file at once, so the composer never holds a preview.
  /// @return Future completing when the bubble is stored, or the student backs out.
  Future<void> _sendPhoto() async {
    final String? path = await KtmCameraScreen.push(context, title: 'Foto');
    if (path == null || !mounted) {
      return;
    }
    try {
      final String url = await ref
          .read(uploadRepositoryProvider)
          .uploadImage(path);
      if (!mounted) {
        return;
      }
      await ref
          .read(inboxRepositoryProvider)
          .sendImage(widget.conversationId, url);
    } on ApiException catch (error) {
      _tell(error.userMessage);
      rethrow;
    } catch (_) {
      _tell('Foto belum bisa dikirim.');
      rethrow;
    }
  }

  void _tell(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

    return RouteGapHost(
      gap: kComposerGap,
      child: Scaffold(
        backgroundColor: KosplyColors.backgroundOf(context),
        appBar: SellerAppBar(seller: peer, showActive: true),
        body: UiBridgeScope(
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
        bottomNavigationBar: ChatComposer(
          onSend: _send,
          onSendLocation: _sendLocation,
          onSendPhoto: _sendPhoto,
        ),
      ),
    );
  }
}

/// @title _ChatBubble
/// @notice The student on the right, the other person on the left.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.peer});

  final ChatMessage message;
  final Seller peer;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.isMine;
    final String place = message.locationLabel.trim().isEmpty
        ? 'Lokasi saat ini'
        : message.locationLabel.trim();
    return MessageBubble(
      text: message.isLocation ? '' : message.text,
      mine: mine,
      avatarPath: mine ? Seller.avatar : peer.avatarPath,
      imageUrl: message.isImage ? message.imageUrl : '',
      locationLabel: message.isLocation ? place : '',
      bubbleId: message.id,
    );
  }
}
