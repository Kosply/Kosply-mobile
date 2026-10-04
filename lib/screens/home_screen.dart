/// @title HomeScreen
/// @notice Marketplace feed: search, banners, catalogue, and AI history.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/placeholder_catalog.dart';
import '../models/ai_thread.dart';
import '../models/product.dart';
import '../providers/ai_chat_provider.dart';
import '../screens/see_all_screen.dart';
import '../theme/kosply_colors.dart';
import '../widgets/ai_history_tile.dart';
import '../widgets/ai_home_overlay.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/product_grid.dart';
import '../widgets/searchbar.dart';
import '../widgets/section_heading.dart';

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

  static final List<Product> _allItems = PlaceholderCatalog.all();

  void _openSeeAll(BuildContext context, String title) {
    SeeAllScreen.push(context, title: title, items: _allItems);
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

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      body: Stack(
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
                onTap: () => _openSeeAll(context, 'Rekomendasi'),
              ),
              const SizedBox(height: 12),
              ProductGrid(items: _allItems.take(4).toList()),
              const SizedBox(height: 24),
              SectionHeading(
                'Terdekat',
                actionLabel: 'Lihat semua',
                onTap: () => _openSeeAll(context, 'Terdekat'),
              ),
              const SizedBox(height: 12),
              ProductGrid(items: _allItems.skip(4).take(4).toList()),
              const SizedBox(height: 24),
              SectionHeading(
                'Semua Produk',
                actionLabel: 'Lihat semua',
                onTap: () => _openSeeAll(context, 'Semua Produk'),
              ),
              const SizedBox(height: 12),
              ProductGrid(items: _allItems),
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
    );
  }
}
