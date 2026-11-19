/// @title Search catalogue
/// @notice Results opened from Home or Search after the student presses Enter.
/// @dev The grid follows the submitted query. Further typing waits for the
/// next Enter, so the cards do not reload on every letter.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/device_location.dart';
import '../../../core/location/nearby.dart';
import '../../../core/ui_bridge/catalog_filter.dart';
import '../../../core/ui_bridge/catalog_sort.dart';
import '../../../core/ui_bridge/ui_bridge.dart';
import '../../../core/ui_bridge/ui_bridge_scope.dart';
import '../../../core/ui_bridge/ui_ids.dart';
import '../../../models/catalog/product.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../providers/location/location_label_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/empty/empty_state_card.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';
import '../../../widgets/common/search/searchbar.dart';
import '../../../widgets/product/grid/product_grid.dart';

/// @title SearchCatalogScreen
/// @notice Back, a search field, and the cards for the current query.
class SearchCatalogScreen extends ConsumerStatefulWidget {
  /// @notice Creates the results screen.
  /// @param query Text submitted from Home or Search.
  /// @return A new {SearchCatalogScreen} instance.
  const SearchCatalogScreen({required this.query, super.key});

  /// @dev Named route for this screen.
  static const routeName = '/search-catalog';

  /// @dev Text submitted from Home or Search.
  final String query;

  /// @notice Pushes the results for [query].
  /// @param context The build context.
  /// @param query Submitted search text.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context, String query) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => SearchCatalogScreen(query: query),
      ),
    );
  }

  /// @notice Creates the query state.
  /// @return The {_SearchCatalogScreenState} instance.
  @override
  ConsumerState<SearchCatalogScreen> createState() =>
      _SearchCatalogScreenState();
}

/// @title _SearchCatalogScreenState
/// @notice Holds the submitted query separately from the field text.
class _SearchCatalogScreenState extends ConsumerState<SearchCatalogScreen> {
  late final TextEditingController _controller;
  late String _query;
  CatalogSort? _sort;

  /// @notice Seeds the field from the submitted query.
  /// @return void
  @override
  void initState() {
    super.initState();
    _query = widget.query.trim();
    _controller = TextEditingController(text: _query);
  }

  /// @notice Releases the controller.
  /// @return void
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// @notice Applies [value] as the next result query.
  /// @param value Text in the field when Enter was pressed.
  /// @return void
  void _submit(String value) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _query = value.trim());
  }

  /// @notice Opens the four sort choices.
  /// @return void
  Future<void> _openFilter() async {
    final CatalogSort? picked = await showModalBottomSheet<CatalogSort>(
      context: context,
      backgroundColor: KosplyColors.surfaceOf(context),
      builder: (BuildContext sheetContext) {
        TextStyle styleFor(bool selected) {
          return TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected
                ? KosplyColors.primary
                : KosplyColors.textPrimaryOf(sheetContext),
          );
        }

        return SafeArea(
          child: Column(
            key: const Key('search-filter-sheet'),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final CatalogSort sort in CatalogSort.values)
                ListTile(
                  key: Key('search-sort-${sort.name}'),
                  title: Text(sort.label, style: styleFor(_sort == sort)),
                  onTap: () => Navigator.of(sheetContext).pop(sort),
                ),
            ],
          ),
        );
      },
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _sort = picked);
  }

  /// @notice Builds the back row, the field, and the matching cards.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    ref.watch(catalogSyncProvider);
    final List<Product> catalogue =
        ref.watch(catalogProductsProvider).value ?? const <Product>[];
    final DeviceFix? fix = ref.watch(deviceFixProvider);
    final List<Product> matched = catalogue
        .where(CatalogFilter(query: _query).allows)
        .toList();
    final CatalogSort? sort = _sort;
    final List<Product> items = sort == null
        ? nearestFirst(matched, fix: fix)
        : sortCatalogue(matched, sort, fix: fix);
    final Color onShell = KosplyColors.textPrimaryOf(context);

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          key: const Key('search-catalog-back'),
          icon: PhosphorGlyph(PhosphorCode.arrowLeft, size: 20, color: onShell),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: KosplySearchbar(
            key: const Key('search-catalog-input'),
            controller: _controller,
            onFilter: _openFilter,
            onSubmitted: _submit,
          ),
        ),
      ),
      body: UiBridgeScope(
        screen: 'search_catalog',
        selection: <String, Object?>{if (_query.isNotEmpty) 'query': _query},
        elements: <UiElement>[
          UiElement(
            id: UiIds.input('search'),
            kind: UiElementKinds.input,
            label: 'Cari',
          ),
          for (final Product item in items.take(24))
            UiElement.product(item.id, label: item.title),
        ],
        child: ListView(
          key: const Key('search-catalog-scroll'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          children: [
            if (items.isEmpty)
              const EmptyStateCard(
                key: Key('search-catalog-empty'),
                icon: PhosphorCode.package,
                message: 'Tidak ada barang untuk pencarian ini.',
              )
            else
              ProductGrid(items: items, eventSource: 'search'),
          ],
        ),
      ),
    );
  }
}
