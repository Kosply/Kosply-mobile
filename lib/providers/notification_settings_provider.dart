/// @title Notification settings provider
/// @notice Holds All / Personalisasi channel flags for the setting screen.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_settings.dart';

/// @title NotificationSettingsNotifier
/// @notice Mutates the in-memory {NotificationSettings}.
class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  /// @notice Starts with every channel on in All mode.
  /// @return The initial {NotificationSettings}.
  @override
  NotificationSettings build() => const NotificationSettings();

  /// @notice Switches All or Personalisasi.
  /// @dev All turns every channel back on.
  /// @param mode The selected mode.
  /// @return void
  void setMode(NotificationMode mode) {
    if (mode == NotificationMode.all) {
      state = const NotificationSettings();
      return;
    }
    state = state.copyWith(mode: mode);
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
  }
}

/// @dev Session-scoped notification preferences.
final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );
