/// @title AuthScaffold
/// @notice Shared page shell for every auth and onboarding screen.
/// @dev Owns the white background, the wordmark app bar, the optional header
/// above the content, the scrollable body, and the pinned bottom bar. This
/// removes the duplicated scaffold + app bar + SafeArea + Column structure
/// that previously existed in each screen.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';
import 'kosply_wordmark.dart';

/// @title AuthScaffold
/// @notice Reusable scaffold with wordmark app bar and optional bottom bar.
class AuthScaffold extends StatelessWidget {
  /// @notice Creates the shared scaffold.
  /// @param body Main content of the screen.
  /// @param header Optional widget pinned above the body.
  /// @param bottomBar Optional widget pinned at the bottom.
  /// @param scrollable Whether to wrap [body] in a scroll view.
  /// @param contentPadding Padding around the body content.
  /// @param wordmarkWidth Width of the app bar wordmark.
  /// @param showAppBar Whether to show the wordmark app bar.
  /// @return A new {AuthScaffold} instance.
  const AuthScaffold({
    required this.body,
    this.header,
    this.bottomBar,
    this.scrollable = true,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
    this.wordmarkWidth = 110,
    this.showAppBar = true,
    super.key,
  });

  /// @dev Main content of the screen.
  final Widget body;

  /// @dev Optional widget pinned above the body.
  final Widget? header;

  /// @dev Optional widget pinned at the bottom.
  final Widget? bottomBar;

  /// @dev Whether to wrap [body] in a scroll view.
  final bool scrollable;

  /// @dev Padding around the body content.
  final EdgeInsets contentPadding;

  /// @dev Width of the app bar wordmark.
  final double wordmarkWidth;

  /// @dev Whether to show the wordmark app bar.
  final bool showAppBar;

  /// @notice Builds the shared page shell.
  /// @param context The build context.
  /// @return The scaffold widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KosplyColors.card,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: KosplyColors.card,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: KosplyWordmark(width: wordmarkWidth),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?header,
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: contentPadding,
                      child: body,
                    )
                  : body,
            ),
            ?bottomBar,
          ],
        ),
      ),
    );
  }
}