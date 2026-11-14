/// @title AI chat provider
/// @notice Holds the Home AI overlay, active thread, and cached history.
/// @dev The overlay stays optimistic in memory: a prompt shows at once with a
/// pending AI bubble, and `POST /api/ai/chat/stream` replaces it as tokens
/// arrive. An interrupt stays unpersisted until the student approves or
/// rejects it through `POST /api/ai/chat/resume`. Finished exchanges are
/// cached through the {AiChatRepository}.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers/database_provider.dart';
import '../../core/network/api_exception.dart';
import '../../core/ui_bridge/ui_bridge.dart';
import '../../core/ui_bridge/ui_commands.dart';
import '../../data/chat/ai_chat_repository.dart';
import '../../models/chat/ai_thread.dart';
import '../../models/chat/ai_turn.dart';
import '../account/session_provider.dart';
import '../network/api_provider.dart';

/// @dev Home AI repository backed by the Drift cache and `/api/ai/*`.
final aiChatRepositoryProvider = Provider<AiChatRepository>(
  (ref) => AiChatRepository(
    dao: ref.watch(appDatabaseProvider).aiChatDao,
    api: ref.watch(apiClientProvider),
    currentUserId: ref.watch(currentUserIdProvider),
  ),
);

/// @dev Text of the bubble shown while an answer is on its way.
const String aiPendingText = 'AI sedang mengetik…';

/// @title AiPanelKind
/// @notice Which overlay sits above the AI composer.
enum AiPanelKind {
  /// @dev Composer only; the chat overlay is hidden.
  hidden,

  /// @dev Human and AI bubbles for the active thread.
  chat,

  /// @dev Replaces the chat overlay with the history list.
  history,
}

/// @title AiChatState
/// @notice Snapshot of the Home AI overlay and its threads.
class AiChatState {
  /// @notice Creates the overlay snapshot.
  /// @param composerOpen Whether the circle has expanded into the search-width
  /// bar.
  /// @param panel Chat, history, or hidden.
  /// @param panelMinimized Whether the panel is collapsed to title plus arrow.
  /// @param activeThreadId Thread shown in the chat overlay.
  /// @param threads History, newest first.
  /// @return A new {AiChatState} instance.
  const AiChatState({
    this.composerOpen = false,
    this.panel = AiPanelKind.hidden,
    this.panelMinimized = false,
    this.activeThreadId,
    this.threads = const <AiThread>[],
  });

  /// @dev Whether the circle has expanded into the search-width bar.
  final bool composerOpen;

  /// @dev Chat, history, or hidden.
  final AiPanelKind panel;

  /// @dev Whether the panel is collapsed to title plus arrow.
  final bool panelMinimized;

  /// @dev Thread shown in the chat overlay.
  final String? activeThreadId;

  /// @dev History, newest first.
  final List<AiThread> threads;

  /// @notice The active thread, or null when none is selected.
  AiThread? get activeThread {
    final String? id = activeThreadId;
    if (id == null) {
      return null;
    }
    for (final AiThread thread in threads) {
      if (thread.id == id) {
        return thread;
      }
    }
    return null;
  }

  /// @notice Copies this snapshot with selected fields replaced.
  /// @return A new {AiChatState}.
  AiChatState copyWith({
    bool? composerOpen,
    AiPanelKind? panel,
    bool? panelMinimized,
    String? activeThreadId,
    List<AiThread>? threads,
    bool clearActiveThread = false,
  }) {
    return AiChatState(
      composerOpen: composerOpen ?? this.composerOpen,
      panel: panel ?? this.panel,
      panelMinimized: panelMinimized ?? this.panelMinimized,
      activeThreadId: clearActiveThread
          ? null
          : (activeThreadId ?? this.activeThreadId),
      threads: threads ?? this.threads,
    );
  }
}

/// @title AiChatNotifier
/// @notice Mutates the Home AI overlay and persists appended exchanges.
class AiChatNotifier extends Notifier<AiChatState> {
  int _seq = 0;

