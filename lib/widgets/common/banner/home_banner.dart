/// @title Home banner
/// @notice Promo strip at the top of Home.
/// @dev Visual only. The copy is a placeholder until a real campaign exists.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui_bridge/catalog_filter.dart';
import '../../../theme/colors/kosply_colors.dart';

/// @title HomeBanner
/// @notice One full-width promo card with room for the copy and a search CTA.
class HomeBanner extends ConsumerWidget {
  /// @notice Creates the home banner.
  /// @return A new {HomeBanner} instance.
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      key: const Key('home-banner'),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 188),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: KosplyColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barang bekas kampus',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Meja, buku, dan peralatan kos dari mahasiswa di sekitarmu.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xE6FFFFFF),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            key: const Key('home-banner-cta'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: KosplyColors.primary,
              elevation: 0,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              ref.read(catalogSearchFocusProvider).requestFocus();
            },
            child: const Text(
              'Cari barang',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
