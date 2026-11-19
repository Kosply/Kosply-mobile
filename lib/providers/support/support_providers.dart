/// @title Support providers
/// @notice Exposes the offline-first help centre to the support screens.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers/database_provider.dart';
import '../../data/support/support_repository.dart';
import '../../models/chat/conversation.dart';
import '../../models/support/help_topic.dart';
import '../../models/support/support_ticket.dart';
import '../account/session_provider.dart';
import '../catalog/catalog_providers.dart';
import '../network/api_provider.dart';

/// @dev Support repository backed by the Drift cache.
final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepository(
    dao: ref.watch(appDatabaseProvider).supportDao,
    api: ref.watch(apiClientProvider),
    currentUserId: ref.watch(currentUserIdProvider),
  ),
);

/// @dev The cached FAQ in display order.
final helpTopicsProvider = StreamProvider<List<HelpTopic>>(
  (ref) => ref.watch(supportRepositoryProvider).watchHelpTopics(),
);

/// @dev The cached ticket rows, newest activity first.
final supportTicketsProvider = StreamProvider<List<SupportTicket>>(
  (ref) => ref.watch(supportRepositoryProvider).watchTickets(),
);

/// @dev The bubbles of one cached ticket, oldest first.
final ticketMessagesProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, String ticketId) =>
      ref.watch(supportRepositoryProvider).watchTicketMessages(ticketId),
);

/// @dev Re-reads the public FAQ when the Help desk or ticket form opens.
final helpTopicsSyncProvider = FutureProvider.autoDispose<void>(
  (ref) =>
      refreshQuietly(ref.read(supportRepositoryProvider).refreshHelpTopics),
);

/// @dev Re-reads the student's tickets when the contact screen opens.
final ticketsSyncProvider = FutureProvider.autoDispose<void>(
  (ref) => refreshQuietly(ref.read(supportRepositoryProvider).refreshTickets),
);

/// @dev Pulls one ticket's thread when it is opened.
final ticketSyncProvider = FutureProvider.autoDispose.family<void, String>(
  (ref, String ticketId) => refreshQuietly(
    () => ref.read(supportRepositoryProvider).refreshTicket(ticketId),
  ),
);
