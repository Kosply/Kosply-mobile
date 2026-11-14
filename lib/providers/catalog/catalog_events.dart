/// @title Catalogue events
/// @notice Fires each impression and click once per app session.
/// @dev The backend also dedupes, but a rebuild must not POST on every frame.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog/catalog_repository.dart';
import 'catalog_providers.dart';

/// @title CatalogEventLog
/// @notice Session dedupe in front of {CatalogRepository.recordEvent}.
class CatalogEventLog {
  /// @notice Creates the log.
  /// @param catalog Catalogue repository.
  /// @return A new {CatalogEventLog} instance.
  CatalogEventLog(this._catalog);

  final CatalogRepository _catalog;
  final Set<String> _seen = <String>{};

  /// @notice Records an impression the first time a card is shown.
  /// @param productId Product id.
  /// @param source `feed`, `search`, or `detail`.
  void impression(String productId, String source) {
    _send(productId, 'IMPRESSION', source);
  }

  /// @notice Records a detail open.
  /// @param productId Product id.
  void click(String productId) {
    _send(productId, 'CLICK', 'detail');
  }

  void _send(String productId, String type, String source) {
    if (productId.isEmpty || !_seen.add('$type:$productId')) {
      return;
    }
    _catalog.recordEvent(productId, type, source: source);
  }
}

/// @dev One log for the signed-in session.
final catalogEventsProvider = Provider<CatalogEventLog>(
  (ref) => CatalogEventLog(ref.watch(catalogRepositoryProvider)),
);
