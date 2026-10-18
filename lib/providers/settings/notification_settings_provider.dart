/// @title Notification settings provider
/// @notice Holds All / Personalisasi channel flags for the setting screen.
/// @dev Persisted with SharedPreferences through {PreferencesStore}.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/keys/storage_keys.dart';
import '../../core/storage/providers/storage_providers.dart';
import '../../core/storage/stores/preferences_store.dart';
import '../../models/settings/notification_settings.dart';

/// @title NotificationSettingsNotifier
/// @notice Mutates {NotificationSettings} and persists every change.
class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
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
    return NotificationSettings(
      mode: mode,
      ads: store.readBool(StorageKeys.notificationAds) ?? true,
      message: store.readBool(StorageKeys.notificationMessage) ?? true,
      newMessage: store.readBool(StorageKeys.notificationNewMessage) ?? true,
      promo: store.readBool(StorageKeys.notificationPromo) ?? true,
      transaction: store.readBool(StorageKeys.notificationTransaction) ?? true,
    );
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

  void _setChannel({
    bool? ads,
    bool? message,
    bool? newMessage,
    bool? promo,
    bool? transaction,
  }) {
    state = state.copyWith(
      mode: NotificationMode.personalized,
      ads: ads,
      message: message,
      newMessage: newMessage,
      promo: promo,
      transaction: transaction,
    );
    _persist(state);
  }

  void _persist(NotificationSettings settings) {
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
  }
}

/// @dev Global notification preferences, persisted across releases.
final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );
