/// @title SteppedForm
/// @notice Reusable one-input-per-step form driven by a list of {FormStep}s.
/// @dev Owns the step index, the per-step controllers, the four code
/// controllers used by the verification step, the error state, and the pinned
/// Back + Continue bar. Both the registration form and the forgot-password
/// flow are built on top of this widget, so their behaviour cannot drift
/// apart.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/form_step.dart';
import 'auth_scaffold.dart';
import 'auth_text_field.dart';
import 'email_code_verification.dart';
import 'form_actions.dart';
import 'form_heading.dart';

/// @title SteppedForm
/// @notice Stateful multi-step form with a single input per step.
class SteppedForm extends StatefulWidget {
  /// @notice Creates a stepped form.
  /// @param steps Ordered list of steps to render.
  /// @param onCompleted Called when the last step is submitted successfully.
  /// @param onExit Called when Back is pressed on the first step; defaults to
  /// popping the current route.
  /// @param continueLabel Label of the primary button.
  /// @param emailStepIndex Index of the step holding the email address shown
  /// in the verification reminder line.
  /// @return A new {SteppedForm} instance.
  const SteppedForm({
    required this.steps,
    required this.onCompleted,
    this.onExit,
    this.continueLabel = 'Continue',
    this.emailStepIndex = 0,
    super.key,
  });

  /// @dev Ordered list of steps to render.
  final List<FormStep> steps;

  /// @dev Called when the last step is submitted successfully.
  final VoidCallback onCompleted;

  /// @dev Called when Back is pressed on the first step.
  final VoidCallback? onExit;

  /// @dev Label of the primary button.
  final String continueLabel;

  /// @dev Index of the step holding the email address.
  final int emailStepIndex;

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
      () => TextEditingController(),
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
        Navigator.of(context).pop();
      }
      return;
    }
    setState(() {
      _step--;
      _error = null;
    });
  }

  /// @notice Validates the active step and advances when valid.
  /// @dev Calls {SteppedForm.onCompleted} after the last step.
  /// @return void
  void _onContinue() {
    final step = widget.steps[_step];
    final error = step.validator(_currentValue());
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (_step == widget.steps.length - 1) {
      widget.onCompleted();
      return;
    }
    setState(() {
      _step++;
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

    return AuthScaffold(
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
              onResend: () {},
            )
          else
            AuthTextField(
              controller: _controllerFor(_step),
              hint: step.hint,
              helper: step.helper,
              error: _error,
              obscure: step.obscure,
              keyboardType: step.keyboardType,
              onChanged: (_) => _clearError(),
            ),
        ],
      ),
      bottomBar: FormActions(
        onBack: _onBack,
        onContinue: _onContinue,
        continueLabel: widget.continueLabel,
      ),
    );
  }
}