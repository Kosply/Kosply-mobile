/// @title InterestScreen
/// @notice "Apa yang kamu suka?" personalization picker for the home feed.
/// @dev Three cards per row using a {GridView}; each card is an
/// {InterestCategoryCard}. Built from {AuthScaffold}, {FormHeading}, and
/// {FormActions}; finishing the screen lands on {KosplyMainLayout}.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../layouts/main_layout.dart';
import '../models/interest_category.dart';
import '../theme/kosply_colors.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/form_actions.dart';
import '../widgets/form_heading.dart';
import '../widgets/interest_category_card.dart';

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
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: KosplyCategories.all.length,
        itemBuilder: (context, index) {
          final category = KosplyCategories.all[index];
          return InterestCategoryCard(
            category: category,
            selected: _selected.contains(category.title),
            onTap: () => _toggle(category.title),
          );
        },
      ),
      bottomBar: FormActions(
        onBack: () {},
        onContinue: () => Navigator.of(
          context,
        ).pushReplacementNamed(KosplyMainLayout.routeName),
        continueLabel: 'Start browsing',
        showBack: false,
      ),
    );
  }
}