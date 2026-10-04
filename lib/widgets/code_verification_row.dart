/// @title CodeVerificationRow
/// @notice Four boxed code inputs, one digit each, used by every screen that
/// asks for an email verification code.
/// @dev Shared widget so the registration and forgot-password flows show the
/// same code entry. Each box accepts a single digit, filters non-digits, and
/// moves focus forward (or backward when a box is cleared).
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/kosply_colors.dart';

/// @title CodeVerificationRow
/// @notice Row of four square digit boxes.
/// @dev Stateless; the digit logic lives in {_onChanged}.
class CodeVerificationRow extends StatelessWidget {
  /// @notice Creates the code row.
  /// @param controllers One controller per box.
  /// @param focusNodes One focus node per box.
  /// @param hasError Whether to paint the boxes with the error colour.
  /// @param onChanged Called whenever any box value changes.
  /// @param boxColor Background colour of each box.
  /// @return A new {CodeVerificationRow} instance.
  const CodeVerificationRow({
    required this.controllers,
    required this.focusNodes,
    required this.hasError,
    required this.onChanged,
    this.boxColor = KosplyColors.inputFill,
    super.key,
  });

  /// @dev One controller per box.
  final List<TextEditingController> controllers;

  /// @dev One focus node per box.
  final List<FocusNode> focusNodes;

  /// @dev Whether to paint the boxes with the error colour.
  final bool hasError;

  /// @dev Called whenever any box value changes.
  final VoidCallback onChanged;

  /// @dev Background colour of each box.
  final Color boxColor;

  /// @notice Handles typing in one code box.
  /// @dev Keeps a single digit per box, drops non-digits, and moves focus to
  /// the next box (or the previous one when the box is cleared).
  /// @param index Index of the edited box.
  /// @param value The new raw value.
  /// @return void
  void _onChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      controllers[index].clear();
      onChanged();
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
      return;
    }
    controllers[index].text = digits.substring(0, 1);
    onChanged();
    if (index < controllers.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus();
    }
  }

  /// @notice Builds the row of code boxes.
  /// @param context The build context.
  /// @return The code row widget.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < controllers.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _CodeBox(
              controller: controllers[i],
              focusNode: focusNodes[i],
              hasError: hasError,
              boxColor: boxColor,
              onChanged: (value) => _onChanged(i, value),
            ),
          ),
        ],
      ],
    );
  }

  /// @notice Joins the current box values into one code string.
  /// @return The joined digits.
  String get value => controllers.map((c) => c.text).join();
}

/// @title _CodeBox
/// @notice Single square box holding one verification digit.
/// @dev Numeric keyboard, one character maximum, digits only.
class _CodeBox extends StatelessWidget {
  /// @notice Creates a code box.
  /// @param controller Controller owning the digit.
  /// @param focusNode Focus node for this box.
  /// @param hasError Whether to show the error border colour.
  /// @param boxColor Background colour of the box.
  /// @param onChanged Called when the value changes.
  /// @return A new {_CodeBox} instance.
  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.boxColor,
    required this.onChanged,
  });

  /// @dev Controller owning the digit.
  final TextEditingController controller;

  /// @dev Focus node for this box.
  final FocusNode focusNode;

  /// @dev Whether to show the error border colour.
  final bool hasError;

  /// @dev Background colour of the box.
  final Color boxColor;

  /// @dev Called when the value changes.
  final ValueChanged<String> onChanged;

  /// @notice Builds the square code box.
  /// @param context The build context.
  /// @return The code box widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: boxColor,
        border: Border(
          bottom: BorderSide(
            color: hasError ? KosplyColors.error : KosplyColors.inputBorder,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}