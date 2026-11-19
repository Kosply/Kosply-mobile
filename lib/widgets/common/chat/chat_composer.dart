/// @title ChatComposer
/// @notice Bottom input shared by COD chat and support tickets.
/// @dev The keyboard's send action posts the text. While a send runs the
/// field stays disabled, so a double tap cannot post the bubble twice, and
/// the text is only cleared after the backend accepted it. The plus control
/// offers location and photo only when the screen supplies those callbacks,
/// and both send immediately with nothing left in the field.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../../../theme/colors/kosply_colors.dart';
import '../icons/phosphor_icons.dart';

/// @title ChatComposer
/// @notice Attach, text, and send controls.
class ChatComposer extends StatefulWidget {
  /// @notice Creates the composer.
  /// @param onSend Sends the text; throws to keep it in the field.
  /// @param onSendLocation Sends the current pin immediately.
  /// @param onSendPhoto Opens the camera and sends the shot immediately.
  /// @param hint Placeholder text.
  /// @return A new {ChatComposer} instance.
  const ChatComposer({
    required this.onSend,
    this.onSendLocation,
    this.onSendPhoto,
    this.hint = 'Tulis pesan...',
    super.key,
  });

  /// @dev Sends the text; throws to keep it in the field.
  final Future<void> Function(String text) onSend;

  /// @dev Sends the current pin immediately. Null hides that choice.
  final Future<void> Function()? onSendLocation;

  /// @dev Sends one photo immediately. Null hides that choice.
  final Future<void> Function()? onSendPhoto;

  /// @dev Placeholder text.
  final String hint;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _text = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _text.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }
    setState(() => _sending = true);
    try {
      await widget.onSend(text);
      _text.clear();
    } catch (_) {
      // The screen already explained the failure; the text stays for a retry.
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  /// @notice Opens location and photo. The chosen one sends at once.
  /// @return void
  Future<void> _attach() async {
    if (_sending) {
      return;
    }
    if (widget.onSendLocation == null && widget.onSendPhoto == null) {
      return;
    }
    final String? picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: KosplyColors.surfaceOf(context),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onSendLocation != null)
                ListTile(
                  key: const Key('chat-attach-location'),
                  title: const Text('Kirim lokasi saat ini'),
                  onTap: () => Navigator.of(sheetContext).pop('location'),
                ),
              if (widget.onSendPhoto != null)
                ListTile(
                  key: const Key('chat-attach-photo'),
                  title: const Text('Kirim foto'),
                  onTap: () => Navigator.of(sheetContext).pop('photo'),
                ),
            ],
          ),
        );
      },
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _sending = true);
    try {
      if (picked == 'location') {
        await widget.onSendLocation?.call();
      } else if (picked == 'photo') {
        await widget.onSendPhoto?.call();
      }
    } catch (_) {
      // The screen already explained the failure.
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color surface = KosplyColors.surfaceOf(context);
    final Color outline = KosplyColors.outlineOf(context);
    final Color iconColor = KosplyColors.textPrimaryOf(context);
    final bool hasText = _text.text.trim().isNotEmpty;

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
                onPressed: _attach,
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
                      controller: _text,
                      enabled: !_sending,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      cursorColor: KosplyColors.primary,
                      style: TextStyle(
                        fontSize: 14,
                        color: KosplyColors.textPrimaryOf(context),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: KosplyColors.textSecondaryOf(context),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (hasText)
                _ComposerIcon(
                  key: const Key('chat-send'),
                  codePoint: PhosphorCode.paperPlaneTilt,
                  color: KosplyColors.primary,
                  onPressed: _send,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// @title _ComposerIcon
/// @notice Circular plus or send control.
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
