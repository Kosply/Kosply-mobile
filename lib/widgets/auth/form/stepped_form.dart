/// @title SteppedForm
/// @notice Reusable one-input-per-step form driven by a list of {FormStep}s.
/// @dev Owns the step index, the per-step controllers, the four code
/// controllers used by the verification step, the error state, and the pinned
/// Back + Continue bar. Both the registration form and the forgot-password
/// flow are built on top of this widget, so their behaviour cannot drift
/// apart.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/form/form_step.dart';
import '../scaffold/auth_scaffold.dart';
import '../fields/auth_text_field.dart';
import '../verification/email_code_verification.dart';
import 'form_actions.dart';
import 'form_heading.dart';

/// @title StepFeedback
/// @notice A server-side refusal of a submitted step.
/// @dev Returned from {SteppedForm.onStepSubmit}; [step] moves the form back
/// to the field the server objected to (e.g. the email step on
/// `EMAIL_TAKEN`), or stays on the current step when null.
class StepFeedback {
  /// @notice Creates feedback.
  /// @param message Error shown under the field.
  /// @param step Step to show it on; null keeps the current step.
  /// @return A new {StepFeedback} instance.
  const StepFeedback(this.message, {this.step});

  /// @dev Error shown under the field.
  final String message;

  /// @dev Step to show it on; null keeps the current step.
  final int? step;
}

/// @title SteppedForm
/// @notice Stateful multi-step form with a single input per step.
class SteppedForm extends StatefulWidget {
  /// @notice Creates a stepped form.
  /// @param steps Ordered list of steps to render.
  /// @param onCompleted Called with one value per step when the last step is
  /// submitted successfully; code steps contribute their joined digits.
  /// @param onExit Called when Back is pressed on the first step; defaults to
  /// {NavigatorState.maybePop}, which never removes the last route.
  /// @param continueLabel Label of the primary button.
  /// @param emailStepIndex Index of the step holding the email address shown
  /// in the verification reminder line.
  /// @param initialValues Prefilled text per step index, e.g. the Google name.
  /// @param onStepSubmit Async check after a step validates locally, e.g. a
  /// backend call; returning feedback keeps the form open with the error.
  /// @param onResend Asks the server for a fresh code. The argument is the
  /// email currently on the form. Null keeps the resend link local.
  /// @return A new {SteppedForm} instance.
  const SteppedForm({
    required this.steps,
    required this.onCompleted,
    this.onStepSubmit,
    this.onResend,
    this.onExit,
    this.continueLabel = 'Continue',
    this.emailStepIndex = 0,
    this.initialValues = const <int, String>{},
    super.key,
  });

  /// @dev Ordered list of steps to render.
  final List<FormStep> steps;

  /// @dev Called with one value per step when the last step is submitted.
  final void Function(List<String> values) onCompleted;

  /// @dev Async check run after a step validates, before the form moves on.
  final Future<StepFeedback?> Function(int step, List<String> values)?
  onStepSubmit;

  /// @dev Asks the server for a fresh code. Null keeps resend local.
  final Future<StepFeedback?> Function(String email)? onResend;

  /// @dev Called when Back is pressed on the first step.
  final VoidCallback? onExit;

  /// @dev Label of the primary button.
  final String continueLabel;

  /// @dev Index of the step holding the email address.
  final int emailStepIndex;

  /// @dev Prefilled text per step index.
  final Map<int, String> initialValues;

  /// @notice Creates the mutable state.
  /// @return The {_SteppedFormState} instance.
  @override
  State<SteppedForm> createState() => _SteppedFormState();
}

/// @title _SteppedFormState
/// @notice Mutable state for {SteppedForm}.
/// @dev Holds one controller per text step plus the code controllers.
class _SteppedFormState extends State<SteppedForm> {
  /// @dev Zero-based index of the active step.
  late int _step = 0;

  /// @dev True while {SteppedForm.onStepSubmit} is waiting on the backend.
  bool _busy = false;

  /// @dev One controller per text step, keyed by step index.
  final Map<int, TextEditingController> _controllers = {};

  /// @dev One controller per verification code box.
  final List<TextEditingController> _codeControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  /// @dev One focus node per verification code box.
  final List<FocusNode> _codeFocusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  /// @dev Validation error for the active step, null when valid.
  String? _error;

  /// @notice Returns (and lazily creates) the controller of a text step.
  /// @param index Step index.
  /// @return The controller for that step.
  TextEditingController _controllerFor(int index) {
    return _controllers.putIfAbsent(
      index,
      () => TextEditingController(text: widget.initialValues[index]),
    );
  }

