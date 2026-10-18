/// @title AppSeeder
/// @notice Fills the local cache on first launch.
/// @dev Kept as a plain object so {main} and the widget tests can await it
/// before showing any screen, which keeps the first frame free of empty
/// states. Every repository guards its own cache, so the whole run is cheap
/// once the tables already hold data.
/// @author Kosply-mobile
library;

import '../catalog/catalog_repository.dart';
import '../chat/ai_chat_repository.dart';
import '../inbox/inbox_repository.dart';
import '../support/support_repository.dart';

/// @title AppSeeder
/// @notice Seeds every offline-first cache once.
class AppSeeder {
  /// @notice Creates the seeder.
  /// @param catalog Catalogue repository.
  /// @param inbox Inbox repository.
  /// @param support Support repository.
  /// @param aiChat Home AI repository.
  /// @return A new {AppSeeder} instance.
  const AppSeeder({
    required this.catalog,
    required this.inbox,
    required this.support,
    required this.aiChat,
  });

  /// @dev Catalogue repository; also seeds the seller rows the inbox needs.
  final CatalogRepository catalog;

  /// @dev Inbox repository.
  final InboxRepository inbox;

  /// @dev Support repository.
  final SupportRepository support;

  /// @dev Home AI repository.
  final AiChatRepository aiChat;

  /// @notice Seeds every cache that has never been synced.
  /// @return Future completing when the caches are ready.
  Future<void> seedIfEmpty() async {
    await catalog.ensureSeeded();
    await inbox.ensureSeeded();
    await support.ensureSeeded();
    await aiChat.ensureSeeded();
  }
}