  /// @notice Starts collapsed and hydrates the history from the cache.
  /// @return The initial {AiChatState}.
  @override
  AiChatState build() {
    unawaited(_hydrate());
    return const AiChatState();
  }

  Future<void> _hydrate() async {
    late final List<AiThread> threads;
    try {
      threads = await ref.read(aiChatRepositoryProvider).threadsOnce();
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      rethrow;
    }
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(threads: threads);
    await _syncThreads();
  }

  /// @notice Pulls the server's session list behind the cached one.
  /// @dev Best effort: offline, the cached history stays on screen.
  /// @return Future completing when the list is merged.
  Future<void> _syncThreads() async {
    final AiChatRepository repo = ref.read(aiChatRepositoryProvider);
    if (repo.currentUserId.isEmpty) {
      return;
    }
    try {
      await repo.refreshThreads();
    } on ApiException {
      return;
    }
    final List<AiThread> threads = await repo.threadsOnce();
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(threads: _keepLocal(threads));
  }

  /// @notice Merges server threads with ones only this device has so far.
  /// @param server Threads read back from the cache after a refresh.
  /// @return Server threads plus local ones the server has not listed yet.
  List<AiThread> _keepLocal(List<AiThread> server) {
    final Set<String> ids = server.map((AiThread t) => t.id).toSet();
    return <AiThread>[
      for (final AiThread thread in state.threads)
        if (!ids.contains(thread.id)) thread,
      ...server,
    ];
  }

  /// @notice Expands the circle into the search-width composer.
  /// @return void
  void openComposer() {
    state = state.copyWith(composerOpen: true);
  }

  /// @notice Opens the chat overlay for [threadId].
  /// @param threadId Identifier taken from {AiThread.id}.
  /// @return void
  void openThread(String threadId) {
    state = state.copyWith(
      composerOpen: true,
      panel: AiPanelKind.chat,
      panelMinimized: false,
      activeThreadId: threadId,
    );
    unawaited(_loadHistory(threadId));
  }

  /// @notice Fills a thread opened from history with its server transcript.
  /// @param threadId Thread id.
  /// @return Future completing when the thread is replaced.
  Future<void> _loadHistory(String threadId) async {
    final AiChatRepository repo = ref.read(aiChatRepositoryProvider);
    try {
      await repo.refreshHistory(threadId);
    } on ApiException {
      return;
    }
    final List<AiThread> cached = await repo.threadsOnce();
    if (!ref.mounted) {
      return;
    }
    for (final AiThread thread in cached) {
      if (thread.id == threadId && thread.messages.isNotEmpty) {
        _replace(thread);
      }
    }
  }

  /// @notice Replaces the chat overlay with the history list.
  /// @return void
  void openHistory() {
    state = state.copyWith(
      composerOpen: true,
      panel: AiPanelKind.history,
      panelMinimized: false,
    );
  }

  /// @notice Minimizes or expands the current overlay panel.
  /// @return void
  void togglePanelMinimized() {
    if (state.panel == AiPanelKind.hidden) {
      return;
    }
    state = state.copyWith(panelMinimized: !state.panelMinimized);
  }

  /// @notice Closes the composer and chat overlay back to the brain circle.
  /// @return void
  void close() {
    state = state.copyWith(
      composerOpen: false,
      panel: AiPanelKind.hidden,
      panelMinimized: false,
      clearActiveThread: true,
    );
  }

  /// @notice Sends [text] and opens the chat overlay with the AI answer.
  /// @param text Prompt typed in the composer.
  /// @return void
  void send(String text) {
    final String prompt = text.trim();
    if (prompt.isEmpty) {
      return;
    }
    final AiThread? current = state.activeThread;
    if (current == null || state.panel != AiPanelKind.chat) {
      _startThread(prompt);
      return;
    }
    _append(current, prompt);
  }

