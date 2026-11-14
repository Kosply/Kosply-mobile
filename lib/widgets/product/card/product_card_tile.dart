/// @title ProductCardTile
/// @notice Binds a [Product] to [ProductCard] and opens the detail screen.
/// @dev Keeps the field-by-field mapping and the navigation call in one place,
/// so lists only pass a [Product] and every card opens the same route.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui_bridge/ui_bridge.dart';
import '../../../core/ui_bridge/ui_commands.dart';
import '../../../core/ui_bridge/ui_ids.dart';
import '../../../models/catalog/product.dart';
import '../../../providers/catalog/catalog_events.dart';
import '../../../screens/seller/product/product_view_screen.dart';
import 'product_card.dart';

/// @title ProductCardTile
/// @notice Tappable catalogue card driven by a [Product].
class ProductCardTile extends ConsumerWidget {
  /// @notice Creates a tappable card.
  /// @param product Product to render.
  /// @param anchor Whether this card is the scroll target for its product.
  /// Only one mounted card per product may anchor, because the key is shared.
  /// @return A new {ProductCardTile} instance.
  const ProductCardTile({
    required this.product,
    this.anchor = true,
    this.eventSource = 'feed',
    super.key,
  });

  /// @dev Product to render.
  final Product product;

  /// @dev Whether this card is the scroll target for its product.
  final bool anchor;

  /// @dev Analytics source sent with the impression (`feed`, `search`, `detail`).
  final String eventSource;

  /// @notice Builds the card, outlined while the AI is pointing at it.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The card widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool highlighted = ref.watch(uiHighlightProvider) == product.id;
    final Widget card = ProductCard(
      title: product.title,
      price: product.price,
      location: product.location,
      imagePath: product.imagePath,
      highlighted: highlighted,
      onTap: () {
        ref
            .read(uiBridgeProvider.notifier)
            .recordClick(
              id: UiIds.product(product.id),
              kind: UiElementKinds.product,
            );
        ProductViewScreen.push(context, product.id);
      },
    );
    final Widget reported = _ImpressionOnce(
      productId: product.id,
      source: eventSource,
      child: card,
    );
    if (!anchor) {
      return reported;
    }
    return KeyedSubtree(
      key: ref.watch(uiAnchorsProvider).of(UiIds.product(product.id)),
      child: reported,
    );
  }
}

/// @dev Fires one impression after the card is on screen.
class _ImpressionOnce extends ConsumerStatefulWidget {
  const _ImpressionOnce({
    required this.productId,
    required this.source,
    required this.child,
  });

  final String productId;
  final String source;
  final Widget child;

  @override
  ConsumerState<_ImpressionOnce> createState() => _ImpressionOnceState();
}

class _ImpressionOnceState extends ConsumerState<_ImpressionOnce> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(catalogEventsProvider).impression(widget.productId, widget.source);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
