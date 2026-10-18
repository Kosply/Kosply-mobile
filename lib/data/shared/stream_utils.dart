/// @title Stream utilities
/// @notice Small helpers for combining the DAO streams.
/// @dev The inbox, support, and AI repositories need a table plus its messages
/// to build a list row; combining the two watches keeps every query a plain
/// Drift select so stream updates stay predictable.
/// @author Kosply-mobile
library;

import 'dart:async';

/// @notice Combines the latest value of [first] with the latest of [second].
/// @dev Emits only after both sources have a value, then re-emits on either
/// change. Errors are forwarded; the result closes when both inputs close.
/// @param first Stream providing `A` values.
/// @param second Stream providing `B` values.
/// @param combine Builds the result from the latest pair.
/// @return The combined stream.
Stream<R> combineLatest2<A, B, R>(
  Stream<A> first,
  Stream<B> second,
  R Function(A first, B second) combine,
) {
  late final StreamController<R> controller;
  StreamSubscription<A>? firstSub;
  StreamSubscription<B>? secondSub;
  A? firstValue;
  B? secondValue;
  bool hasFirst = false;
  bool hasSecond = false;
  bool firstDone = false;
  bool secondDone = false;

  void emit() {
    if (hasFirst && hasSecond && !controller.isClosed) {
      controller.add(combine(firstValue as A, secondValue as B));
    }
  }

  void maybeClose() {
    if (firstDone && secondDone && !controller.isClosed) {
      unawaited(controller.close());
    }
  }

  controller = StreamController<R>(
    onListen: () {
      firstSub = first.listen(
        (A value) {
          firstValue = value;
          hasFirst = true;
          emit();
        },
        onError: controller.addError,
        onDone: () {
          firstDone = true;
          maybeClose();
        },
      );
      secondSub = second.listen(
        (B value) {
          secondValue = value;
          hasSecond = true;
          emit();
        },
        onError: controller.addError,
        onDone: () {
          secondDone = true;
          maybeClose();
        },
      );
    },
    onPause: () {
      firstSub?.pause();
      secondSub?.pause();
    },
    onResume: () {
      firstSub?.resume();
      secondSub?.resume();
    },
    onCancel: () {
      unawaited(firstSub?.cancel());
      unawaited(secondSub?.cancel());
    },
  );
  return controller.stream;
}
