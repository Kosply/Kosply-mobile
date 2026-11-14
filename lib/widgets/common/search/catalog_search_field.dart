/// @title Catalog search field
/// @notice Search pill bound to {catalogFilterProvider}, so typing and an
/// `apply_filter` callback edit the same query.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui_bridge/catalog_filter.dart';
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
      controller: _controller,
      focusNode: ref.watch(catalogSearchFocusProvider),
      onChanged: (String value) =>
          ref.read(catalogFilterProvider.notifier).setQuery(value),
    );
  }
}
