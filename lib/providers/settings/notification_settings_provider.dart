/// @title Notification settings provider
/// @notice Holds All / Personalisasi channel flags for the setting screen.
/// @dev Persisted with SharedPreferences through {PreferencesStore}, and
/// mirrored to `PATCH /api/notifications/preferences` for the channels the
/// backend actually sends: Message → `chat`, Transaksi → `product`, Iklan and
/// Promo → `system` (on while either is on). "New message" is an in-app badge
/// with no server counterpart, so it stays on the device.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/keys/storage_keys.dart';
import '../../core/storage/providers/storage_providers.dart';
import '../../core/storage/stores/preferences_store.dart';
import '../../data/notifications/notification_repository.dart';
import '../../models/settings/notification_settings.dart';
import '../account/session_provider.dart';
import '../network/api_provider.dart';

/// @title NotificationSettingsNotifier
/// @notice Mutates {NotificationSettings} and persists every change.
class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  /// @dev Flags as last sent to the backend, to send only what changed.
  NotificationSettings? _synced;

  /// @notice Restores saved flags, defaulting to every channel on.
  /// @return The initial {NotificationSettings}.
  @override
  NotificationSettings build() {
    final PreferencesStore store = ref.watch(preferencesStoreProvider);
    final String? savedMode = store.readString(StorageKeys.notificationMode);
    final NotificationMode mode =
        savedMode == NotificationMode.personalized.name
        ? NotificationMode.personalized
        : NotificationMode.all;
    final NotificationSettings restored = NotificationSettings(
      mode: mode,
      ads: store.readBool(StorageKeys.notificationAds) ?? true,
      message: store.readBool(StorageKeys.notificationMessage) ?? true,
      newMessage: store.readBool(StorageKeys.notificationNewMessage) ?? true,
      promo: store.readBool(StorageKeys.notificationPromo) ?? true,
      transaction: store.readBool(StorageKeys.notificationTransaction) ?? true,
      verification:
          store.readBool(StorageKeys.notificationVerification) ?? true,
      reports: store.readBool(StorageKeys.notificationReports) ?? true,
      support: store.readBool(StorageKeys.notificationSupport) ?? true,
    );
    _synced = restored;
    Future<void>.microtask(_pullRemote);
    return restored;
  }

  /// @notice Applies `GET /api/notifications/preferences` without echoing a PATCH.
  /// @return Future completing when the flags match the server.
  Future<void> _pullRemote() async {
    if (ref.read(currentUserIdProvider).isEmpty) {
      return;
    }
    final Map<String, bool> remote;
    try {
      remote = await ref.read(notificationRepositoryProvider).preferences();
    } on ApiException {
      return;
    }
    if (!ref.mounted || remote.isEmpty) {
      return;
    }
    bool value(String key, bool fallback) => remote[key] ?? fallback;
    final bool system = value('system', state.ads || state.promo);
    final NotificationSettings next = state.copyWith(
      message: value('chat', state.message),
      transaction: value('product', state.transaction),
      ads: system ? state.ads : false,
      promo: system ? state.promo : false,
      verification: value('verification', state.verification),
      reports: value('reports', state.reports),
      support: value('support', state.support),
    );
    state = next;
    _synced = next;
    _writeLocal(next);
  }

  /// @notice Switches All or Personalisasi.
  /// @dev All turns every channel back on.
  /// @param mode The selected mode.
  /// @return void
  void setMode(NotificationMode mode) {
    if (mode == NotificationMode.all) {
      state = const NotificationSettings();
      _persist(state);
      return;
    }
    state = state.copyWith(mode: mode);
    _persist(state);
  }

  /// @notice Sets the ads channel.
  void setAds(bool value) => _setChannel(ads: value);

  /// @notice Sets the chat-message channel.
  void setMessage(bool value) => _setChannel(message: value);

  /// @notice Sets the new-message channel.
  void setNewMessage(bool value) => _setChannel(newMessage: value);

  /// @notice Sets the promo channel.
  void setPromo(bool value) => _setChannel(promo: value);

  /// @notice Sets the transaction channel.
  void setTransaction(bool value) => _setChannel(transaction: value);

  /// @notice Sets the verification-result channel.
  void setVerification(bool value) => _setChannel(verification: value);

  /// @notice Sets the report-outcome channel.
  void setReports(bool value) => _setChannel(reports: value);

  /// @notice Sets the support-reply channel.
  void setSupport(bool value) => _setChannel(support: value);

  void _setChannel({
    bool? ads,
    bool? message,
    bool? newMessage,
    bool? promo,
    bool? transaction,
    bool? verification,
    bool? reports,
    bool? support,
  }) {
    state = state.copyWith(
      mode: NotificationMode.personalized,
      ads: ads,
      message: message,
      newMessage: newMessage,
      promo: promo,
      transaction: transaction,
      verification: verification,
      reports: reports,
      support: support,
    );
    _persist(state);
  }

  /// @notice Backend preference keys for [settings].
  /// @param settings Local channel flags.
  /// @return `{key: enabled}` for every mirrored backend key.
  static Map<String, bool> remoteKeys(NotificationSettings settings) {
    return <String, bool>{
      'chat': settings.message,
      'product': settings.transaction,
      'system': settings.ads || settings.promo,
      'verification': settings.verification,
      'reports': settings.reports,
      'support': settings.support,
    };
  }

  /// @notice Sends the mirrored keys that changed, best effort.
  /// @param before Settings before the change.
  /// @param after Settings after the change.
  /// @return Future completing when every call settled.
  Future<void> _syncRemote(
    NotificationSettings before,
    NotificationSettings after,
  ) async {
    if (ref.read(currentUserIdProvider).isEmpty) {
      return;
    }
    final Map<String, bool> old = remoteKeys(before);
    for (final MapEntry<String, bool> entry in remoteKeys(after).entries) {
      if (old[entry.key] == entry.value) {
        continue;
      }
      try {
        await ref
            .read(apiClientProvider)
            .patch(
              '/api/notifications/preferences',
              body: <String, Object>{'key': entry.key, 'enabled': entry.value},
            );
      } on ApiException {
        // Offline: the local switch still applies; the next change resends.
      }
    }
  }

  void _persist(NotificationSettings settings) {
    final NotificationSettings before = _synced ?? settings;
    _synced = settings;
    unawaited(_syncRemote(before, settings));
    _writeLocal(settings);
  }

  void _writeLocal(NotificationSettings settings) {
    final PreferencesStore store = ref.read(preferencesStoreProvider);
    unawaited(
      store.writeString(StorageKeys.notificationMode, settings.mode.name),
    );
    unawaited(store.writeBool(StorageKeys.notificationAds, settings.ads));
    unawaited(
      store.writeBool(StorageKeys.notificationMessage, settings.message),
    );
    unawaited(
      store.writeBool(StorageKeys.notificationNewMessage, settings.newMessage),
    );
    unawaited(store.writeBool(StorageKeys.notificationPromo, settings.promo));
    unawaited(
      store.writeBool(
        StorageKeys.notificationTransaction,
        settings.transaction,
      ),
    );
    unawaited(
      store.writeBool(
        StorageKeys.notificationVerification,
        settings.verification,
      ),
    );
    unawaited(store.writeBool(StorageKeys.notificationReports, settings.reports));
    unawaited(
      store.writeBool(StorageKeys.notificationSupport, settings.support),
    );
  }
}

/// @dev Global notification preferences, persisted across releases.
final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );
