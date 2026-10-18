/// @title Support tables
/// @notice Local cache for help topics, support tickets and their messages.
/// @dev Ticket columns mirror the backend `support_tickets` and
/// `support_messages` tables. Help topics cache the FAQ endpoint.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import 'cache_marker.dart';

/// @title HelpTopics
/// @notice Cached FAQ entries shown in Help desk.
@DataClassName('HelpTopicRow')
class HelpTopics extends Table with CacheMarker {
  /// @dev Stable identifier from the backend.
  TextColumn get id => text()();

  /// @dev Label shown on the expandable row.
  TextColumn get title => text()();

  /// @dev Guidance shown when the row is expanded.
  TextColumn get answer => text()();

  /// @dev Position kept so the FAQ matches the backend order.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// @title SupportTickets
/// @notice Cached contact-support threads.
@DataClassName('SupportTicketRow')
class SupportTickets extends Table with CacheMarker {
  /// @dev Stable identifier from the backend.
  TextColumn get id => text()();

  /// @dev Human-readable ticket number, e.g. KSP-1234.
  TextColumn get ticketNo => text().withDefault(const Constant(''))();

  /// @dev Identifier of the student who opened the ticket.
  TextColumn get userId => text().withDefault(const Constant(''))();

  /// @dev Problem category.
  TextColumn get category => text().withDefault(const Constant('LAINNYA'))();

  /// @dev OPEN or CLOSED.
  TextColumn get status => text().withDefault(const Constant('OPEN'))();

  /// @dev Subject shown as the inbox-style username line.
  TextColumn get subject => text().withDefault(const Constant(''))();

  /// @dev First message body.
  TextColumn get description => text().withDefault(const Constant(''))();

  /// @dev UTC millis of the last message.
  IntColumn get lastMessageAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis when the backend created the ticket.
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis of the last backend update to the row.
  IntColumn get backendUpdatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// @title SupportMessages
/// @notice Cached ticket chat bubbles.
@DataClassName('SupportMessageRow')
class SupportMessages extends Table with CacheMarker {
  /// @dev Stable identifier from the backend.
  TextColumn get id => text()();

  /// @dev Ticket this bubble belongs to.
  TextColumn get ticketId => text()();

  /// @dev Identifier of the sender.
  TextColumn get senderId => text().withDefault(const Constant(''))();

  /// @dev Sender role, e.g. USER or ADMIN.
  TextColumn get senderRole => text().withDefault(const Constant('USER'))();

  /// @dev Display name of the sender.
  TextColumn get senderName => text().withDefault(const Constant(''))();

  /// @dev Message body; stored as the backend `text` column.
  TextColumn get body => text().named('text').withDefault(const Constant(''))();

  /// @dev Image URL when the bubble carries a photo.
  TextColumn get imageUrl => text().withDefault(const Constant(''))();

  /// @dev Admin-only internal note.
  BoolColumn get isInternal => boolean().withDefault(const Constant(false))();

  /// @dev Whether the reporter has read the bubble.
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  /// @dev UTC millis when the bubble was read; 0 while unread.
  IntColumn get readAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis when the backend created the bubble.
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