  /// @notice Releases every controller and focus node.
  /// @return void
  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final node in _codeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// @notice Reads the current value of the active step.
  /// @return The step value, joining the code boxes for the verification step.
  String _currentValue() {
    final step = widget.steps[_step];
    if (step.isCodeStep) {
      return _codeControllers.map((c) => c.text).join();
    }
    return _controllerFor(_step).text;
  }

  /// @notice Moves to the previous step, or exits on the first step.
  /// @return void
  void _onBack() {
    if (_step == 0) {
      final onExit = widget.onExit;
      if (onExit != null) {
        onExit();
      } else {
        Navigator.of(context).maybePop();
      }
      return;
    }
    setState(() {
      _step--;
      _error = null;
    });
  }

  /// @notice Reads one value per step.
  /// @return The step values, code digits joined per code step.
  List<String> _collectValues() {
    return [
      for (int index = 0; index < widget.steps.length; index++)
        if (widget.steps[index].isCodeStep)
          _codeControllers.map((c) => c.text).join()
        else
          _controllerFor(index).text,
    ];
  }

  /// @notice Validates the active step and advances when valid.
  /// @dev Runs {SteppedForm.onStepSubmit} first when given, ignoring taps
  /// while it waits; calls {SteppedForm.onCompleted} after the last step.
  /// @return Future completing when the step is settled.
  Future<void> _onContinue() async {
    if (_busy) {
      return;
    }
    final step = widget.steps[_step];
    final error = step.validator(_currentValue());
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final submit = widget.onStepSubmit;
    if (submit != null) {
      setState(() => _busy = true);
      StepFeedback? feedback;
      try {
        feedback = await submit(_step, _collectValues());
      } finally {
        if (mounted) {
          setState(() => _busy = false);
        }
      }
      if (!mounted) {
        return;
      }
      final StepFeedback? refusal = feedback;
      if (refusal != null) {
        setState(() {
          _step = refusal.step ?? _step;
          _error = refusal.message;
        });
        return;
      }
    }
    if (_step == widget.steps.length - 1) {
      widget.onCompleted(_collectValues());
      return;
    }
    setState(() {
      final int next = _step + 1;
      if (widget.steps[next].isCodeStep) {
        for (final TextEditingController controller in _codeControllers) {
          controller.clear();
        }
      }
      _step = next;
      _error = null;
    });
  }

  /// @notice Asks for a fresh code and clears the boxes when it is accepted.
  /// @return Future completing when the request settles.
  Future<void> _onResend() async {
    final Future<StepFeedback?> Function(String email)? resend = widget.onResend;
    if (resend == null || _busy) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    StepFeedback? feedback;
    try {
      feedback = await resend(_controllerFor(widget.emailStepIndex).text);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
    if (!mounted) {
      return;
    }
    final StepFeedback? refusal = feedback;
    if (refusal != null) {
      setState(() {
        _step = refusal.step ?? _step;
        _error = refusal.message;
      });
      return;
    }
    setState(() {
      for (final TextEditingController controller in _codeControllers) {
        controller.clear();
      }
      _error = null;
    });
  }

  /// @notice Clears a shown error as soon as the user types again.
  /// @return void
  void _clearError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  /// @notice Builds the active step inside the shared shell.
  /// @param context The build context.
  /// @return The stepped form widget.
  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_step];

    // @dev The system back gesture mirrors the on-screen Back: earlier steps
    // @dev first, then the screen's exit hook on the first step.
    return PopScope<Object?>(
      canPop: _step == 0 && widget.onExit == null,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _onBack();
        }
      },
      child: AuthScaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormHeading(step.title),
            const SizedBox(height: 16),
            if (step.isCodeStep)
              EmailCodeVerification(
                controllers: _codeControllers,
                focusNodes: _codeFocusNodes,
                email: _controllerFor(widget.emailStepIndex).text,
                helper: step.helper,
                error: _error,
                onChanged: _clearError,
                onResend: () => unawaited(_onResend()),
              )
            else
              AuthTextField(
                // @dev New field per step. Android keeps the open keyboard's
                // type when one TextField is only updated, so the number pad
                // from NIM stayed up on campus and major.
                key: ValueKey<int>(_step),
                controller: _controllerFor(_step),
                hint: step.hint,
                helper: step.helper,
                error: _error,
                obscure: step.obscure,
                keyboardType: step.keyboardType,
                autofocus: true,
                onChanged: (_) => _clearError(),
              ),
          ],
        ),
        bottomBar: FormActions(
          onBack: _onBack,
          onContinue: () => unawaited(_onContinue()),
          continueLabel: _busy ? 'Please wait…' : widget.continueLabel,
        ),
      ),
    );
  }
}