  /// @notice Re-prompts from [message] in the active thread.
  /// @param message Bubble whose Copy/Ulangi row was tapped.
  /// @return void
  void repeat(AiMessage message) {
    final AiThread? current = state.activeThread;
    if (current == null) {
      return;
    }
    String prompt = message.text;
    if (!message.isMine) {
      for (int i = current.messages.length - 1; i >= 0; i--) {
        if (current.messages[i].isMine) {
          prompt = current.messages[i].text;
          break;
        }
      }
    }
    _append(current, prompt);
  }

  void _startThread(String prompt) {
    _seq += 1;
    final String id = AiChatRepository.newConversationId();
    final String title = prompt.length > 28
        ? '${prompt.substring(0, 28)}…'
        : prompt;
    final AiThread thread = AiThread(
      id: id,
      title: title,
      preview: prompt,
      timeLabel: 'Baru',
      messages: <AiMessage>[
        AiMessage(id: '$id-h-$_seq', text: prompt, isMine: true),
        AiMessage(
          id: '$id-a-$_seq',
          text: aiPendingText,
          isMine: false,
          pending: true,
        ),
      ],
    );
    state = state.copyWith(
      composerOpen: true,
      panel: AiPanelKind.chat,
      panelMinimized: false,
      activeThreadId: id,
      threads: <AiThread>[thread, ...state.threads],
    );
    unawaited(_answer(id, prompt, '$id-a-$_seq'));
  }

  void _append(AiThread current, String prompt) {
    _seq += 1;
    final AiThread next = current.copyWith(
      preview: prompt,
      timeLabel: 'Baru',
      messages: <AiMessage>[
        ...current.messages,
        AiMessage(id: '${current.id}-h-$_seq', text: prompt, isMine: true),
        AiMessage(
          id: '${current.id}-a-$_seq',
          text: aiPendingText,
          isMine: false,
          pending: true,
        ),
      ],
    );
    state = state.copyWith(
      composerOpen: true,
      panel: AiPanelKind.chat,
      panelMinimized: false,
      activeThreadId: next.id,
    );
    _replace(next);
    unawaited(_answer(current.id, prompt, '${current.id}-a-$_seq'));
  }

  /// @notice Approves or rejects the chat action waiting on [bubbleId].
  /// @dev `POST /api/ai/chat/resume`. This never places a phone call.
  /// @param threadId Thread id.
  /// @param bubbleId Id of the approval bubble.
  /// @param approve True to let the chat action run.
  /// @return Future completing when the bubble shows the next answer.
  Future<void> decide({
    required String threadId,
    required String bubbleId,
    required bool approve,
  }) async {
    if (_bubble(threadId, bubbleId)?.needsApproval != true) {
      return;
    }
    _paint(
      threadId,
      bubbleId,
      text: aiPendingText,
      thinking: '',
      pending: true,
      needsApproval: false,
    );
    final AiChatRepository repo = ref.read(aiChatRepositoryProvider);
    String reply;
    try {
      final AiTurn turn = await repo.resume(
        conversationId: threadId,
        approve: approve,
      );
      reply = turn.answer.isEmpty
          ? (approve ? 'Disetujui.' : 'Ditolak.')
          : turn.answer;
    } on ApiException catch (error) {
      reply = error.userMessage;
    }
    if (!ref.mounted) {
      return;
    }
    _paint(
      threadId,
      bubbleId,
      text: reply,
      thinking: '',
      pending: false,
      needsApproval: false,
      persist: true,
    );
  }

