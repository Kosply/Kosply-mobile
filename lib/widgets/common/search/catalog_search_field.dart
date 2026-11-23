/// @title Catalog search field
/// @notice Search pill on Home and Search.
/// @dev Typing stays in the field. Enter opens the search catalogue. An
/// `apply_filter` callback can still rewrite the text.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui_bridge/catalog_filter.dart';
import '../../../screens/main/search/search_catalog_screen.dart';
import 'searchbar.dart';

/// @title CatalogSearchField
/// @notice The catalogue search pill on Home and Search.
class CatalogSearchField extends ConsumerStatefulWidget {
  /// @notice Creates the bound search pill.
  /// @return A new {CatalogSearchField} instance.
  const CatalogSearchField({super.key});

  /// @notice Creates the controller state.
  /// @return The {_CatalogSearchFieldState} instance.
  @override
  ConsumerState<CatalogSearchField> createState() => _CatalogSearchFieldState();
}

/// @title _CatalogSearchFieldState
/// @notice Keeps the text controller aligned with the shared filter.
class _CatalogSearchFieldState extends ConsumerState<CatalogSearchField> {
  late final TextEditingController _controller;

  /// @notice Seeds the field from the shared filter.
  /// @return void
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(catalogFilterProvider).query,
    );
  }

  /// @notice Releases the controller.
  /// @return void
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// @notice Builds the pill and mirrors AI filter changes into the field.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The search pill.
  @override
  Widget build(BuildContext context) {
    ref.listen<CatalogFilter>(catalogFilterProvider, (
      CatalogFilter? previous,
      CatalogFilter next,
    ) {
      if (_controller.text != next.query) {
        _controller.text = next.query;
      }
    });
    return KosplySearchbar(
      key: const Key('catalog-search'),
      controller: _controller,
      focusNode: ref.watch(catalogSearchFocusProvider),
      showFilter: false,
      onSubmitted: (String value) {
        final String query = value.trim();
        if (query.isEmpty) {
          return;
        }
        FocusManager.instance.primaryFocus?.unfocus();
        // The feed stays on the shared filter. Put that text back so the
        // pill does not look like a live search after the results open.
        final String bound = ref.read(catalogFilterProvider).query;
        if (_controller.text != bound) {
          _controller.text = bound;
        }
        SearchCatalogScreen.push(context, query);
      },
    );
  }
}
