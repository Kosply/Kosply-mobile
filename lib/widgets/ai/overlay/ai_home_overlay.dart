/// @title Home AI overlay
/// @notice Floating brain circle on the right that expands into a
/// search-width composer with a chat or history panel stacked above it.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/chat/ai_thread.dart';
import '../../../models/chat/listing_proposal.dart';
import '../../../providers/chat/ai_chat_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../history/ai_history_tile.dart';
import '../markdown/markdown_view.dart';
import '../../common/icons/phosphor_icons.dart';
import 'ai_overlay_layer.dart';

/// @title AiHomeOverlay
/// @notice Bottom-right AI composer and the overlay stacked above it.
class AiHomeOverlay extends ConsumerStatefulWidget {
  /// @notice Creates the Home AI overlay.
  /// @return A new {AiHomeOverlay} instance.
  const AiHomeOverlay({super.key});

  /// @notice Creates the composer text state.
  /// @return The {_AiHomeOverlayState} instance.
  @override
  ConsumerState<AiHomeOverlay> createState() => _AiHomeOverlayState();
}

/// @title _AiHomeOverlayState
/// @notice Owns the prompt field for the expanded composer.
class _AiHomeOverlayState extends ConsumerState<AiHomeOverlay> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _controller.text;
    ref.read(aiChatProvider.notifier).send(text);
    _controller.clear();
  }

  /// @notice Builds the stacked composer and panel.
  /// @param context The build context.
  /// @return The overlay widget.
  @override
  Widget build(BuildContext context) {
    final AiChatState ai = ref.watch(aiChatProvider);
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final double safe = MediaQuery.paddingOf(context).bottom;
    final double gap = ref.watch(aiOverlayGapProvider);
    final double inset = keyboard > safe ? keyboard : safe;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + inset + gap),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ai.panel != AiPanelKind.hidden) ...[
            _AiPanel(state: ai),
            const SizedBox(height: 8),
          ],
          if (ai.composerOpen)
            _ComposerBar(controller: _controller, onSend: _send)
          else
            const Align(
              alignment: Alignment.centerRight,
              child: _ComposerFab(),
            ),
        ],
      ),
    );
  }
}

/// @title _ComposerFab
/// @notice Collapsed circular brain control, sitting on the right.
class _ComposerFab extends ConsumerWidget {
  const _ComposerFab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: KosplyColors.primary.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        key: const Key('ai-fab'),
        customBorder: const CircleBorder(),
        onTap: () => ref.read(aiChatProvider.notifier).openComposer(),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: PhosphorGlyph(
              PhosphorCode.brain,
              size: 22,
              color: KosplyColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// @title _ComposerBar
/// @notice Expanded prompt bar matching {KosplySearchbar} width and height.
class _ComposerBar extends ConsumerWidget {
  const _ComposerBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: KosplyColors.surfaceOf(context),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        key: const Key('ai-composer'),
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: KosplyColors.outlineOf(context)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('ai-input'),
                controller: controller,
                cursorColor: KosplyColors.primary,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: TextStyle(
                  fontSize: 13,
                  color: KosplyColors.textPrimaryOf(context),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Tanya Kosply AI...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: KosplyColors.textSecondaryOf(context),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            _ComposerIcon(
              key: const Key('ai-history'),
              codePoint: PhosphorCode.chats,
              onPressed: () => ref.read(aiChatProvider.notifier).openHistory(),
            ),
            _ComposerIcon(
              key: const Key('ai-send'),
              codePoint: PhosphorCode.paperPlaneTilt,
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}

/// @title _ComposerIcon
/// @notice Round control inside the expanded AI bar.
class _ComposerIcon extends StatelessWidget {
  const _ComposerIcon({
    required this.codePoint,
    required this.onPressed,
    super.key,
  });

  final int codePoint;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: PhosphorGlyph(
            codePoint,
            size: 18,
            color: KosplyColors.primary,
          ),
        ),
      ),
    );
  }
}

/// @title _AiPanel
/// @notice Chat or history overlay stacked above the composer.
class _AiPanel extends ConsumerWidget {
  const _AiPanel({required this.state});

  final AiChatState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool history = state.panel == AiPanelKind.history;
    final String title = history
        ? 'chat history'
        : (state.activeThread?.title ?? 'Kosply AI');
    final double bodyHeight = (MediaQuery.sizeOf(context).height * 0.32).clamp(
      160.0,
      280.0,
    );

