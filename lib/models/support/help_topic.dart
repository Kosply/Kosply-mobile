/// @title HelpTopic
/// @notice One common campus-marketplace problem shown in Help desk.
/// @author Kosply-mobile
library;

/// @title HelpTopic
/// @notice FAQ entry: a short title and the answer shown when the row expands.
class HelpTopic {
  /// @notice Creates a help topic.
  /// @param title Label shown on the expandable row.
  /// @param answer Guidance shown when the row is expanded.
  /// @return A new {HelpTopic} instance.
  const HelpTopic({required this.title, required this.answer});

  /// @dev Label shown on the expandable row.
  final String title;

  /// @dev Guidance shown when the row is expanded.
  final String answer;
}
