/// @title ProductViewScreen
/// @notice Detail view of a single catalogue item.
/// @dev Receives only a product id and resolves the rest through the cached
/// catalogue, refreshed from `GET /api/products/:id` on open. The hero and the
/// thumbnail strip stay in sync. Chat sits in a pinned bar so the title and
/// price can read as a block; it opens (or reuses) the buyer's room for this
/// product through `POST /api/conversations`.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/nearby.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/ui_bridge/ui_bridge.dart';
import '../../../core/ui_bridge/ui_bridge_scope.dart';
import '../../../core/ui_bridge/ui_ids.dart';
import '../../../models/catalog/product.dart';
import '../../../models/catalog/seller.dart';
import '../../../models/catalog/product_stats.dart';
import '../../../providers/account/session_provider.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../providers/location/location_label_provider.dart';
import '../../../providers/catalog/favorites_provider.dart';
import '../../../providers/catalog/seller_analytics_provider.dart';
import '../../../providers/inbox/inbox_providers.dart';
import '../../reports/report_sheet.dart';
import 'product_actions.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/seller/chat/chat_seller_bar.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';
import '../../../widgets/product/grid/product_grid.dart';
import '../../../widgets/common/headings/section_heading.dart';
import '../../../widgets/seller/identity/seller_identity.dart';
import '../../main/inbox/chat_detail_screen.dart';
import '../detail/seller_detail_screen.dart';
import '../../../widgets/ai/overlay/ai_overlay_layer.dart';
import '../../../widgets/common/images/kosply_image.dart';

/// @title ProductViewScreen
/// @notice Product detail screen.
class ProductViewScreen extends ConsumerWidget {
  /// @notice Creates the detail screen.
  /// @param productId Identifier of the product to show.
  /// @return A new {ProductViewScreen} instance.
  const ProductViewScreen({required this.productId, super.key});

  /// @dev Named route for this screen.
  static const routeName = '/product';

