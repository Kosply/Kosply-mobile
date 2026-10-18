/// @title UI bridge registry
/// @notice Publishes what each screen shows so the AI can read it through
/// `ui_state`, and offers the safe callbacks Flutter implements.
/// @dev Protocol: `ui_tools.md`. Screens wrap their body in {UiBridgeScope}.
/// @author Kosply-mobile
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui_ids.dart';

/// @title UiCallbacks
/// @notice Safe callback names Flutter implements for the agent.
/// @dev Unknown names are refused backend-side; keep this list in sync.
abstract final class UiCallbacks {
  /// @notice Open a catalog detail screen.
  static const String openProduct = 'open_product';

  /// @notice Bring an already visible element into view.
  static const String showProduct = 'show_product';

  /// @notice Apply a catalog filter.
  static const String applyFilter = 'apply_filter';

  /// @notice Clear the active catalog filter.
  static const String clearFilter = 'clear_filter';

  /// @notice Scroll the active list to an element.
  static const String scrollTo = 'scroll_to';

  /// @notice Highlight an element briefly.
  static const String highlight = 'highlight';

  /// @notice Show a toast message.
  static const String showToast = 'show_toast';

  /// @notice Open the chat with a seller.
  static const String openChat = 'open_chat';

  /// @notice Focus an input field.
  static const String focusInput = 'focus_input';

  /// @notice Switch to another screen.
  static const String openScreen = 'open_screen';

  /// @notice Every safe name above.
  static const Set<String> safe = <String>{
    openProduct,
    showProduct,
    applyFilter,
    clearFilter,
    scrollTo,
    highlight,
    showToast,
    openChat,
    focusInput,
    openScreen,
  };
}

/// @title UiElementKinds
/// @notice Kind tags attached to published elements.
abstract final class UiElementKinds {
  /// @notice Catalog card.
  static const String product = 'product';

  /// @notice Tappable button.
  static const String button = 'button';

  /// @notice Text input.
  static const String input = 'input';

  /// @notice Static text block.
  static const String text = 'text';

  /// @notice Conversation row.
  static const String conversation = 'conversation';
}

/// @title UiElement
/// @notice One visible, addressable thing on the current screen.
@immutable
class UiElement {
  /// @notice Creates an element snapshot.
  /// @param id Convention id from {UiIds}.
  /// @param kind One of {UiElementKinds}.
  /// @param label Human readable text the model may quote.
  /// @param callback Safe action tapping it triggers, if any.
  /// @param args Arguments for that action.
  /// @return A new {UiElement} instance.
  const UiElement({
    required this.id,
    required this.kind,
    this.label = '',
    this.callback,
    this.args = const <String, Object?>{},
  });

  /// @notice Catalog card for [productId] tagged with the open callback.
  /// @param productId Backend product id.
  /// @param label Visible title.
  /// @return A new {UiElement} instance.
  factory UiElement.product(String productId, {String label = ''}) {
    return UiElement(
      id: UiIds.product(productId),
      kind: UiElementKinds.product,
      label: label,
      callback: UiCallbacks.openProduct,
      args: <String, Object?>{'productId': productId},
    );
  }

  /// @notice Button element for [action].
  /// @param action Verb, e.g. `send`.
  /// @param label Visible text.
  /// @param target Optional subject, e.g. a product id.
  /// @param callback Safe action the button triggers, if any.
  /// @param args Arguments for that action.
  /// @return A new {UiElement} instance.
  factory UiElement.button(
    String action, {
    String label = '',
    String? target,
    String? callback,
    Map<String, Object?> args = const <String, Object?>{},
  }) {
    return UiElement(
      id: UiIds.button(action, target: target),
      kind: UiElementKinds.button,
      label: label,
      callback: callback,
      args: args,
    );
  }

  /// @dev Convention id.
  final String id;

  /// @dev Kind tag.
  final String kind;

  /// @dev Visible text.
  final String label;

  /// @dev Safe callback name.
  final String? callback;

