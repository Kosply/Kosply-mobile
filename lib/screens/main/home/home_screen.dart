/// @title HomeScreen
/// @notice Marketplace feed: search, banners, catalogue, and AI history.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui_bridge/ui_bridge.dart';
import '../../../core/ui_bridge/ui_bridge_scope.dart';
import '../../../models/chat/ai_thread.dart';
import '../../../models/catalog/product.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../providers/chat/ai_chat_provider.dart';
import 'see_all_screen.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/ai/history/ai_history_tile.dart';
import '../../../widgets/ai/overlay/ai_home_overlay.dart';
import '../../../widgets/product/banner/banner_carousel.dart';
import '../../../widgets/product/grid/product_grid.dart';
import '../../../widgets/common/search/searchbar.dart';
import '../../../widgets/common/headings/section_heading.dart';

/// @title HomeScreen
/// @notice Home tab body.
class HomeScreen extends ConsumerWidget {
  /// @notice Creates the home feed.
  /// @return A new {HomeScreen} instance.
  const HomeScreen({super.key});

  static const List<String> _bannerImages = <String>[
    'assets/images/placeholder_catalog.png',
    'assets/images/placeholder_catalog.png',
    'assets/images/placeholder_catalog.png',
  ];

  void _openSeeAll(BuildContext context, String title, List<Product> items) {
    SeeAllScreen.push(context, title: title, items: items);
  }

  /// @notice Extra list padding so the floating AI overlay does not cover the
  /// last Home section.
  double _bottomPad(AiChatState ai) {
    if (ai.panel != AiPanelKind.hidden && !ai.panelMinimized) {
      return 360;
    }
    if (ai.composerOpen || ai.panel != AiPanelKind.hidden) {
      return 140;
    }
    return 88;
  }

  /// @notice Builds the feed and the floating AI overlay.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AiChatState ai = ref.watch(aiChatProvider);
    final List<AiThread> history = ai.threads;
    final List<Product> items =
        ref.watch(catalogProductsProvider).value ?? const <Product>[];

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      body: UiBridgeScope(
        screen: 'home',
        elements: <UiElement>[
          for (final Product item in items)
            UiElement.product(item.id, label: item.title),
        ],
        child: Stack(
          children: [
            ListView(
              key: const Key('home-scroll'),
              padding: EdgeInsets.fromLTRB(16, 12, 16, _bottomPad(ai)),
              children: [
                const KosplySearchbar(),
                const SizedBox(height: 16),
                const BannerCarousel(
                  autoAdvanceSeconds: 4,
                  images: _bannerImages,
                ),
                const SizedBox(height: 24),
                SectionHeading(
                  'Rekomendasi',
                  actionLabel: 'Lihat semua',
                  onTap: () => _openSeeAll(context, 'Rekomendasi', items),
                ),
                const SizedBox(height: 12),
                ProductGrid(items: items.take(4).toList()),
                const SizedBox(height: 24),
                SectionHeading(
                  'Terdekat',
                  actionLabel: 'Lihat semua',
                  onTap: () => _openSeeAll(context, 'Terdekat', items),
                ),
                const SizedBox(height: 12),
                ProductGrid(items: items.skip(4).take(4).toList()),
                const SizedBox(height: 24),
                SectionHeading(
                  'Semua Produk',
                  actionLabel: 'Lihat semua',
                  onTap: () => _openSeeAll(context, 'Semua Produk', items),
                ),
                const SizedBox(height: 12),
                ProductGrid(items: items),
                const SizedBox(height: 24),
                const SectionHeading('Chat history'),
                const SizedBox(height: 8),
                for (final AiThread thread in history)
                  AiHistoryTile(
                    key: Key('home-ai-history-${thread.id}'),
                    thread: thread,
                    onTap: () =>
                        ref.read(aiChatProvider.notifier).openThread(thread.id),
                  ),
              ],
            ),
            if (ai.composerOpen || ai.panel != AiPanelKind.hidden)
              Positioned.fill(
                child: GestureDetector(
                  key: const Key('ai-dismiss'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => ref.read(aiChatProvider.notifier).close(),
                ),
              ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: AiHomeOverlay(),
            ),
          ],
        ),
      ),
    );
  }
}
