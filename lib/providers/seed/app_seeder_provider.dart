/// @title App seeder provider
/// @notice Bootstrap hook that fills every cache before the first frame.
/// @dev {main} awaits {appSeederProvider} with the platform overrides in
/// place; the widget-test helper does the same with the in-memory defaults.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/shared/app_seeder.dart';
import '../catalog/catalog_providers.dart';
import '../chat/ai_chat_provider.dart';
import '../inbox/inbox_providers.dart';
import '../support/support_providers.dart';

/// @dev Seeder wired to the live repositories.
final appSeederProvider = Provider<AppSeeder>(
  (ref) => AppSeeder(
    catalog: ref.watch(catalogRepositoryProvider),
    inbox: ref.watch(inboxRepositoryProvider),
    support: ref.watch(supportRepositoryProvider),
    aiChat: ref.watch(aiChatRepositoryProvider),
  ),
);
