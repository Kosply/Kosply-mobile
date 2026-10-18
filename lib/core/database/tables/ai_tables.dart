/// @title AI tables
/// @notice Local cache for Home AI conversations and their messages.
/// @dev Columns mirror the backend `ai_conversations` and `ai_messages`
/// tables so history from `/api/ai/conversations` caches as-is.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import 'cache_marker.dart';

/// @title AiConversations
/// @notice Cached Home AI conversations.
@DataClassName('AiConversationRow')
class AiConversations extends Table with CacheMarker {
  /// @dev Stable identifier from the backend.
  TextColumn get id => text()();

  /// @dev Identifier of the owning student.
  TextColumn get userId => text().withDefault(const Constant(''))();

  /// @dev Heading shown on the overlay and the Home list.
  TextColumn get title => text().withDefault(const Constant(''))();

  /// @dev UTC millis of the last message; drives history ordering.
  IntColumn get lastMessageAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis when the backend created the conversation.
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis of the last backend update to the row.
  IntColumn get backendUpdatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// @title AiMessages
/// @notice Cached bubbles for one AI conversation.
@DataClassName('AiMessageRow')
class AiMessages extends Table with CacheMarker {
  /// @dev Stable identifier from the backend.
  TextColumn get id => text()();

  /// @dev Conversation this bubble belongs to.
  TextColumn get conversationId => text()();

  /// @dev USER, ASSISTANT or SYSTEM.
  TextColumn get role => text().withDefault(const Constant('USER'))();

  /// @dev Message body.
  TextColumn get content => text().withDefault(const Constant(''))();

  /// @dev Model that produced an assistant bubble.
  TextColumn get model => text().withDefault(const Constant(''))();

  /// @dev UTC millis when the backend created the bubble.
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
