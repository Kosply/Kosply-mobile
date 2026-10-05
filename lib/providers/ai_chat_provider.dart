/// @title AI chat provider
/// @notice Holds the Home AI overlay, active thread, and placeholder history.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/placeholder_ai_chat.dart';
import '../models/ai_thread.dart';

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
/// @notice Mutates the in-memory Home AI overlay.
class AiChatNotifier extends Notifier<AiChatState> {
  int _seq = 0;
  int _reply = 0;

  /// @notice Starts with the placeholder history and a collapsed circle.
  /// @return The initial {AiChatState}.
  @override
  AiChatState build() {
    return AiChatState(threads: PlaceholderAiChat.threads());
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

  /// @notice Sends [text] and opens the chat overlay with a lorem reply.
  /// @param text Prompt typed in the composer.
  /// @return void
  void send(String text) {
    final String prompt = text.trim();
    if (prompt.isEmpty) {
      return;
    }
    final String reply = PlaceholderAiChat.replyAt(_reply++);
    final AiThread? current = state.activeThread;
    if (current == null || state.panel != AiPanelKind.chat) {
      _startThread(prompt, reply);
      return;
    }
    _append(current, prompt, reply);
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
    final String reply = PlaceholderAiChat.replyAt(_reply++);
    _append(current, prompt, reply);
  }

  void _startThread(String prompt, String reply) {
    _seq += 1;
    final String id = 'ai-new-$_seq';
    final String title = prompt.length > 28
        ? '${prompt.substring(0, 28)}…'
        : prompt;
    final AiThread thread = AiThread(
      id: id,
      title: title,
      preview: reply,
      timeLabel: 'Baru',
      messages: <AiMessage>[
        AiMessage(id: '$id-h-$_seq', text: prompt, isMine: true),
        AiMessage(id: '$id-a-$_seq', text: reply, isMine: false),
      ],
    );
    state = state.copyWith(
      composerOpen: true,
      panel: AiPanelKind.chat,
      panelMinimized: false,
      activeThreadId: id,
      threads: <AiThread>[thread, ...state.threads],
    );
  }

  void _append(AiThread current, String prompt, String reply) {
    _seq += 1;
    final AiThread next = current.copyWith(
      preview: reply,
      timeLabel: 'Baru',
      messages: <AiMessage>[
        ...current.messages,
        AiMessage(id: '${current.id}-h-$_seq', text: prompt, isMine: true),
        AiMessage(id: '${current.id}-a-$_seq', text: reply, isMine: false),
      ],
    );
    final List<AiThread> threads = <AiThread>[
      next,
      for (final AiThread item in state.threads)
        if (item.id != current.id) item,
    ];
    state = state.copyWith(
      composerOpen: true,
      panel: AiPanelKind.chat,
      panelMinimized: false,
      activeThreadId: next.id,
      threads: threads,
    );
  }
}

/// @dev Session-scoped Home AI overlay. Starts with placeholder history.
final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