  /// @notice Asks the backend and swaps the pending bubble for the result.
  /// @param threadId Thread id, sent as `conversation_id`.
  /// @param prompt The student's prompt.
  /// @param bubbleId Id of the pending AI bubble.
  /// @return Future completing when the bubble is settled.
  Future<void> _answer(String threadId, String prompt, String bubbleId) async {
    final AiChatRepository repo = ref.read(aiChatRepositoryProvider);
    String reply;
    String thinking = '';
    bool needsApproval = false;
    List<UiCallback> callbacks = const <UiCallback>[];
    try {
      final AiTurn turn = await repo.ask(
        conversationId: threadId,
        message: prompt,
        uiState: ref.read(uiBridgeProvider).toJson(),
        onPartial: (String nextThinking, String nextAnswer) {
          if (!ref.mounted) {
            return;
          }
          _paint(
            threadId,
            bubbleId,
            text: nextAnswer.isEmpty ? aiPendingText : nextAnswer,
            thinking: nextThinking,
            pending: true,
            needsApproval: false,
          );
        },
      );
      reply = turn.answer.isEmpty
          ? 'AI tidak mengirim jawaban.'
          : turn.answer;
      thinking = turn.thinking;
      needsApproval = turn.needsApproval;
      callbacks = turn.callbacks;
    } on ApiException catch (error) {
      reply = error.userMessage;
    }
    if (!ref.mounted) {
      return;
    }
    _paint(
      threadId,
      bubbleId,
      text: reply,
      thinking: thinking,
      pending: needsApproval,
      needsApproval: needsApproval,
      persist: !needsApproval,
    );
    if (needsApproval) {
      unawaited(_watchApproval(threadId, bubbleId));
    }
    if (callbacks.isNotEmpty) {
      ref.read(uiCommandsProvider.notifier).enqueue(callbacks);
    }
  }

  /// @notice Reads one approval wait. A resolved answer replaces the bubble.
  /// @param threadId Thread id.
  /// @param bubbleId Approval bubble id.
  /// @return Future completing when the wait returns.
  Future<void> _watchApproval(String threadId, String bubbleId) async {
    final ({String status, String answer}) waited;
    try {
      waited = await ref.read(aiChatRepositoryProvider).waitApproval(threadId);
    } on ApiException {
      return;
    }
    if (!ref.mounted || waited.status != 'resolved' || waited.answer.isEmpty) {
      return;
    }
    if (_bubble(threadId, bubbleId)?.needsApproval != true) {
      return;
    }
    _paint(
      threadId,
      bubbleId,
      text: waited.answer,
      thinking: '',
      pending: false,
      needsApproval: false,
      persist: true,
    );
  }

  AiMessage? _bubble(String threadId, String bubbleId) {
    for (final AiThread thread in state.threads) {
      if (thread.id != threadId) {
        continue;
      }
      for (final AiMessage message in thread.messages) {
        if (message.id == bubbleId) {
          return message;
        }
      }
    }
    return null;
  }

  void _paint(
    String threadId,
    String bubbleId, {
    required String text,
    required String thinking,
    required bool pending,
    required bool needsApproval,
    bool persist = false,
  }) {
    AiThread? thread;
    for (final AiThread item in state.threads) {
      if (item.id == threadId) {
        thread = item;
      }
    }
    if (thread == null) {
      return;
    }
    final AiThread settled = thread.copyWith(
      preview: text,
      messages: <AiMessage>[
        for (final AiMessage message in thread.messages)
          message.id == bubbleId
              ? AiMessage(
                  id: bubbleId,
                  text: text,
                  isMine: false,
                  pending: pending,
                  thinking: thinking,
                  needsApproval: needsApproval,
                )
              : message,
      ],
    );
    _replace(settled);
    if (persist) {
      unawaited(ref.read(aiChatRepositoryProvider).persistThread(settled));
    }
  }

  /// @notice Puts [thread] first in the list, replacing its old copy.
  /// @param thread Updated thread.
  /// @return void
  void _replace(AiThread thread) {
    state = state.copyWith(
      threads: <AiThread>[
        thread,
        for (final AiThread item in state.threads)
          if (item.id != thread.id) item,
      ],
    );
  }
}

/// @dev Session-scoped Home AI overlay, hydrated from the cache and the server.
final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
