/// @title AuthSession
/// @notice Signed-in account of the current device.
/// @dev Only the token pair is secret; all fields are persisted through
/// {SecureStore} so a restart can restore the session without the backend.
/// [userId] is the backend `users.id`: every "is this mine?" check in the app
/// (chat bubbles, the seller's own shelf) compares against it.
/// @author Kosply-mobile
library;

/// @title AuthProvider
/// @notice Provider that created the session.
enum AuthProvider {
  /// @dev Google sign-in from onboarding.
  google,

  /// @dev Email and password sign-up or sign-in.
  email,

  /// @dev Sign in with Apple.
  apple,
}

/// @title AuthSession
/// @notice Identity, provider, and the token pair.
class AuthSession {
  /// @notice Creates a session.
  /// @param email Account email.
  /// @param displayName Name shown across the app.
  /// @param provider Provider that created the session.
  /// @param accessToken Short-lived token sent to the backend.
  /// @param refreshToken Long-lived token used to renew the access token.
  /// @param onboardingRequired Whether campus data still needs to be filled.
  /// @param userId Backend `users.id` of the account.
  /// @param username Marketplace handle.
  /// @param role `BUYER`, `SELLER`, or a staff role.
  /// @return A new {AuthSession} instance.
  const AuthSession({
    required this.email,
    required this.displayName,
    required this.provider,
    required this.accessToken,
    required this.refreshToken,
    this.onboardingRequired = false,
    this.userId = '',
    this.username = '',
    this.role = 'BUYER',
  });

  /// @dev Account email.
  final String email;

  /// @dev Name shown across the app.
  final String displayName;

  /// @dev Provider that created the session.
  final AuthProvider provider;

  /// @dev Short-lived token sent to the backend.
  final String accessToken;

  /// @dev Long-lived token used to renew the access token.
  final String refreshToken;

  /// @dev Whether campus data still needs to be filled.
  final bool onboardingRequired;

  /// @dev Backend `users.id` of the account.
  final String userId;

  /// @dev Marketplace handle.
  final String username;

  /// @dev `BUYER`, `SELLER`, or a staff role.
  final String role;

  /// @notice Whether the session came from Google.
  bool get isGoogle => provider == AuthProvider.google;

  /// @notice Whether the session came from Apple.
  bool get isApple => provider == AuthProvider.apple;

  /// @notice Label shown next to the signed-in email.
  String get providerLabel {
    switch (provider) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.email:
        return 'Email';
    }
  }

  /// @notice Whether the backend lets this account post listings.
  bool get canSell => role == 'SELLER' || role == 'ADMIN' || role == 'SUPER_ADMIN';

  /// @notice Copies this session with selected fields replaced.
  /// @param onboardingRequired New onboarding flag.
  /// @param accessToken New access token.
  /// @param refreshToken New refresh token.
  /// @param displayName New display name.
  /// @param username New handle.
  /// @param role New role.
  /// @return A new {AuthSession}.
  AuthSession copyWith({
    bool? onboardingRequired,
    String? accessToken,
    String? refreshToken,
    String? displayName,
    String? username,
    String? role,
  }) {
    return AuthSession(
      email: email,
      displayName: displayName ?? this.displayName,
      provider: provider,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      onboardingRequired: onboardingRequired ?? this.onboardingRequired,
      userId: userId,
      username: username ?? this.username,
      role: role ?? this.role,
    );
  }
}
