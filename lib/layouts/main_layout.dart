import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_mode.dart';
import '../models/user_profile.dart';
import '../providers/account_mode_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/home_screen.dart';
import '../screens/inbox_screen.dart';
import '../screens/jual_screen.dart';
import '../screens/profile_setting_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/kosply_colors.dart';
import '../widgets/kosply_wordmark.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/seller_avatar.dart';

/// @title KosplyMainLayout
/// @notice Nested home shell with the bottom-navigation destinations.
/// @dev Uses Riverpod ({navigationIndexProvider}) for the selected tab. Not
/// the app entry point while the auth flow is still under construction;
/// reachable through the '/home' route.
class KosplyMainLayout extends ConsumerWidget {
  /// @notice Creates the main layout shell.
  /// @param key Optional widget key.
  /// @return A new {KosplyMainLayout} instance.
  const KosplyMainLayout({super.key});

  /// @dev Named route for this shell.
  static const routeName = '/home';

  /// @notice Pushes this shell onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the shell is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Maps a visible tab slot onto the 5-page body list.
  /// @dev Buyer tabs skip Jual, so Inbox and Profil sit one slot earlier.
  /// @param visual Index in the visible {NavigationBar}.
  /// @param isSeller Whether the Jual tab is shown.
  /// @return Body page index in 0..4.
  static int pageIndexFor(int visual, bool isSeller) {
    if (isSeller) {
      return visual;
    }
    return visual < 2 ? visual : visual + 1;
  }

  /// @notice Maps a body page index onto the visible tab slot.
  /// @param page Body page index in 0..4.
  /// @param isSeller Whether the Jual tab is shown.
  /// @return Index in the visible {NavigationBar}.
  static int visualIndexFor(int page, bool isSeller) {
    if (isSeller) {
      return page;
    }
    if (page == 2) {
      return 0;
    }
    return page < 2 ? page : page - 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSeller = ref.watch(accountModeProvider) == AccountMode.seller;
    final int currentPageIndex = ref.watch(navigationIndexProvider);
    final UserProfile profile = ref.watch(profileProvider);
    final bool hasPhoto = profile.hasPhoto;
    final String avatarPath = profile.avatarPath;
    final Color shellColor = KosplyColors.backgroundOf(context);
    final Color onShell = KosplyColors.textPrimaryOf(context);

    ref.listen<AccountMode>(accountModeProvider, (
      AccountMode? previous,
      AccountMode next,
    ) {
      if (next == AccountMode.buyer && ref.read(navigationIndexProvider) == 2) {
        ref.read(navigationIndexProvider.notifier).setIndex(0);
      }
    });

    final int pageIndex = (!isSeller && currentPageIndex == 2)
        ? 0
        : currentPageIndex;

    return Scaffold(
      backgroundColor: shellColor,
      appBar: AppBar(
        backgroundColor: shellColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            const KosplyMark(size: 36),
            const SizedBox(width: 12),

            // 2. Location Pill Container
            // @dev Flexible so the label ellipsises instead of overflowing the
            // @dev app bar on narrow screens.
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: KosplyColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    PhosphorGlyph(
                      PhosphorCode.mapPin,
                      size: 16,
                      color: KosplyColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'ITB Ganesha',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: KosplyColors.textPrimaryOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              key: const Key('top-bar-profile'),
              onTap: () => ProfileSettingScreen.push(context),
              child: hasPhoto
                  ? SellerAvatar(path: avatarPath, size: 32)
                  : CircleAvatar(
                      radius: 16,
                      backgroundColor: KosplyColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 18,
                        color: KosplyColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: <Widget>[
        const HomeScreen(),
        const SearchScreen(),
        const JualScreen(),
        const InboxScreen(),
        const SettingsScreen(),
      ][pageIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: shellColor,
          border: Border(
            top: BorderSide(color: KosplyColors.outlineOf(context), width: 1.0),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: KosplyColors.primary);
              }
              return IconThemeData(color: onShell.withValues(alpha: 0.64));
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: KosplyColors.primary,
                  fontWeight: FontWeight.bold,
                );
              }
              return TextStyle(
                color: onShell.withValues(alpha: 0.64),
                fontWeight: FontWeight.bold,
              );
            }),
          ),
          child: NavigationBar(
            backgroundColor: shellColor,
            indicatorColor: const Color(0x00000000),
            selectedIndex: visualIndexFor(pageIndex, isSeller),
            onDestinationSelected: (int index) {
              ref
                  .read(navigationIndexProvider.notifier)
                  .setIndex(pageIndexFor(index, isSeller));
            },
            destinations: <Widget>[
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              if (isSeller)
                const NavigationDestination(
                  icon: Icon(Icons.sell_outlined),
                  selectedIcon: Icon(Icons.sell),
                  label: 'Jual',
                ),
              const NavigationDestination(
                icon: Icon(Icons.inbox_outlined),
                selectedIcon: Icon(Icons.inbox),
                label: 'Inbox',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
