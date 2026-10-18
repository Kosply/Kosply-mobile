/// @title StorageKeys
/// @notice Shared preference and secure-storage keys used across the app.
/// @dev Keeping the keys here avoids silent typos between the notifier that
/// writes a value and the one that reads it back.
/// @author Kosply-mobile
library;

/// @title StorageKeys
/// @notice Canonical key names for {PreferencesStore} and {SecureStore}.
abstract final class StorageKeys {
  /// @dev Dark-mode flag written by the theme setting.
  static const String themeDark = 'settings.theme_dark';

  /// @dev Buyer or seller role name from {AccountMode.name}.
  static const String accountMode = 'settings.account_mode';

  /// @dev Notification master mode name from {NotificationMode.name}.
  static const String notificationMode = 'settings.notification.mode';

  /// @dev Ads channel flag.
  static const String notificationAds = 'settings.notification.ads';

  /// @dev Chat message channel flag.
  static const String notificationMessage = 'settings.notification.message';

  /// @dev New-thread channel flag.
  static const String notificationNewMessage = 'settings.notification.new_message';

  /// @dev Promo channel flag.
  static const String notificationPromo = 'settings.notification.promo';

  /// @dev Transaction channel flag.
  static const String notificationTransaction = 'settings.notification.transaction';

  /// @dev Access token written after a successful sign-in.
  static const String accessToken = 'auth.access_token';

  /// @dev Refresh token paired with {accessToken}.
  static const String refreshToken = 'auth.refresh_token';

  /// @dev Account email shown while the session is restored.
  static const String authEmail = 'auth.email';

  /// @dev Display name captured from the provider at sign-in.
  static const String authDisplayName = 'auth.display_name';

  /// @dev Provider name from {AuthProvider.name}.
  static const String authProvider = 'auth.provider';

  /// @dev '1' while the account still needs campus data filled.
  static const String authOnboarding = 'auth.onboarding_required';
}
