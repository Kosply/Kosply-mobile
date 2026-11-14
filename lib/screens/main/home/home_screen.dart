/// @title HomeScreen
/// @notice Marketplace feed: search, banners, catalogue, and AI history.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui_bridge/catalog_filter.dart';
import '../../../core/ui_bridge/ui_bridge.dart';
import '../../../core/ui_bridge/ui_bridge_scope.dart';
import '../../../core/ui_bridge/ui_ids.dart';
import '../../../models/chat/ai_thread.dart';
import '../../../models/catalog/product.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../providers/chat/ai_chat_provider.dart';
import 'see_all_screen.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/ai/history/ai_history_tile.dart';
import '../../../widgets/product/grid/product_grid.dart';
import '../../../widgets/common/search/catalog_search_field.dart';
import '../../../widgets/common/headings/section_heading.dart';

/// @title HomeScreen
/// @notice Home tab body.
class HomeScreen extends ConsumerWidget {
  /// @notice Creates the home feed.
  /// @return A new {HomeScreen} instance.
  const HomeScreen({super.key});

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

  /// @notice Addressable cards for the AI, capped so `ui_state` stays under
  /// the backend's 8000-character limit.
  /// @param visible Products that pass the active filter.
  /// @return The search field plus up to 24 cards.
  List<UiElement> _bridgeElements(List<Product> visible) {
    return <UiElement>[
      UiElement(
        id: UiIds.input('search'),
        kind: UiElementKinds.input,
        label: 'Cari',
      ),
      for (final Product item in visible.take(24))
        UiElement.product(item.id, label: item.title),
    ];
  }

  /// @notice Builds the feed. The AI control lives on the tab shell.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(catalogSyncProvider);
    final AiChatState ai = ref.watch(aiChatProvider);
    final CatalogFilter filter = ref.watch(catalogFilterProvider);
    final List<AiThread> history = ai.threads;
    final List<Product> items =
        (ref.watch(catalogProductsProvider).value ?? const <Product>[])
            .where(filter.allows)
            .toList();

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      body: UiBridgeScope(
        screen: 'home',
        elements: _bridgeElements(items),
        selection: filter.toJson(),
        child: ListView(
          key: const Key('home-scroll'),
          padding: EdgeInsets.fromLTRB(16, 12, 16, _bottomPad(ai)),
          children: [
            const CatalogSearchField(),
            const SizedBox(height: 24),
            SectionHeading(
              'Rekomendasi',
              actionLabel: 'Lihat semua',
              onTap: () => _openSeeAll(context, 'Rekomendasi', items),
            ),
            const SizedBox(height: 12),
            ProductGrid(items: items.take(4).toList(), anchor: true),
            const SizedBox(height: 24),
            SectionHeading(
              'Terdekat',
              actionLabel: 'Lihat semua',
              onTap: () => _openSeeAll(context, 'Terdekat', items),
            ),
            const SizedBox(height: 12),
            ProductGrid(items: items.skip(4).take(4).toList(), anchor: true),
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
      ),
    );
  }
}
