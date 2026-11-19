/// @title Markdown view
/// @notice Renders the subset of Markdown an AI answer actually uses.
/// @dev Headings, paragraphs, lists, fenced code, and inline bold, italic,
/// code, and links. Links stay text; the overlay does not open a browser.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

/// @title MarkdownView
/// @notice A chat-sized Markdown block painted in [color].
class MarkdownView extends StatelessWidget {
  /// @notice Creates a viewer for [data].
  /// @param data Markdown source.
  /// @param color Body colour. Bold and code reuse it.
  /// @param baseSize Body font size.
  /// @return A new {MarkdownView} instance.
  const MarkdownView({
    required this.data,
    required this.color,
    this.baseSize = 14,
    super.key,
  });

  /// @dev Markdown source.
  final String data;

  /// @dev Body colour.
  final Color color;

  /// @dev Body font size.
  final double baseSize;

  /// @notice Builds the block column.
  /// @param context The build context.
  /// @return The rendered Markdown.
  @override
  Widget build(BuildContext context) {
    final List<Widget> blocks = _blocks(data);
    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          blocks[i],
        ],
      ],
    );
  }

  TextStyle get _body =>
      TextStyle(fontSize: baseSize, height: 1.35, color: color);

  List<Widget> _blocks(String source) {
    final List<String> lines = source.replaceAll('\r\n', '\n').split('\n');
    final List<Widget> out = <Widget>[];
    int i = 0;
    while (i < lines.length) {
      final String line = lines[i];
      if (line.trim().isEmpty) {
        i += 1;
        continue;
      }
      if (line.trimLeft().startsWith('```')) {
        final List<String> code = <String>[];
        i += 1;
        while (i < lines.length && !lines[i].trimLeft().startsWith('```')) {
          code.add(lines[i]);
          i += 1;
        }
        if (i < lines.length) {
          i += 1;
        }
        out.add(_codeBlock(code.join('\n')));
        continue;
      }
      final RegExpMatch? heading = RegExp(r'^(#{1,3})\s+(.*)$')
          .firstMatch(line);
      if (heading != null) {
        out.add(_heading(heading.group(1)!.length, heading.group(2)!));
        i += 1;
        continue;
      }
      if (_list.hasMatch(line)) {
        final List<String> items = <String>[];
        while (i < lines.length && _list.hasMatch(lines[i])) {
          items.add(lines[i].replaceFirst(_list, ''));
          i += 1;
        }
        out.add(_listBlock(items));
        continue;
      }
      final List<String> para = <String>[];
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          !lines[i].trimLeft().startsWith('```') &&
          !RegExp(r'^(#{1,3})\s+').hasMatch(lines[i]) &&
          !_list.hasMatch(lines[i])) {
        para.add(lines[i].trim());
        i += 1;
      }
      out.add(_rich(para.join(' '), _body));
    }
    return out;
  }

  Widget _heading(int level, String text) {
    final double size = switch (level) {
      1 => baseSize + 4,
      2 => baseSize + 2,
      _ => baseSize + 1,
    };
    return _rich(
      text,
      _body.copyWith(fontSize: size, fontWeight: FontWeight.w700),
    );
  }

  Widget _listBlock(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: _body),
              Expanded(child: _rich(items[i], _body)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _codeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: _body.copyWith(fontFamily: 'monospace', fontSize: baseSize - 1),
      ),
    );
  }

  Widget _rich(String text, TextStyle style) {
    return Text.rich(TextSpan(children: _inline(text, style)));
  }

  List<InlineSpan> _inline(String text, TextStyle style) {
    final List<InlineSpan> spans = <InlineSpan>[];
    int cursor = 0;
    for (final RegExpMatch match in _inlinePattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(text: text.substring(cursor, match.start), style: style),
        );
      }
      final String? code = match.group(1);
      final String? bold = match.group(2) ?? match.group(3);
      final String? italic = match.group(4) ?? match.group(5);
      final String? link = match.group(6);
      if (code != null) {
        spans.add(
          TextSpan(
            text: code,
            style: style.copyWith(
              fontFamily: 'monospace',
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        );
      } else if (bold != null) {
        spans.add(
          TextSpan(
            text: bold,
            style: style.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else if (italic != null) {
        spans.add(
          TextSpan(
            text: italic,
            style: style.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (link != null) {
        spans.add(
          TextSpan(
            text: link,
            style: style.copyWith(decoration: TextDecoration.underline),
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: style));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: style));
    }
    return spans;
  }
}

final RegExp _list = RegExp(r'^\s*(?:[-*+]|\d+\.)\s+');

final RegExp _inlinePattern = RegExp(
  r'`([^`]+)`|\*\*([^*]+)\*\*|__([^_]+)__|(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)_([^_]+)_(?!_)|\[([^\]]+)\]\([^)]+\)',
);
