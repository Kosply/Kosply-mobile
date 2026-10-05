/// @title ProductViewScreen
/// @notice Detail view of a single catalogue item.
/// @dev Receives only a product id and resolves the rest through
/// [PlaceholderCatalog]. The hero and the thumbnail strip stay in sync.
/// Chat sits in a pinned bar so the title and price can read as a block.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/placeholder_catalog.dart';
import '../models/product.dart';
import '../models/seller.dart';
import '../providers/favorites_provider.dart';
import '../theme/kosply_colors.dart';
import '../widgets/chat_seller_bar.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/product_grid.dart';
import '../widgets/section_heading.dart';
import '../widgets/seller_identity.dart';
import 'chat_detail_screen.dart';
import 'seller_detail_screen.dart';

/// @title ProductViewScreen
/// @notice Product detail screen.
class ProductViewScreen extends StatelessWidget {
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

  /// @notice Builds the product detail.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final Product product = PlaceholderCatalog.byId(productId);
    final List<Product> related = PlaceholderCatalog.all()
        .where((Product item) => item.id != productId)
        .take(4)
        .toList();

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
        actions: [
          _FavoriteButton(productId: productId),
          _ActionButton(
            codePoint: PhosphorCode.dotsThree,
            weight: PhosphorWeight.bold,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        key: const Key('product-detail-scroll'),
        children: [
          _ProductGallery(product: product),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitlePriceBlock(product: product),
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
                ProductGrid(items: related),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ChatSellerBar(
        onPressed: () => ChatDetailScreen.push(context, product.sellerId),
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
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(productId),
    );
  }
}

/// @dev App bar icon button driven by a Phosphor code point.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.codePoint,
    this.weight = PhosphorWeight.regular,
  });

  final int codePoint;
  final PhosphorWeight weight;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: PhosphorGlyph(
        codePoint,
        weight: weight,
        size: 20,
        color: KosplyColors.textPrimaryOf(context),
      ),
      onPressed: () {},
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
              return Image.asset(
                images[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
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
                      child: Image.asset(images[index], fit: BoxFit.cover),
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
          description.isEmpty ? Product.loremIpsum : description,
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