    return Material(
      color: KosplyColors.surfaceOf(context),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        key: const Key('ai-panel'),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KosplyColors.outlineOf(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PanelHeader(title: title, minimized: state.panelMinimized),
            if (!state.panelMinimized)
              SizedBox(
                height: bodyHeight,
                child: history
                    ? _HistoryBody(threads: state.threads)
                    : _ChatBody(thread: state.activeThread),
              ),
          ],
        ),
      ),
    );
  }
}

/// @title _PanelHeader
/// @notice Title on the left, minimize arrow on the right.
class _PanelHeader extends ConsumerWidget {
  const _PanelHeader({required this.title, required this.minimized});

  final String title;
  final bool minimized;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 4, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: KosplyColors.textPrimaryOf(context),
                ),
              ),
            ),
            IconButton(
              key: const Key('ai-panel-toggle'),
              visualDensity: VisualDensity.compact,
              onPressed: () =>
                  ref.read(aiChatProvider.notifier).togglePanelMinimized(),
              icon: PhosphorGlyph(
                minimized ? PhosphorCode.caretUp : PhosphorCode.caretDown,
                size: 16,
                color: KosplyColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// @title _HistoryBody
/// @notice Scrollable list that replaces the chat overlay.
class _HistoryBody extends ConsumerWidget {
  const _HistoryBody({required this.threads});

  final List<AiThread> threads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: threads.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 1, color: KosplyColors.outlineOf(context));
      },
      itemBuilder: (BuildContext context, int index) {
        final AiThread thread = threads[index];
        return AiHistoryTile(
          key: Key('ai-history-row-${thread.id}'),
          thread: thread,
          onTap: () => ref.read(aiChatProvider.notifier).openThread(thread.id),
        );
      },
    );
  }
}

/// @title _ChatBody
/// @notice Human and AI bubbles. Copy and Ulangi sit under a finished AI answer.
class _ChatBody extends StatelessWidget {
  const _ChatBody({required this.thread});

  final AiThread? thread;

  @override
  Widget build(BuildContext context) {
    final List<AiMessage> messages = thread?.messages ?? const <AiMessage>[];
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Tanya Kosply AI...',
          style: TextStyle(
            fontSize: 13,
            color: KosplyColors.textSecondaryOf(context),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < messages.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _AiBubble(threadId: thread?.id ?? '', message: messages[i]),
          ],
        ],
      ),
    );
  }
}

/// @title _AiBubble
/// @notice One human or AI bubble.
/// @dev Reasoning sits in its own dropdown. A chat action shows the message
/// preview, then asks before anything is sent. The answer bubble appears
/// under that. Copy and Ulangi appear only after the answer is finished.
/// Setujui sends the preview. Tolak does not. There is no call button.
class _AiBubble extends ConsumerWidget {
  const _AiBubble({required this.threadId, required this.message});

  final String threadId;
  final AiMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool mine = message.isMine;
    final Color bubbleColor = mine
        ? KosplyColors.primary
        : (KosplyColors.isDark(context)
              ? KosplyColors.darkSurface
              : const Color(0xFFF3F4F6));
    final Color textColor = mine
        ? Colors.white
        : KosplyColors.textPrimaryOf(context);

    final bool showActions =
        !mine && !message.pending && message.text.isNotEmpty;
    final bool thinking = !mine && message.thinking.isNotEmpty;
    final bool typingOnly = message.text == aiPendingText;
    final bool showAnswer = mine || (message.text.isNotEmpty && !typingOnly);

