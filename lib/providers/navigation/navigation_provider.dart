import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Define the Notifier class to manage the integer state
class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // Initial active tab index (Home)
  }

  void setIndex(int newIndex) {
    state = newIndex;
  }
}

// 2. Expose the provider globally
final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(
  NavigationIndexNotifier.new,
);