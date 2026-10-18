/// @title UI bridge element ids
/// @notice id shapes the AI reads from `ui_state.elements` and the click
/// registrations screens record.
/// @dev Mirrors `ui_tools.md`: catalog cards, inputs, and buttons.
/// @author Kosply-mobile
library;

/// @title UiIds
/// @notice Builders for the click-convention ids.
abstract final class UiIds {
  /// @notice Catalog card id for [productId].
  /// @param productId Backend product id.
  /// @return `product:<id>`.
  static String product(String productId) => 'product:$productId';

  /// @notice Input id for the field called [name].
  /// @param name Field name, e.g. `search` or `bio`.
  /// @return `input:<name>`.
  static String input(String name) => 'input:$name';

  /// @notice Button id for [action], optionally scoped to [target].
  /// @param action Verb, e.g. `chat` or `send`.
  /// @param target Optional subject, e.g. a product id.
  /// @return `btn:<action>` or `btn:<action>:<target>`.
  static String button(String action, {String? target}) =>
      target == null ? 'btn:$action' : 'btn:$action:$target';
}
