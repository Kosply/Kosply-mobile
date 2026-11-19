/// @title Local user
/// @notice Identifiers of the signed-in student inside the local cache.
/// @dev The backend fills the real account id after login; until then the
/// offline-first cache uses a single local row so chat bubbles can tell
/// "mine" from "theirs".
/// @author Kosply-mobile
library;

/// @dev Identifier used for the local account row and its messages.
const String localUserId = 'me';
