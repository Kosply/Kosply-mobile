/// @title AiChatRepository
/// @notice Kosply AI threads: cached history plus turns through the backend.
/// @dev Conversation turns use `POST /api/ai/chat/stream` (SSE). A sensitive
/// tool pauses on `interrupt`; the student approves with
/// `POST /api/ai/chat/resume`. Contact with another student is a chat, never
/// a phone call. Photo listing fill stays on non-streaming `POST /api/ai/chat`.
/// History comes from `GET /api/ai/conversations` and `/api/ai/history/:id`.
/// @author Kosply-mobile
library;

import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../core/database/daos/ai_chat_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/json_read.dart';
import '../../core/network/sse.dart';
import '../../models/catalog/listing_card.dart';
import '../../models/chat/ai_turn.dart';
import '../../models/chat/listing_proposal.dart';
import '../../models/chat/ai_thread.dart';
import '../shared/stream_utils.dart';
import '../shared/time_labels.dart';

/// @title AiChatRepository
/// @notice AI chat persistence and backend turns.
class AiChatRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the AI chat cache.
  /// @param api Backend client.
  /// @param currentUserId Backend id of the signed-in student.
  /// @return A new {AiChatRepository} instance.
  AiChatRepository({
    required this.dao,
    required this.api,
    required this.currentUserId,
  });

  /// @dev Drift access to the AI chat cache.
  final AiChatDao dao;

  /// @dev Backend client.
  final ApiClient api;

  /// @dev Backend id of the signed-in student.
  final String currentUserId;

  static final Random _random = Random.secure();

  /// @notice A fresh conversation id the backend accepts (`[A-Za-z0-9_-]`).
  /// @return 24 lowercase alphanumerics.
  static String newConversationId() {
    const String alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(<int>[
      for (int i = 0; i < 24; i++)
        alphabet.codeUnitAt(_random.nextInt(alphabet.length)),
    ]);
  }

  /// @notice Replaces the cached thread list with the server's sessions.
  /// @return Future completing when the cache matches the server.
  Future<void> refreshThreads() async {
    final Map<String, dynamic> json = await api.get('/api/ai/conversations');
    final int now = utcMillisNow();
    await dao.replaceConversations(
      rows: <AiConversationsCompanion>[
        for (final Map<String, dynamic> item in json.objects('items'))
          AiConversationsCompanion(
            id: Value<String>(item.str('id')),
            userId: Value<String>(item.str('userId')),
            title: Value<String>(item.str('title')),
            lastMessageAt: Value<int>(item.millis('lastMessageAt')),
            createdAt: Value<int>(item.millis('createdAt')),
            backendUpdatedAt: Value<int>(item.millis('updatedAt')),
            updatedAt: Value<int>(now),
            lastFetched: Value<int>(now),
          ),
      ],
      fetchedAt: now,
    );
  }

  /// @notice Replaces one thread's cached messages with its transcript.
  /// @param conversationId Thread id.
  /// @return Future completing when the transcript is cached.
  Future<void> refreshHistory(String conversationId) async {
    final Map<String, dynamic> json = await api.get(
      '/api/ai/history/$conversationId',
    );
    final List<Map<String, dynamic>> messages = json.objects('messages');
    final int now = utcMillisNow();
    await dao.replaceMessages(
      conversationId: conversationId,
      rows: <AiMessagesCompanion>[
        for (int i = 0; i < messages.length; i++)
          if (_isTranscriptRole(messages[i].str('role')))
            AiMessagesCompanion.insert(
              id: '$conversationId-$i',
              conversationId: conversationId,
              role: Value<String>(_roleOf(messages[i].str('role'))),
              content: Value<String>(messages[i].str('content')),
              createdAt: Value<int>(now + i),
            ),
      ],
      fetchedAt: now,
    );
  }

  /// @dev Shown when a sensitive tool pauses and the draft text is missing.
  static const String approvalText =
      'AI butuh persetujuanmu sebelum melanjutkan.';

  /// @dev Asked under the message preview, before anything is sent.
  static const String approvalAsk = 'Kirim pesan ini?';

  /// @dev Asked under the seller-form preview, before the fields are written.
  static const String approvalFill = 'Isi form barang ini?';

  /// @notice Sends one chatbot turn over SSE, including the screen the user sees.
  /// @dev Events: `thinking`, `token`, `callback`, `interrupt`, `done`.
  /// [onPartial] fires as thinking and answer text grow. An interrupt with no
  /// answer becomes {approvalText}. The `done` frame completes the turn
  /// without waiting for the stream cancel, which would deadlock inside the
  /// event. Listing fill does not use this method.
  /// @param conversationId Thread id; a new id starts a new session.
  /// @param message The student's prompt.
  /// @param uiState Snapshot from {UiBridgeState.toJson}. Null when no
  /// screen is published.
  /// @param onPartial Called with the thinking and answer collected so far.
  /// @return The answer, thinking, callbacks, and whether approval is waiting.
  Future<AiTurn> ask({
    required String conversationId,
    required String message,
    Map<String, Object?>? uiState,
    List<String> imageUrls = const <String>[],
    void Function(String thinking, String answer)? onPartial,
  }) {
    final StringBuffer thinking = StringBuffer();
    final StringBuffer answer = StringBuffer();
    final List<UiCallback> callbacks = <UiCallback>[];
    bool needsApproval = false;
    String draft = '';
    ListingProposal? proposal;
    final Completer<AiTurn> result = Completer<AiTurn>();
    late final StreamSubscription<SseEvent> subscription;

    void closeStream() {
      scheduleMicrotask(() {
        subscription.cancel();
      });
    }

    void succeed() {
      if (result.isCompleted) {
        return;
      }
      result.complete(
        _turn(
          thinking.toString(),
          answer.toString(),
          callbacks,
          needsApproval,
          draft,
          proposal,
        ),
      );
      closeStream();
    }

    void fail(Object error, StackTrace stackTrace) {
      if (result.isCompleted) {
        return;
      }
      result.completeError(error, stackTrace);
      closeStream();
    }

    subscription = api
        .openSse(
          'POST',
          '/api/ai/chat/stream',
          body: <String, Object?>{
            'conversation_id': conversationId,
            'message': message,
            'ui_state': ?uiState,
            if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
            if (imageUrls.isNotEmpty) 'see_photos': true,
          },
          timeout: ApiConfig.aiTimeout,
        )
        .listen(
          (SseEvent event) {
            if (result.isCompleted) {
              return;
            }
            switch (event.name) {
              case 'thinking':
                thinking.write(event.json.str('text'));
                onPartial?.call(thinking.toString(), answer.toString());
              case 'token':
                answer.write(event.json.str('text'));
                onPartial?.call(thinking.toString(), answer.toString());
              case 'callback':
                final UiCallback? callback = UiCallback.fromJson(event.json);
                if (callback != null) {
                  callbacks.add(callback);
                }
              case 'interrupt':
                needsApproval = true;
                final String nextDraft = _draftOf(event.json);
                if (nextDraft.isNotEmpty) {
                  draft = nextDraft;
                }
                proposal = _proposalOf(event.json) ?? proposal;
              case 'error':
                fail(
                  ApiException(
                    statusCode: 502,
                    code: 'AGENT_ERROR',
                    message: event.json.str('message'),
                  ),
                  StackTrace.current,
                );
              case 'done':
                if (event.json.flag('awaitingApproval')) {
                  needsApproval = true;
                }
                succeed();
            }
          },
          onError: fail,
          onDone: succeed,
        );
    return result.future;
  }

  /// @notice Approves or rejects the sensitive tool waiting on a thread.
  /// @dev `POST /api/ai/chat/resume`. Approve runs the chat action. Reject
  /// continues without it. There is no phone call to place.
  /// @param conversationId Thread id.
  /// @param approve True to let the tool run.
  /// @return The agent's next answer.
  Future<AiTurn> resume({
    required String conversationId,
    required bool approve,
  }) async {
    final Map<String, dynamic> json = await api.post(
      '/api/ai/chat/resume',
      body: <String, Object?>{
        'conversation_id': conversationId,
        'approve': approve,
      },
      timeout: ApiConfig.aiTimeout,
    );
    return AiTurn.fromJson(json);
  }

  /// @notice Checks once whether a pending approval was resolved elsewhere.
  /// @dev `GET /api/ai/wait/:id`. The fake answers `noop` immediately so a
  /// widget test never blocks. A live `noop` also returns at once.
  /// @param conversationId Thread id.
  /// @return The wait status and any answer already produced.
  Future<({String status, String answer})> waitApproval(
    String conversationId,
  ) async {
    final Map<String, dynamic> json = await api.get(
      '/api/ai/wait/$conversationId',
      query: const <String, String>{'timeout': '1'},
      timeout: const Duration(seconds: 5),
    );
    return (status: json.str('status'), answer: json.str('answer'));
  }

  AiTurn _turn(
    String thinking,
    String answer,
    List<UiCallback> callbacks,
    bool needsApproval,
    String draft,
    ListingProposal? proposal,
  ) {
    String preview = draft.trim();
    String text = answer;
    if (needsApproval) {
      if (proposal != null) {
        text = approvalFill;
        preview = '';
      } else {
        if (preview.isEmpty) {
          preview = answer.trim();
        }
        text = preview.isEmpty ? approvalText : approvalAsk;
      }
    }
    return AiTurn(
      answer: text,
      thinking: thinking,
      callbacks: callbacks,
      needsApproval: needsApproval,
      draft: needsApproval ? preview : '',
      proposal: needsApproval ? proposal : null,
    );
  }

  /// @notice Reads the seller form a pending tool would write.
  /// @param json Interrupt event body.
  /// @return The four fields, or null when this pause is not a form fill.
  ListingProposal? _proposalOf(Map<String, dynamic> json) {
    for (final Map<String, dynamic> pause in json.objects('pending')) {
      for (final Map<String, dynamic> tool in pause.objects('pending_tools')) {
        if (tool.str('name') != 'fill_product_form') {
          continue;
        }
        final Map<String, dynamic> args =
            tool.object('args') ?? const <String, dynamic>{};
        final String title = args.str('title').trim();
        final String description = args.str('description').trim();
        final String category = args.str('category').trim();
        final int price = _rupiah(args['price']);
        if (title.isEmpty ||
            description.isEmpty ||
            category.isEmpty ||
            price < 1 ||
            price > 2000000000 ||
            title.length > 191) {
          continue;
        }
        return ListingProposal(
          title: title,
          price: price,
          description: description,
          category: category,
        );
      }
    }
    return null;
  }

  /// @notice Integer rupiah from a tool argument.
  /// @param value Model argument. Digits inside a string count too.
  /// @return The amount, or 0 when it is not a whole rupiah price.
  int _rupiah(Object? value) {
    if (value is bool) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      if (value != value.roundToDouble()) {
        return 0;
      }
      return value.toInt();
    }
    final String digits = (value?.toString() ?? '').replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    return int.tryParse(digits) ?? 0;
  }

  /// @notice Reads the chat line a pending tool would send.
  /// @param json Interrupt event body.
  /// @return The message text, or empty when the tool named none.
  String _draftOf(Map<String, dynamic> json) {
    for (final Map<String, dynamic> pause in json.objects('pending')) {
      for (final Map<String, dynamic> tool in pause.objects('pending_tools')) {
        final Map<String, dynamic> args =
            tool.object('args') ?? const <String, dynamic>{};
        final String message = args.str('message');
        if (message.isNotEmpty) {
          return message;
        }
        final String text = args.str('text');
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return '';
  }

  /// @notice Asks the agent to fill a product card from side photos.
  /// @dev Kept for the backend listing turn. The add-product form does not
  /// call this. A `photos` turn. [message] carries the seller's name and
  /// condition. The model writes the description and a category; price and
  /// stock stay null. The published title is the seller's name, not the model's.
  /// @param imageUrls Uploaded photo URLs, cover first.
  /// @param message `Nama barang` and `Kondisi barang` lines.
  /// @return The card.
  Future<ListingCard> fillListing(
    List<String> imageUrls, {
    required String message,
  }) async {
    final Map<String, dynamic> json = await api.post(
      '/api/ai/chat',
      body: <String, Object?>{
        'conversation_id': newConversationId(),
        'message': message,
        'imageUrls': imageUrls,
      },
      timeout: ApiConfig.aiTimeout,
    );
    final Map<String, dynamic>? listing = json.object('listing');
    if (listing == null) {
      throw const FormatException('the AI answered without a product card');
    }
    return ListingCard.fromJson(listing);
  }

  /// @notice Streams every cached thread with its messages.
  /// @return Stream of threads, newest activity first.
  Stream<List<AiThread>> watchThreads() {
    return combineLatest2(
      dao.watchConversations(),
      dao.watchAllMessages(),
      _toThreads,
    );
  }

  /// @notice Reads every cached thread once.
  /// @return Threads, newest activity first.
  Future<List<AiThread>> threadsOnce() async {
    final List<AiConversationRow> conversations = await dao.conversationsOnce();
    final List<AiMessageRow> messages = await dao.allMessagesOnce();
    return _toThreads(conversations, messages);
  }

  /// @notice Writes a thread and its messages to the cache.
  /// @param thread Thread as shown in the overlay.
  /// @return Future completing when the rows are durable.
  Future<void> persistThread(AiThread thread) async {
    final int now = utcMillisNow();
    await dao.upsertConversation(
      AiConversationsCompanion(
        id: Value<String>(thread.id),
        userId: Value<String>(currentUserId),
        title: Value<String>(thread.title),
        lastMessageAt: Value<int>(now),
        createdAt: Value<int>(now),
        backendUpdatedAt: Value<int>(now),
        updatedAt: Value<int>(now),
        lastFetched: Value<int>(now),
      ),
    );
    await dao.replaceMessages(
      conversationId: thread.id,
      rows: <AiMessagesCompanion>[
        for (int i = 0; i < thread.messages.length; i++)
          if (!thread.messages[i].pending && !thread.messages[i].needsApproval)
            AiMessagesCompanion.insert(
              id: thread.messages[i].id,
              conversationId: thread.id,
              role: Value<String>(
                thread.messages[i].isMine ? 'USER' : 'ASSISTANT',
              ),
              content: Value<String>(thread.messages[i].text),
              createdAt: Value<int>(now + i),
            ),
      ],
      fetchedAt: now,
    );
  }

  /// @notice Whether a transcript role is shown to the student.
  /// @param role Role from `/ai/history` (`human`, `ai`, `system`, ...).
  /// @return True for the two chat sides.
  bool _isTranscriptRole(String role) {
    final String value = role.toLowerCase();
    return value == 'human' ||
        value == 'user' ||
        value == 'ai' ||
        value == 'assistant';
  }

  /// @notice Maps a transcript role to the cache's `USER`/`ASSISTANT`.
  /// @param role Role from `/ai/history`.
  /// @return The cached role.
  String _roleOf(String role) {
    final String value = role.toLowerCase();
    return value == 'human' || value == 'user' ? 'USER' : 'ASSISTANT';
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
