/// @title Inbox providers
/// @notice Exposes the offline-first inbox to the chat screens.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers/database_provider.dart';
import '../../data/inbox/inbox_repository.dart';
import '../../models/catalog/seller.dart';
import '../../models/chat/conversation.dart';

/// @dev Inbox repository backed by the Drift cache.
final inboxRepositoryProvider = Provider<InboxRepository>(
  (ref) => InboxRepository(dao: ref.watch(appDatabaseProvider).inboxDao),
);

/// @dev The cached inbox rows, newest activity first.
final inboxConversationsProvider = StreamProvider<List<Conversation>>(
  (ref) => ref.watch(inboxRepositoryProvider).watchConversations(),
);

/// @dev The other student of one cached thread.
final chatPeerProvider = StreamProvider.family<Seller?, String>(
  (ref, String conversationId) =>
      ref.watch(inboxRepositoryProvider).watchPeer(conversationId),
);

/// @dev The bubbles of one cached thread, oldest first.
final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, String conversationId) =>
      ref.watch(inboxRepositoryProvider).watchMessages(conversationId),
);
