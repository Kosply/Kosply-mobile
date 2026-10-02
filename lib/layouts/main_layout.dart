import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

class KosplyMainLayout extends StatefulWidget {
  const KosplyMainLayout({super.key});

  @override
  State<KosplyMainLayout> createState() => _KosplyMainLayoutState();
}

class _KosplyMainLayoutState extends State<KosplyMainLayout> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          color: Colors.white, // Match your background color
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300, // Color of your tiny stroke
              width:
                  1.0, // Thickness of the stroke (1 pixel is nice and subtle)
            ),
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
            indicatorColor: Color(0x00000000),
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
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
