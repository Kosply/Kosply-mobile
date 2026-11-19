/// @title AppSync
/// @notice Pulls the backend into the offline cache in one place.
/// @dev Replaces the old placeholder seeder: the cache is now filled from
/// the server. Each step is independent and best effort, so one failing
/// route (or no network at all) leaves the last good cache on screen
/// instead of blocking the app. Private data is only fetched with a session.
/// @author Kosply-mobile
library;

import '../../core/network/api_exception.dart';
import '../account/account_repository.dart';
import '../catalog/catalog_repository.dart';
import '../chat/ai_chat_repository.dart';
import '../inbox/inbox_repository.dart';
import '../support/support_repository.dart';

/// @title AppSync
/// @notice Refreshes every cached feature from the backend.
class AppSync {
  /// @notice Creates the synchroniser.
  /// @param catalog Products, sellers and favorites.
  /// @param inbox COD chat rooms.
  /// @param support FAQ and tickets.
  /// @param aiChat AI sessions.
  /// @param account The signed-in profile.
  /// @param signedIn Whether a session exists.
  /// @return A new {AppSync} instance.
  const AppSync({
    required this.catalog,
    required this.inbox,
    required this.support,
    required this.aiChat,
    required this.account,
    required this.signedIn,
  });

  /// @dev Products, sellers and favorites.
  final CatalogRepository catalog;

  /// @dev COD chat rooms.
  final InboxRepository inbox;

  /// @dev FAQ and tickets.
  final SupportRepository support;

  /// @dev AI sessions.
  final AiChatRepository aiChat;

  /// @dev The signed-in profile.
  final AccountRepository account;

  /// @dev Whether a session exists.
  final bool signedIn;

  /// @notice Refreshes everything this session may read.
  /// @return Future completing when every step has settled.
  Future<void> syncAll() async {
    await syncPublic();
    await syncAccount();
  }

  /// @notice Refreshes what anyone may read: the catalogue and the FAQ.
  /// @return Future completing when both steps have settled.
  Future<void> syncPublic() async {
    await _attempt(catalog.refresh);
    await _attempt(support.refreshHelpTopics);
  }

  /// @notice Refreshes the signed-in student's own data.
  /// @return Future completing when every step has settled.
  Future<void> syncAccount() async {
    if (!signedIn) {
      return;
    }
    await _attempt(account.refreshMe);
    await _attempt(catalog.refreshFavorites);
    await _attempt(inbox.refresh);
    await _attempt(support.refreshTickets);
    await _attempt(aiChat.refreshThreads);
  }

  /// @notice Runs one refresh, swallowing backend and network failures.
  /// @param step The refresh to run.
  /// @return Future completing when it settled.
  Future<void> _attempt(Future<void> Function() step) async {
    try {
      await step();
    } on ApiException {
      // Offline or refused: the cached copy stays on screen.
    }
  }
}