  /// @dev Identifier of the product to show.
  final String productId;

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @param productId Identifier of the product to show.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context, String productId) {
    return Navigator.of(context).pushNamed(routeName, arguments: productId);
  }

  /// @notice Opens the buyer's room for this product, then the chat.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return Future completing when navigation starts.
  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    final String roomId;
    try {
      roomId = await ref
          .read(inboxRepositoryProvider)
          .openForProduct(productId);
    } on ApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
      return;
    }
    if (context.mounted && roomId.isNotEmpty) {
      await ChatDetailScreen.push(context, roomId);
    }
  }

  /// @notice Builds the product detail.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(productSyncProvider(productId));
    final Product? product = ref.watch(catalogProductProvider(productId)).value;
    if (product == null) {
      return const _MissingProduct();
    }
    final List<Product> related = nearestFirst(
      ref
              .watch(catalogProductsProvider)
              .value
              ?.where((Product item) => item.id != productId)
              .toList() ??
          const <Product>[],
      fix: ref.watch(deviceFixProvider),
    ).take(4).toList();
    final bool mine =
        product.sellerId.isNotEmpty &&
        product.sellerId == ref.watch(currentUserIdProvider);
    final ProductStats? stats = mine
        ? ref.watch(productStatsProvider(productId)).value
        : null;

    return RouteGapHost(
      gap: kBottomBarGap,
      child: Scaffold(
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
          actions: [
            _FavoriteButton(productId: productId),
            IconButton(
              key: const Key('product-more'),
              icon: PhosphorGlyph(
                PhosphorCode.dotsThree,
                weight: PhosphorWeight.bold,
                size: 20,
                color: KosplyColors.textPrimaryOf(context),
              ),
              onPressed: () async {
                if (mine) {
                  final bool gone = await showListingActions(
                    context,
                    ref,
                    product,
                  );
                  if (gone && context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                  return;
                }
                await showReportSheet(
                  context,
                  productId: product.id,
                  userId: product.sellerId,
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: UiBridgeScope(
          screen: 'product_view',
          elements: <UiElement>[
            UiElement.product(product.id, label: product.title),
            UiElement.button(
              'chat',
              label: 'Chat penjual',
              target: product.sellerId,
              callback: UiCallbacks.openChat,
              args: <String, Object?>{'sellerId': product.sellerId},
            ),
            UiElement.button('favorite', label: 'Simpan', target: product.id),
          ],
          child: ListView(
            key: const Key('product-detail-scroll'),
            children: [
              _ProductGallery(product: product),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitlePriceBlock(product: product),
                    if (stats != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${stats.impressions} dilihat · ${stats.clicks} diklik · ${stats.inquiries} chat · ${stats.favorites} favorit',
                        key: const Key('product-stats'),
                        style: TextStyle(
                          fontSize: 12,
                          color: KosplyColors.textSecondaryOf(context),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _DescriptionBlock(description: product.description),
                    const SizedBox(height: 8),
                    _InfoBlock(product: product),
                    const SizedBox(height: 16),
                    _SellerBlock(
                      product: product,
                      onTap: () =>
                          SellerDetailScreen.push(context, product.sellerId),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeading('Rekomendasi'),
                    const SizedBox(height: 12),
                    ProductGrid(items: related, eventSource: 'detail'),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ChatSellerBar(
          onPressed: () {
            ref
                .read(uiBridgeProvider.notifier)
                .recordClick(
                  id: UiIds.button('chat', target: product.sellerId),
                  kind: UiElementKinds.button,
                );
            _openChat(context, ref);
          },
        ),
      ),
    );
  }
}

/// @dev Empty shell for an unknown product id, keeping the back arrow reachable.
class _MissingProduct extends StatelessWidget {
  const _MissingProduct();

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}

/// @dev Heart that toggles this product in {favoritesProvider}.
class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool saved = ref.watch(favoritesProvider).contains(productId);

    return IconButton(
      key: const Key('product-favorite'),
      icon: PhosphorGlyph(
        PhosphorCode.heart,
        weight: saved ? PhosphorWeight.fill : PhosphorWeight.regular,
        size: 20,
        color: saved
            ? KosplyColors.primary
            : KosplyColors.textPrimaryOf(context),
      ),
      onPressed: () {
        ref
            .read(uiBridgeProvider.notifier)
            .recordClick(
              id: UiIds.button('favorite', target: productId),
              kind: UiElementKinds.button,
            );
        ref.read(favoritesProvider.notifier).toggle(productId).catchError((
          Object error,
        ) {
          if (error is ApiException && context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(error.userMessage)));
          }
        });
      },
    );
  }
}

/// @dev Full-bleed hero plus a compact thumbnail strip that drives it.
class _ProductGallery extends StatefulWidget {
  const _ProductGallery({required this.product});

  final Product product;

  @override
  State<_ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<_ProductGallery> {
  late final PageController _pageController = PageController();
  int _index = 0;

  List<String> get _images {
    if (widget.product.gallery.isNotEmpty) {
      return widget.product.gallery;
    }
    return <String>[widget.product.imagePath];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index) {
      return;
    }
    setState(() => _index = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = _images;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (int index) => setState(() => _index = index),
            itemBuilder: (BuildContext context, int index) {
              return KosplyImage(images[index], width: double.infinity);
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: images.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 8);
              },
              itemBuilder: (BuildContext context, int index) {
                final bool selected = index == _index;
                return GestureDetector(
                  onTap: () => _select(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? KosplyColors.primary
                            : KosplyColors.outlineOf(context),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: KosplyImage(images[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// @dev Title stacked above the price.
class _TitlePriceBlock extends StatelessWidget {
  const _TitlePriceBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: KosplyColors.textPrimaryOf(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.price,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: KosplyColors.primary,
          ),
        ),
      ],
    );
  }
}

/// @dev Seller row that opens {SellerDetailScreen}.
class _SellerBlock extends StatelessWidget {
  const _SellerBlock({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SellerIdentity(
      seller: Seller(
        id: product.sellerId,
        name: product.sellerName,
        avatarPath: product.sellerAvatarPath,
        activeLabel: product.sellerActiveLabel,
        bio: '',
      ),
      onTap: onTap,
    );
  }
}

/// @dev Description heading plus the long body text.
class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: KosplyColors.textPrimaryOf(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description.isEmpty ? 'Belum ada deskripsi.' : description,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: KosplyColors.textSecondaryOf(context),
          ),
        ),
      ],
    );
  }
}

/// @dev Quantity, location and category rows.
class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> rows = <(String, String)>[
      ('Kuantitas', '${product.quantity}'),
      ('Lokasi', product.location),
      ('Kategori', product.category),
    ];

    return Column(
      children: [
        for (final (String label, String value) in rows) ...[
          Divider(
            height: 1,
            thickness: 1,
            color: KosplyColors.outlineOf(context),
          ),
          _InfoRow(label: label, value: value),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: KosplyColors.textSecondaryOf(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KosplyColors.textPrimaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
