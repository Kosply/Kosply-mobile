/// @title Search opens
/// @notice Product ids the student opened from Search, newest first.
/// @dev Session only. The Search tab's "Dibuka terakhir" reads this list.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// @title SearchOpens
/// @notice Remembers products opened from a search card.
class SearchOpens extends Notifier<List<String>> {
  /// @notice Starts empty. Nothing has been opened yet.
  /// @return An empty id list.
  @override
  List<String> build() => const <String>[];

  /// @notice Puts [productId] first, dropping an older copy of the same id.
  /// @param productId Product the student just opened.
  /// @return void
  void record(String productId) {
    if (productId.isEmpty) {
      return;
    }
    state = <String>[
      productId,
      for (final String id in state)
        if (id != productId) id,
    ].take(12).toList();
  }
}

/// @dev Product ids opened from Search, newest first.
final searchOpensProvider = NotifierProvider<SearchOpens, List<String>>(
  SearchOpens.new,
);
