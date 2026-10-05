/// @title PhosphorGlyph
/// @notice Minimal Phosphor icon set bundled through the app's own fonts.
/// @dev Two workarounds are stacked here. First, the `phosphor_flutter`
/// package cannot be used on this SDK: it declares
/// `class PhosphorIconData extends IconData`, and `IconData` is a final class,
/// which fails at compile time. Second, fonts declared under `flutter.fonts`
/// are still subject to icon tree-shaking, and a subset built from `IconData`
/// constants came out empty. Rendering the code point as text keeps the font
/// intact, because text fonts are not shaken. The TTFs live in
/// assets/fonts and are declared in pubspec.yaml.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';

/// @title PhosphorWeight
/// @notice Available Phosphor font weights bundled with the app.
enum PhosphorWeight {
  /// @dev Outline weight.
  regular('Phosphor'),

  /// @dev Solid weight.
  fill('PhosphorFill'),

  /// @dev Heavier outline weight.
  bold('PhosphorBold');

  const PhosphorWeight(this.fontFamily);

  /// @dev Font family name declared in pubspec.yaml.
  final String fontFamily;
}

/// @title PhosphorCode
/// @notice Glyph code points used by the app.
class PhosphorCode {
  // @dev Prevents instantiation of this utility holder.
  const PhosphorCode._();

  /// @dev Heart outline.
  static const int heart = 0xe2a8;

  /// @dev Three horizontal dots.
  static const int dotsThree = 0xe1fe;

  /// @dev Left arrow.
  static const int arrowLeft = 0xe058;

  /// @dev Speech bubble with a dot.
  static const int chatCircle = 0xe168;

  /// @dev Star outline.
  static const int star = 0xe46a;

  /// @dev Filled dot, used as an online indicator.
  static const int dot = 0xecde;

  /// @dev User silhouette, used on profile setting.
  static const int user = 0xe4c2;

  /// @dev Crescent moon, used on dark mode.
  static const int moon = 0xe330;

  /// @dev Sun, used when dark mode is on.
  static const int sun = 0xe472;

  /// @dev Bar chart, used on analytic.
  static const int chartBar = 0xe150;

  /// @dev Package box, used on the seller catalogue list.
  static const int package = 0xe390;

  /// @dev Question mark in a circle, used on help desk.
  static const int question = 0xe3e8;

  /// @dev Headset, used on contact support.
  static const int headset = 0xe584;

  /// @dev Right chevron, used on tappable setting rows.
  static const int caretRight = 0xe13a;

  /// @dev Map pin, used on location labels.
  static const int mapPin = 0xe316;

  /// @dev Plus, used on the chat composer attach control.
  static const int plus = 0xe3d4;

  /// @dev Microphone, used on the chat composer voice control.
  static const int microphone = 0xe326;

  /// @dev Clock, used on last-active lines.
  static const int clock = 0xe190;

  /// @dev Gear, used on the general setting row.
  static const int gear = 0xe278;

  /// @dev Bell, used on notification rows.
  static const int bell = 0xe096;

  /// @dev Simple lock, used on change password.
  static const int lockSimple = 0xe300;

  /// @dev Sign-out door arrow, used on logout.
  static const int signOut = 0xe3e6;

  /// @dev Megaphone, used on the ads notification switch.
  static const int megaphone = 0xe31c;

  /// @dev Envelope, used on the new-message notification switch.
  static const int envelope = 0xe21c;

  /// @dev Brain, used on the Home AI overlay.
  static const int brain = 0xe74e;

  /// @dev Paper plane, used to send an AI prompt.
  static const int paperPlaneTilt = 0xe398;

  /// @dev Copy, used under AI chat bubbles.
  static const int copy = 0xe1ca;

  /// @dev Clockwise arrow, used to re-prompt a bubble.
  static const int arrowClockwise = 0xe036;

  /// @dev Down chevron, used to minimize the AI panel.
  static const int caretDown = 0xe136;

  /// @dev Up chevron, used to expand a minimized AI panel.
  static const int caretUp = 0xe13c;

  /// @dev Stacked chats, used to open AI chat history.
  static const int chats = 0xe17c;
}

/// @title PhosphorGlyph
/// @notice Renders one Phosphor glyph at a given size and weight.
class PhosphorGlyph extends StatelessWidget {
  /// @notice Creates a glyph.
  /// @param codePoint Glyph code point, see [PhosphorCode].
  /// @param weight Font weight to draw with.
  /// @param size Glyph box size in logical pixels.
  /// @param color Glyph colour.
  /// @return A new {PhosphorGlyph} instance.
  const PhosphorGlyph(
    this.codePoint, {
    this.weight = PhosphorWeight.regular,
    this.size = 16,
    this.color,
    super.key,
  });

  /// @dev Glyph code point.
  final int codePoint;

  /// @dev Font weight to draw with.
  final PhosphorWeight weight;

  /// @dev Glyph box size in logical pixels.
  final double size;

  /// @dev Glyph colour.
  final Color? color;

  /// @notice Builds the glyph.
  /// @param context The build context.
  /// @return The glyph widget.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Text(
        String.fromCharCode(codePoint),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: weight.fontFamily,
          fontSize: size,
          height: 1,
          color: color,
        ),
      ),
    );
  }
}
