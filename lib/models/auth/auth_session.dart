/// @title AuthSession
/// @notice Signed-in account of the current device.
/// @dev Only the token pair is secret; all fields are persisted through
/// {SecureStore} so a restart can restore the session without the backend.
/// @author Kosply-mobile
library;

/// @title AuthProvider
/// @notice Provider that created the session.
enum AuthProvider {
  /// @dev Google sign-in from onboarding.
  google,

  /// @dev Email and password sign-up or sign-in.
  email,
}

/// @title AuthSession
/// @notice Email, display name, provider, and the token pair.
class AuthSession {
  /// @notice Creates a session.
  /// @param email Account email.
  /// @param displayName Name shown across the app.
  /// @param provider Provider that created the session.
  /// @param accessToken Short-lived token sent to the backend.
  /// @param refreshToken Long-lived token used to renew the access token.
  /// @param onboardingRequired Whether campus data still needs to be filled.
  /// @return A new {AuthSession} instance.
  const AuthSession({
    required this.email,
    required this.displayName,
    required this.provider,
    required this.accessToken,
    required this.refreshToken,
    this.onboardingRequired = false,
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

  /// @notice Whether the session came from Google.
  bool get isGoogle => provider == AuthProvider.google;

  /// @notice Copies this session with selected fields replaced.
  /// @param onboardingRequired New onboarding flag.
  /// @return A new {AuthSession}.
  AuthSession copyWith({bool? onboardingRequired}) {
    return AuthSession(
      email: email,
      displayName: displayName,
      provider: provider,
      accessToken: accessToken,
      refreshToken: refreshToken,
      onboardingRequired: onboardingRequired ?? this.onboardingRequired,
    );
  }
}