  /// @dev Callback arguments.
  final Map<String, Object?> args;

  /// @notice JSON shape the agent reads.
  /// @return The element as a map.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'kind': kind,
      if (label.isNotEmpty) 'label': label,
      if (callback != null) 'callback': callback,
      if (args.isNotEmpty) 'args': args,
    };
  }
}

/// @title UiClick
/// @notice The last element the user tapped, as `ui_state.last_click`.
@immutable
class UiClick {
  /// @notice Creates a click record.
  /// @param id Convention id of the tapped element.
  /// @param kind Kind tag of the tapped element.
  /// @return A new {UiClick} instance.
  const UiClick({required this.id, required this.kind});

  /// @dev Convention id.
  final String id;

  /// @dev Kind tag.
  final String kind;

  /// @notice JSON shape the agent reads.
  /// @return The click as a map.
  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'kind': kind};
}

/// @title UiBridgeState
/// @notice Snapshot of the screen the user is looking at.
@immutable
class UiBridgeState {
  /// @notice Creates a snapshot.
  /// @param screen Current screen name, e.g. `home`.
  /// @param elements Addressable elements on screen.
  /// @param selection Active selection, e.g. filters or the focused chat.
  /// @param lastClick Last tapped element.
  /// @return A new {UiBridgeState} instance.
  const UiBridgeState({
    this.screen = '',
    this.elements = const <UiElement>[],
    this.selection = const <String, Object?>{},
    this.lastClick,
  });

  /// @dev Current screen name.
  final String screen;

  /// @dev Addressable elements.
  final List<UiElement> elements;

  /// @dev Active selection.
  final Map<String, Object?> selection;

  /// @dev Last tapped element.
  final UiClick? lastClick;

  /// @notice JSON snapshot sent as the turn's `ui_state`; empty when hidden.
  /// @return The snapshot map, or null when no screen is published.
  Map<String, Object?>? toJson() {
    if (screen.isEmpty) {
      return null;
    }
    return <String, Object?>{
      'screen': screen,
      if (elements.isNotEmpty)
        'elements': elements
            .map((UiElement element) => element.toJson())
            .toList(),
      if (selection.isNotEmpty) 'selection': selection,
      if (lastClick != null) 'last_click': lastClick!.toJson(),
    };
  }
}

/// @title UiBridgeNotifier
/// @notice Holds the current screen snapshot; screens publish through
/// {UiBridgeScope}.
class UiBridgeNotifier extends Notifier<UiBridgeState> {
  /// @notice Creates the empty state.
  /// @return The initial {UiBridgeState}.
  @override
  UiBridgeState build() => const UiBridgeState();

  /// @notice Publishes what [screen] currently shows.
  /// @param screen Screen name.
  /// @param elements Addressable elements.
  /// @param selection Active selection.
  /// @return void
  void publish({
    required String screen,
    List<UiElement> elements = const <UiElement>[],
    Map<String, Object?> selection = const <String, Object?>{},
  }) {
    if (state.screen == screen &&
        identical(state.elements, elements) &&
        mapEquals(state.selection, selection)) {
      return;
    }
    state = UiBridgeState(
      screen: screen,
      elements: elements,
      selection: selection,
      lastClick: state.lastClick,
    );
  }

  /// @notice Records the last tapped element.
  /// @param id Convention id.
  /// @param kind Kind tag.
  /// @return void
  void recordClick({required String id, required String kind}) {
    state = UiBridgeState(
      screen: state.screen,
      elements: state.elements,
      selection: state.selection,
      lastClick: UiClick(id: id, kind: kind),
    );
  }

  /// @notice Drops the snapshot, e.g. when the app leaves the tabs.
  /// @return void
  void reset() => state = const UiBridgeState();
}

/// @title uiBridgeProvider
/// @notice Current screen snapshot for the AI turn payload.
final NotifierProvider<UiBridgeNotifier, UiBridgeState> uiBridgeProvider =
    NotifierProvider<UiBridgeNotifier, UiBridgeState>(UiBridgeNotifier.new);
