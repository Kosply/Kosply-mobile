/// @title HelpDeskScreen
/// @notice FAQ list: tap a common problem to expand its answer.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../data/placeholder_help.dart';
import '../models/help_topic.dart';
import '../theme/kosply_colors.dart';
import '../widgets/phosphor_icons.dart';

/// @title HelpDeskScreen
/// @notice Help desk destination opened from Settings.
class HelpDeskScreen extends StatefulWidget {
  /// @notice Creates the help desk screen.
  /// @return A new {HelpDeskScreen} instance.
  const HelpDeskScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/help-desk';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the mutable expanded-topic state.
  /// @return The {_HelpDeskScreenState} instance.
  @override
  State<HelpDeskScreen> createState() => _HelpDeskScreenState();
}

/// @title _HelpDeskScreenState
/// @notice Holds which FAQ row is currently expanded.
class _HelpDeskScreenState extends State<HelpDeskScreen> {
  String? _expandedTitle;

  /// @notice Builds the expandable FAQ list.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final List<HelpTopic> topics = PlaceholderHelp.topics;

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: PhosphorGlyph(
            PhosphorCode.arrowLeft,
            size: 20,
            color: KosplyColors.textPrimaryOf(context),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Help desk',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: KosplyColors.textPrimaryOf(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: KosplyColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KosplyColors.outlineOf(context)),
            ),
            child: Column(
              children: [
                for (int i = 0; i < topics.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: KosplyColors.outlineOf(context),
                    ),
                  _HelpTopicRow(
                    topic: topics[i],
                    expanded: topics[i].title == _expandedTitle,
                    onTap: () {
                      setState(() {
                        _expandedTitle = topics[i].title == _expandedTitle
                            ? null
                            : topics[i].title;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// @title _HelpTopicRow
/// @notice One FAQ title that expands to show the answer.
class _HelpTopicRow extends StatelessWidget {
  const _HelpTopicRow({
    required this.topic,
    required this.expanded,
    required this.onTap,
  });

  final HelpTopic topic;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('help-topic-${topic.title}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    topic.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KosplyColors.textPrimaryOf(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Transform.rotate(
                  angle: expanded ? 1.57079632679 : 0,
                  child: PhosphorGlyph(
                    PhosphorCode.caretRight,
                    size: 16,
                    color: KosplyColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              Text(
                topic.answer,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: KosplyColors.textSecondaryOf(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
