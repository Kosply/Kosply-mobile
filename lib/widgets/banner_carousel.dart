/// @title BannerCarousel
/// @notice Horizontally swipeable promo banner used on the home screen.
/// @dev One clipped frame. Placeholder art is shown with contain so the
/// whole image stays visible. Dots track the active slide.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title BannerCarousel
/// @notice Reusable promo banner carousel.
class BannerCarousel extends StatefulWidget {
  /// @notice Creates a banner carousel.
  /// @param images Asset paths of the banner slides, in display order.
  /// @param height Banner height.
  /// @param autoAdvanceSeconds Seconds per slide; null disables auto-advance.
  /// @return A new {BannerCarousel} instance.
  const BannerCarousel({
    required this.images,
    this.height = 148,
    this.autoAdvanceSeconds,
    super.key,
  });

  /// @dev Asset paths of the banner slides.
  final List<String> images;

  /// @dev Banner height.
  final double height;

  /// @dev Seconds per slide when auto-advance is enabled.
  final int? autoAdvanceSeconds;

  /// @notice Builds the carousel.
  /// @param context The build context.
  /// @return The carousel state.
  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoAdvanceSeconds != widget.autoAdvanceSeconds) {
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    final int? seconds = widget.autoAdvanceSeconds;
    if (seconds == null || widget.images.length < 2) {
      return;
    }
    _timer = Timer.periodic(Duration(seconds: seconds), (_) {
      if (!_pageController.hasClients) {
        return;
      }
      final int next = (_index + 1) % widget.images.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (int index) => setState(() => _index = index),
              itemBuilder: (BuildContext context, int index) {
                return ColoredBox(
                  color: const Color(0xFFF3F4F6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      widget.images[index],
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.images.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: i == _index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? KosplyColors.primary
                        : KosplyColors.outlineOf(context),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