    return Column(
      crossAxisAlignment: mine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (thinking) ...[
          _ThinkingDropdown(
            id: message.id,
            text: message.thinking,
            live: message.pending && typingOnly,
          ),
          if (showAnswer ||
              message.draft.isNotEmpty ||
              message.proposal != null)
            const SizedBox(height: 8),
        ],
        if (!mine && message.proposal != null) ...[
          _ListingPreview(proposal: message.proposal!),
          if (showAnswer) const SizedBox(height: 8),
        ],
        if (!mine && message.draft.isNotEmpty) ...[
          _DraftPreview(text: message.draft),
          if (showAnswer) const SizedBox(height: 8),
        ],
        if (showAnswer)
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: mine
                ? Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: textColor,
                    ),
                  )
                : MarkdownView(data: message.text, color: textColor),
          ),
        if (!mine &&
            message.pending &&
            !message.needsApproval &&
            message.text != aiPendingText) ...[
          const SizedBox(height: 6),
          Text(
            'Mengirim…',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KosplyColors.textSecondaryOf(context),
            ),
          ),
        ],
        if (message.needsApproval) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                key: const Key('ai-approve'),
                onPressed: () => ref
                    .read(aiChatProvider.notifier)
                    .decide(
                      threadId: threadId,
                      bubbleId: message.id,
                      approve: true,
                    ),
                child: const Text('Setujui'),
              ),
              TextButton(
                key: const Key('ai-reject'),
                onPressed: () => ref
                    .read(aiChatProvider.notifier)
                    .decide(
                      threadId: threadId,
                      bubbleId: message.id,
                      approve: false,
                    ),
                child: const Text('Tolak'),
              ),
            ],
          ),
        ],
        if (showActions) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BubbleAction(
                key: Key('ai-copy-${message.id}'),
                icon: PhosphorCode.copy,
                label: 'Copy',
                onTap: () =>
                    Clipboard.setData(ClipboardData(text: message.text)),
              ),
              const SizedBox(width: 12),
              _BubbleAction(
                key: Key('ai-repeat-${message.id}'),
                icon: PhosphorCode.arrowClockwise,
                label: 'Ulangi',
                onTap: () => ref.read(aiChatProvider.notifier).repeat(message),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// @title _ListingPreview
/// @notice The seller fields Setujui will write. Nothing is published here.
class _ListingPreview extends StatelessWidget {
  const _ListingPreview({required this.proposal});

  final ListingProposal proposal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: DecoratedBox(
        key: const Key('ai-listing-preview'),
        decoration: BoxDecoration(
          color: KosplyColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KosplyColors.outlineOf(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview barang',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: KosplyColors.textSecondaryOf(context),
                ),
              ),
              const SizedBox(height: 8),
              _PreviewLine(label: 'Nama', value: proposal.title),
              _PreviewLine(label: 'Harga', value: _rupiahLabel(proposal.price)),
              _PreviewLine(label: 'Kategori', value: proposal.category),
              _PreviewLine(label: 'Deskripsi', value: proposal.description),
            ],
          ),
        ),
      ),
    );
  }
}

/// @title _PreviewLine
/// @notice One labelled line inside the form preview.
class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: KosplyColors.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: label == 'Deskripsi' ? 6 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: KosplyColors.textPrimaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// @notice Groups an integer rupiah amount with dots.
/// @param price Whole rupiah.
/// @return `Rp85.000` for 85000.
String _rupiahLabel(int price) {
  final String digits = price.toString();
  final StringBuffer out = StringBuffer('Rp');
  for (int i = 0; i < digits.length; i++) {
    final int remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) {
      out.write('.');
    }
    out.write(digits[i]);
  }
  return out.toString();
}

/// @title _DraftPreview
/// @notice The exact chat line that Setujui will send.
class _DraftPreview extends StatelessWidget {
  const _DraftPreview({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KosplyColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KosplyColors.outlineOf(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview pesan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: KosplyColors.textSecondaryOf(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                key: const Key('ai-draft'),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: KosplyColors.textPrimaryOf(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// @title _ThinkingDropdown
/// @notice Card that holds the model's reasoning, apart from the answer bubble.
/// @dev While the answer has not started, the card stays open. It closes once
/// the answer arrives. A tap opens or closes it after that.
class _ThinkingDropdown extends StatefulWidget {
  const _ThinkingDropdown({
    required this.id,
    required this.text,
    required this.live,
  });

  final String id;
  final String text;

  /// @dev True while reasoning is still streaming and the answer is not here.
  final bool live;

  @override
  State<_ThinkingDropdown> createState() => _ThinkingDropdownState();
}

class _ThinkingDropdownState extends State<_ThinkingDropdown> {
  bool? _userOpen;

  bool get _open => _userOpen ?? widget.live;

  @override
  void didUpdateWidget(covariant _ThinkingDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.live && !widget.live) {
      _userOpen = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool open = _open;
    final Color color = KosplyColors.textSecondaryOf(context);
    final Color onShell = KosplyColors.textPrimaryOf(context);
    return SizedBox(
      width: 280,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KosplyColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KosplyColors.outlineOf(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              key: Key('ai-thinking-${widget.id}'),
              onTap: () => setState(() => _userOpen = !open),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    PhosphorGlyph(
                      open ? PhosphorCode.caretUp : PhosphorCode.caretDown,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Proses berpikir',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: onShell,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (open) ...[
              Divider(height: 1, color: KosplyColors.outlineOf(context)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// @title _BubbleAction
/// @notice Small icon-plus-label control under a chat bubble.
class _BubbleAction extends StatelessWidget {
  const _BubbleAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final int icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = KosplyColors.textSecondaryOf(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorGlyph(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
