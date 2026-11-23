/// @title App sync provider
/// @notice Exposes {AppSync} with every repository injected.
/// @dev Rebuilds when the session changes, so a refresh after sign-in uses
/// repositories that know the new student's id.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/shared/app_sync.dart';
import '../account/profile_provider.dart';
import '../account/session_provider.dart';
import '../catalog/catalog_providers.dart';
import '../chat/ai_chat_provider.dart';
import '../inbox/inbox_providers.dart';
import '../support/support_providers.dart';

/// @dev Backend-to-cache synchroniser.
final appSyncProvider = Provider<AppSync>(
  (ref) => AppSync(
    catalog: ref.watch(catalogRepositoryProvider),
    inbox: ref.watch(inboxRepositoryProvider),
    support: ref.watch(supportRepositoryProvider),
    aiChat: ref.watch(aiChatRepositoryProvider),
    account: ref.watch(accountRepositoryProvider),
    signedIn: ref.watch(currentUserIdProvider).isNotEmpty,
  ),
);
