/// @title UI command host
/// @notice Runs the agent's callbacks against the navigator the user sees.
/// @dev Place this above the tab body. It closes the AI panel before a
/// navigation or scroll so the movement is visible.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/inbox/inbox_repository.dart';
import '../../models/chat/ai_turn.dart';
import '../../providers/chat/ai_chat_provider.dart';
import '../../providers/inbox/inbox_providers.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../../screens/main/favorite/favorite_screen.dart';
import '../../screens/main/inbox/chat_detail_screen.dart';
import '../../screens/seller/product/product_view_screen.dart';
import '../../screens/support/help/help_desk_screen.dart';
import 'catalog_filter.dart';
import 'ui_bridge.dart';
import 'ui_commands.dart';
import 'ui_ids.dart';

/// @title UiCommandHost
/// @notice Listens for queued callbacks and runs them.
class UiCommandHost extends ConsumerWidget {
  /// @notice Creates a host around [child].
  /// @param child The tab shell.
  /// @return A new {UiCommandHost} instance.
  const UiCommandHost({required this.child, super.key});

  /// @dev The tab shell.
  final Widget child;

  /// @notice Builds [child] and drains the callback queue after each frame.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The wrapped child.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<List<UiCallback>>(uiCommandsProvider, (
      List<UiCallback>? previous,
      List<UiCallback> next,
    ) {
      if (next.isEmpty) {
        return;
      }
      final List<UiCallback> batch = ref
          .read(uiCommandsProvider.notifier)
          .take();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        for (final UiCallback callback in batch) {
          unawaited(_run(context, ref, callback));
        }
      });
    });
    return child;
  }
}

/// @notice Runs one callback. Unknown names are ignored.
/// @param context Navigator context.
/// @param ref Riverpod handle.
/// @param callback Action from the agent.
/// @return Future completing when the action has started.
Future<void> _run(
  BuildContext context,
  WidgetRef ref,
  UiCallback callback,
) async {
  if (!UiCallbacks.safe.contains(callback.name)) {
    return;
  }
  final Map<String, Object?> args = callback.args;
  switch (callback.name) {
    case UiCallbacks.showToast:
      _toast(context, _text(args, const <String>['message', 'text']));
      return;
    case UiCallbacks.applyFilter:
      ref
          .read(catalogFilterProvider.notifier)
          .apply(
            query: _optional(args, const <String>['query', 'q', 'text']),
            category: _optional(args, const <String>['category']),
            maxPrice: _price(args),
            clearPrice: !_has(args, const <String>['maxPrice', 'max_price']),
            replace: true,
          );
      _revealChat(ref);
      return;
    case UiCallbacks.clearFilter:
      ref.read(catalogFilterProvider.notifier).clear();
      _revealChat(ref);
      return;
    case UiCallbacks.focusInput:
      ref.read(navigationIndexProvider.notifier).setIndex(1);
      _revealChat(ref);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(catalogSearchFocusProvider).requestFocus();
      });
      return;
    case UiCallbacks.openScreen:
      _openScreen(context, ref, _text(args, const <String>['screen', 'name']));
      return;
    case UiCallbacks.openProduct:
      final String productId = _productId(args);
      if (productId.isEmpty || !context.mounted) {
        return;
      }
      _revealChat(ref);
      await ProductViewScreen.push(context, productId);
      return;
    case UiCallbacks.showProduct:
    case UiCallbacks.scrollTo:
    case UiCallbacks.highlight:
      await _showElement(context, ref, callback.name, args);
      return;
    case UiCallbacks.openChat:
      await _openChat(context, ref, args);
      return;
  }
}

/// @notice Scrolls to an element, outlining a product card when one is named.
/// @param context Navigator context.
/// @param ref Riverpod handle.
/// @param name Callback name.
/// @param args Callback arguments.
/// @return Future completing when the scroll has started.
Future<void> _showElement(
  BuildContext context,
  WidgetRef ref,
  String name,
  Map<String, Object?> args,
) async {
  final String productId = _productId(args);
  final String anchor = _text(args, const <String>['id', 'target']);
  final String elementId = anchor.isNotEmpty
      ? anchor
      : (productId.isEmpty ? '' : UiIds.product(productId));
  if (productId.isNotEmpty) {
    ref.read(uiHighlightProvider.notifier).flash(productId);
  }
  _revealChat(ref);
  ref.read(navigationIndexProvider.notifier).setIndex(0);
  await Future<void>.delayed(const Duration(milliseconds: 50));
  if (!context.mounted) {
    return;
  }
  final bool seen = elementId.isNotEmpty && _scrollTo(ref, elementId);
  if (!seen && productId.isNotEmpty && name != UiCallbacks.highlight) {
    await ProductViewScreen.push(context, productId);
  }
}

