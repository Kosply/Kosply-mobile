import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/navigation_provider.dart';
import '../screens/home_screen.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the current index
    final currentPageIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // 1. Brand App Icon (Blue rounded square with 'X')
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5), // Your app purple/blue
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'X',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 2. Location Pill Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Light grayish-blue background
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.location_on,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ), // Red pin icon
                  SizedBox(width: 4),
                  Text(
                    'ITB Ganesha, Ba...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF64748B),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // 3. Circular Profile Avatar on the right
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(
                'assets/images/profile_placeholder.png',
              ), // Or NetworkImage / Icon
            ),
          ),
        ],
      ),
      body: <Widget>[
        // Page 0: Home
        const HomeScreen(),
        // Page 1: Search
        const Center(child: Text('Search Screen Content')),
        // Page 2: Jual
        const Center(child: Text('Jual Screen Content')),
        // Page 3: Inbox
        const Center(child: Text('Inbox Screen Content')),
        // Page 4: Profil
        const Center(child: Text('Profil Screen Content')),
      ][currentPageIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFF4F46E5));
              }
              return const IconThemeData(color: Color(0xFF49454F));
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.bold,
                );
              }
              return const TextStyle(
                color: Color(0xFF49454F),
                fontWeight: FontWeight.bold,
              );
            }),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0x00000000),
            selectedIndex: currentPageIndex,
            onDestinationSelected: (int index) {
              // Update state using Riverpod notifier instead of setState
              ref.read(navigationIndexProvider.notifier).setIndex(index);
            },
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              NavigationDestination(
                icon: Icon(Icons.sell_outlined),
                selectedIcon: Icon(Icons.sell),
                label: 'Jual',
              ),
              NavigationDestination(
                icon: Icon(Icons.inbox_outlined),
                selectedIcon: Icon(Icons.inbox),
                label: 'Inbox',
              ),
              NavigationDestination(
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
