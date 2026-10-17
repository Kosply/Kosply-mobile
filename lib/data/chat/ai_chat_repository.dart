/// @title AiChatRepository
/// @notice Offline-first Home AI conversations and their bubbles.
/// @dev The overlay keeps its optimistic state in the notifier; this repository
/// hydrates that state from the cache and persists every appended exchange.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../../core/database/daos/ai_chat_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../models/chat/ai_thread.dart';
import '../shared/local_user.dart';
import '../shared/stream_utils.dart';
import '../shared/time_labels.dart';
import 'placeholder_ai_chat.dart';

/// @title AiChatRepository
/// @notice Persistence for the Home AI overlay history.
class AiChatRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the AI cache.
  /// @return A new {AiChatRepository} instance.
  AiChatRepository({required this.dao});

  /// @dev Drift access to the AI cache.
  final AiChatDao dao;

  /// @notice Fills the cache when it has never been synced.
  /// @return Future completing when the cache is ready.
  Future<void> ensureSeeded() async {
    if (await dao.isConversationCacheEmpty()) {
      final int now = utcMillisNow();
      await dao.replaceConversations(
        rows: PlaceholderAiChat.conversationRows(now: now),
        fetchedAt: now,
      );
      await dao.upsertMessages(PlaceholderAiChat.messageRows(now: now));
    }
  }

  /// @notice Streams the whole history, newest activity first.
  /// @return Stream of threads with their bubbles.
  Stream<List<AiThread>> watchThreads() {
    return combineLatest2(
      dao.watchConversations(),
      dao.watchAllMessages(),
      _toThreads,
    );
  }

  /// @notice Reads the history once.
  /// @dev Used to hydrate the overlay notifier without listening.
  /// @return The threads as currently cached.
  Future<List<AiThread>> threadsOnce() async {
    final List<AiConversationRow> conversations = await dao
        .conversationsOnce();
    final List<AiMessageRow> messages = await dao.allMessagesOnce();
    return _toThreads(conversations, messages);
  }

  /// @notice Persists one thread and its bubbles.
  /// @dev Called after the optimistic overlay update so the cache always
  /// mirrors what the student just saw.
  /// @param thread Thread to store.
  /// @return Future completing when the write is durable.
  Future<void> persistThread(AiThread thread) async {
    final int now = utcMillisNow();
    await dao.upsertConversation(
      AiConversationsCompanion(
        id: Value<String>(thread.id),
        userId: const Value<String>(localUserId),
        title: Value<String>(thread.title),
        lastMessageAt: Value<int>(now),
        createdAt: Value<int>(now),
        backendUpdatedAt: Value<int>(now),
        updatedAt: Value<int>(now),
        lastFetched: Value<int>(now),
      ),
    );
    await dao.upsertMessages(<AiMessagesCompanion>[
      for (int i = 0; i < thread.messages.length; i++)
        AiMessagesCompanion.insert(
          id: thread.messages[i].id,
          conversationId: thread.id,
          role: Value<String>(
            thread.messages[i].isMine ? 'USER' : 'ASSISTANT',
          ),
          content: Value<String>(thread.messages[i].text),
          createdAt: Value<int>(now + i),
        ),
    ]);
  }

  List<AiThread> _toThreads(
    List<AiConversationRow> conversations,
    List<AiMessageRow> messages,
  ) {
    return <AiThread>[
      for (final AiConversationRow row in conversations)
        _toThread(row, messages),
    ];
  }

  AiThread _toThread(AiConversationRow row, List<AiMessageRow> messages) {
    final List<AiMessageRow> threadMessages = messages
        .where((AiMessageRow item) => item.conversationId == row.id)
        .toList();
    final AiMessageRow? last = threadMessages.isEmpty
        ? null
        : threadMessages.last;
    return AiThread(
      id: row.id,
      title: row.title,
      preview: last?.content ?? '',
      timeLabel: timeLabelFor(row.lastMessageAt),
      messages: <AiMessage>[
        for (final AiMessageRow item in threadMessages)
          AiMessage(
            id: item.id,
            text: item.content,
            isMine: item.role == 'USER',
          ),
      ],
    );
  }
}