/// @notice Opens a seller room from a product, seller, or conversation id.
/// @param context Navigator context.
/// @param ref Riverpod handle.
/// @param args Callback arguments.
/// @return Future completing when navigation starts.
Future<void> _openChat(
  BuildContext context,
  WidgetRef ref,
  Map<String, Object?> args,
) async {
  final String conversationId = _text(args, const <String>[
    'conversationId',
    'conversation_id',
  ]);
  _revealChat(ref);
  if (conversationId.isNotEmpty) {
    if (context.mounted) {
      await ChatDetailScreen.push(context, conversationId);
    }
    return;
  }
  final InboxRepository inbox = ref.read(inboxRepositoryProvider);
  try {
    final String productId = _productId(args);
    final String sellerId = _text(args, const <String>[
      'sellerId',
      'seller_id',
    ]);
    final String roomId = productId.isNotEmpty
        ? await inbox.openForProduct(productId)
        : (sellerId.isEmpty ? '' : await inbox.openForSeller(sellerId));
    if (context.mounted && roomId.isNotEmpty) {
      await ChatDetailScreen.push(context, roomId);
    }
  } catch (_) {
    if (context.mounted) {
      _toast(context, 'Chat penjual belum bisa dibuka.');
    }
  }
}

/// @notice Switches tabs, or pushes a screen that is not a tab.
/// @param context Navigator context.
/// @param ref Riverpod handle.
/// @param name Screen name from the callback.
/// @return void
void _openScreen(BuildContext context, WidgetRef ref, String name) {
  _revealChat(ref);
  switch (name.trim().toLowerCase()) {
    case 'home':
    case 'beranda':
      ref.read(navigationIndexProvider.notifier).setIndex(0);
      break;
    case 'search':
    case 'cari':
      ref.read(navigationIndexProvider.notifier).setIndex(1);
      break;
    case 'jual':
      ref.read(navigationIndexProvider.notifier).setIndex(2);
      break;
    case 'inbox':
      ref.read(navigationIndexProvider.notifier).setIndex(3);
      break;
    case 'profile':
    case 'profil':
    case 'settings':
      ref.read(navigationIndexProvider.notifier).setIndex(4);
      break;
    case 'favorite':
    case 'favorit':
      FavoriteScreen.push(context);
      break;
    case 'help':
    case 'bantuan':
      HelpDeskScreen.push(context);
      break;
    default:
      _toast(context, 'Layar "$name" tidak dikenal.');
  }
}

/// @notice Scrolls [elementId] into view when its card is mounted.
/// @param ref Riverpod handle.
/// @param elementId Convention id.
/// @return True when the element was on screen.
bool _scrollTo(WidgetRef ref, String elementId) {
  final BuildContext? target = ref
      .read(uiAnchorsProvider)
      .of(elementId)
      .currentContext;
  if (target == null) {
    return false;
  }
  unawaited(
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 350),
      alignment: 0.2,
    ),
  );
  return true;
}

/// @notice Hides the AI panel so the screen underneath can move.
/// @param ref Riverpod handle.
/// @return void
void _revealChat(WidgetRef ref) {
  ref.read(aiChatProvider.notifier).close();
}

/// @notice Shows [message] when it is not empty.
/// @param context Scaffold context.
/// @param message Toast text.
/// @return void
void _toast(BuildContext context, String message) {
  if (message.isEmpty) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// @notice First non-empty string among [keys].
/// @param args Callback arguments.
/// @param keys Candidate keys, in preference order.
/// @return The text, or empty.
String _text(Map<String, Object?> args, List<String> keys) {
  for (final String key in keys) {
    final Object? value = args[key];
    if (value == null) {
      continue;
    }
    final String text = value.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }
  }
  return '';
}

/// @notice Like {_text}, but null when every key is absent.
/// @param args Callback arguments.
/// @param keys Candidate keys.
/// @return The text, or null when omitted.
String? _optional(Map<String, Object?> args, List<String> keys) {
  if (!_has(args, keys)) {
    return null;
  }
  return _text(args, keys);
}

/// @notice Whether any of [keys] is present.
/// @param args Callback arguments.
/// @param keys Candidate keys.
/// @return True when a key exists.
bool _has(Map<String, Object?> args, List<String> keys) {
  for (final String key in keys) {
    if (args.containsKey(key) && args[key] != null) {
      return true;
    }
  }
  return false;
}

/// @notice Reads a rupiah cap, or null when absent.
/// @param args Callback arguments.
/// @return The cap.
int? _price(Map<String, Object?> args) {
  for (final String key in const <String>['maxPrice', 'max_price']) {
    final Object? value = args[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value != null) {
      final int? parsed = int.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

/// @notice Product id from the usual argument names.
/// @param args Callback arguments.
/// @return The id without a `product:` prefix.
String _productId(Map<String, Object?> args) {
  final String raw = _text(args, const <String>[
    'productId',
    'product_id',
    'id',
  ]);
  const String prefix = 'product:';
  return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
}
