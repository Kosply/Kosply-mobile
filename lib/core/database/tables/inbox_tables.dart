/// @title Inbox tables
/// @notice Local cache for conversations and their messages.
/// @dev Columns mirror the backend `conversations` and `messages` tables so
/// an inbox refresh can be written straight into the cache.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import 'cache_marker.dart';

/// @title Conversations
/// @notice Cached inbox threads; one room per buyer per product.
@DataClassName('ConversationRow')
class Conversations extends Table with CacheMarker {
  /// @dev Stable identifier from the backend.
  TextColumn get id => text()();

  /// @dev Product the room is about.
  TextColumn get productId => text().withDefault(const Constant(''))();

  /// @dev Identifier of the buyer in the room.
  TextColumn get buyerId => text().withDefault(const Constant(''))();

  /// @dev Identifier of the seller in the room.
  TextColumn get sellerId => text().withDefault(const Constant(''))();

  /// @dev Agreed COD latitude.
  RealColumn get agreedLatitude => real().withDefault(const Constant(0))();

  /// @dev Agreed COD longitude.
  RealColumn get agreedLongitude => real().withDefault(const Constant(0))();

  /// @dev Agreed COD location label.
  TextColumn get agreedLocationLabel =>
      text().withDefault(const Constant(''))();

  /// @dev UTC millis of the last message; drives inbox ordering.
  IntColumn get lastMessageAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis when the backend created the room.
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis of the last backend update to the row.
  IntColumn get backendUpdatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// @title Messages
/// @notice Cached chat bubbles for one conversation.
@DataClassName('MessageRow')
class Messages extends Table with CacheMarker {
  /// @dev Stable identifier from the backend.
  TextColumn get id => text()();

  /// @dev Conversation this bubble belongs to.
  TextColumn get conversationId => text()();

  /// @dev Identifier of the student who sent it.
  TextColumn get senderId => text().withDefault(const Constant(''))();

  /// @dev TEXT, IMAGE, LOCATION or SYSTEM.
  TextColumn get type => text().withDefault(const Constant('TEXT'))();

  /// @dev Message body; stored as the backend `text` column.
  TextColumn get body => text().named('text').withDefault(const Constant(''))();

  /// @dev Image URL for IMAGE bubbles.
  TextColumn get imageUrl => text().withDefault(const Constant(''))();

  /// @dev Latitude for LOCATION bubbles.
  RealColumn get latitude => real().withDefault(const Constant(0))();

  /// @dev Longitude for LOCATION bubbles.
  RealColumn get longitude => real().withDefault(const Constant(0))();

  /// @dev Location label for LOCATION bubbles.
  TextColumn get locationLabel => text().withDefault(const Constant(''))();

  /// @dev Whether the recipient has read the bubble.
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  /// @dev UTC millis when the bubble was read; 0 while unread.
  IntColumn get readAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis when the backend created the bubble.
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
