/// @title InterestScreen
/// @notice "Apa yang kamu suka?" personalization picker for the home feed.
/// @dev Three cards per row; each card is an {InterestCategoryCard}. Built
/// from {AuthScaffold}, {FormHeading}, and {FormActions}; finishing the
/// screen lands on {KosplyMainLayout}.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../../../layouts/main_layout.dart';
import '../../../models/catalog/interest_category.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/auth/scaffold/auth_scaffold.dart';
import '../../../widgets/auth/form/form_actions.dart';
import '../../../widgets/auth/form/form_heading.dart';
import '../../../widgets/auth/onboarding/interest_category_card.dart';

/// @title InterestScreen
/// @notice Stateful grid of selectable interest cards.
class InterestScreen extends StatefulWidget {
  /// @notice Creates the interest picker screen.
  /// @param key Optional widget key.
  /// @return A new {InterestScreen} instance.
  const InterestScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/interest';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the mutable state.
  /// @return The {_InterestScreenState} instance.
  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

/// @title _InterestScreenState
/// @notice Mutable state for {InterestScreen}.
/// @dev Holds the set of selected category titles.
class _InterestScreenState extends State<InterestScreen> {
  /// @dev Cards per row.
  static const int _perRow = 3;

  /// @dev Titles of the currently selected cards.
  final Set<String> _selected = <String>{};

  /// @notice Toggles a card selection.
  /// @param title The category title.
  /// @return void
  void _toggle(String title) {
    setState(() {
      if (!_selected.remove(title)) {
        _selected.add(title);
      }
    });
  }

  /// @notice Builds one row of up to [_perRow] cards.
  /// @dev Rows size to their tallest card instead of a fixed aspect ratio,
  /// so narrow phones and larger system fonts never clip the description.
  /// @param start Index of the first category in the row.
  /// @return The row widget.
  Widget _buildRow(int start) {
    const List<InterestCategory> all = KosplyCategories.all;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = start; i < start + _perRow; i++) ...[
            if (i > start) const SizedBox(width: 12),
            Expanded(
              child: i < all.length
                  ? InterestCategoryCard(
                      category: all[i],
                      selected: _selected.contains(all[i].title),
                      onTap: () => _toggle(all[i].title),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  /// @notice Builds the interest grid.
  /// @dev Three cards per row, scrollable, Continue pinned at the bottom.
  /// @param context The build context.
  /// @return The interest screen widget.
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      header: const Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormHeading('What are you into?', topGap: 0),
            SizedBox(height: 6),
            Text(
              'Pick a few and we will tune your feed around them.',
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: KosplyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      scrollable: false,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        children: [
          for (
            int start = 0;
            start < KosplyCategories.all.length;
            start += _perRow
          ) ...[if (start > 0) const SizedBox(height: 12), _buildRow(start)],
        ],
      ),
      bottomBar: FormActions(
        onBack: () {},
        onContinue: () =>
            Navigator.of(context)
                .pushReplacementNamed(KosplyMainLayout.routeName),
        continueLabel: 'Start browsing',
        showBack: false,
      ),
    );
  }
}
