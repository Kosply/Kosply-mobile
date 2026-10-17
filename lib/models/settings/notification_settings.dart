/// @title NotificationSettings
/// @notice In-session notification preferences from the setting screen.
/// @author Kosply-mobile
library;

/// @title NotificationMode
/// @notice Master delivery mode for marketplace alerts.
enum NotificationMode {
  /// @dev Every channel stays on; individual switches stay hidden.
  all,

  /// @dev Per-channel switches are shown so the student can mute some.
  personalized,
}

/// @title NotificationSettings
/// @notice Mode plus the individual channel flags.
class NotificationSettings {
  /// @notice Creates the preference snapshot.
  /// @param mode All or personalisasi.
  /// @param ads Campus ads and sponsored listings.
  /// @param message Chat messages from other students.
  /// @param newMessage Alerts for a brand-new inbox thread.
  /// @param promo Promo and discount pushes.
  /// @param transaction Order and payment updates.
  /// @return A new {NotificationSettings} instance.
  const NotificationSettings({
    this.mode = NotificationMode.all,
    this.ads = true,
    this.message = true,
    this.newMessage = true,
    this.promo = true,
    this.transaction = true,
  });

  /// @dev Master mode.
  final NotificationMode mode;

  /// @dev Campus ads channel.
  final bool ads;

  /// @dev Chat messages channel.
  final bool message;

  /// @dev New-thread alerts.
  final bool newMessage;

  /// @dev Promo pushes.
  final bool promo;

  /// @dev Order and payment updates.
  final bool transaction;

  /// @notice Whether the personalisasi switches should be visible.
  bool get isPersonalized => mode == NotificationMode.personalized;

  /// @notice Copies this snapshot with selected fields replaced.
  /// @return A new {NotificationSettings}.
  NotificationSettings copyWith({
    NotificationMode? mode,
    bool? ads,
    bool? message,
    bool? newMessage,
    bool? promo,
    bool? transaction,
  }) {
    return NotificationSettings(
      mode: mode ?? this.mode,
      ads: ads ?? this.ads,
      message: message ?? this.message,
      newMessage: newMessage ?? this.newMessage,
      promo: promo ?? this.promo,
      transaction: transaction ?? this.transaction,
    );
  }
}
