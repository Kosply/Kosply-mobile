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

/// @dev Support repository backed by the Drift cache.
final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepository(dao: ref.watch(appDatabaseProvider).supportDao),
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
