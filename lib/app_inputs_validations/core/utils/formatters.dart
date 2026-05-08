import 'package:flutter/services.dart';

// =============================================================================
// 📦 AppFormatters — Custom Input Formatters
// =============================================================================
//
// WHY THIS FILE EXISTS:
// InputFormatters intercept every keystroke *before* it reaches the field's
// value. This is more reliable and user-friendly than post-submit validation
// because it makes invalid input physically impossible to enter.
//
// Three layers of input defense:
//   1. keyboardType  → hints the OS which keyboard to show
//   2. inputFormatters → enforces/transforms characters as they are typed
//   3. validator     → semantic validation on submit / user interaction
// =============================================================================

/// Converts every character to uppercase as the user types.
///
/// Real-world use: coupon codes, licence plate fields, reference IDs.
///
/// Extends [TextInputFormatter] and overrides [formatEditUpdate], which
/// Flutter calls on every keystroke, passing the old and new values.
/// We return a copy of [newValue] with the text uppercased, preserving
/// the cursor position automatically via [TextEditingValue.copyWith].
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // copyWith preserves the cursor position and selection — very important!
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
    );
  }
}

/// Convenience class that groups commonly used formatters as named constants.
///
/// Usage:
/// ```dart
/// inputFormatters: [AppFormatters.noSpaces],
/// inputFormatters: [AppFormatters.digitsOnly],
/// inputFormatters: [AppFormatters.upperCase],
/// ```
class AppFormatters {
  /// Blocks whitespace characters (space, tab, newline) from being entered.
  /// Real-world use: usernames, handles, slugs.
  static final TextInputFormatter noSpaces =
      FilteringTextInputFormatter.deny(RegExp(r'\s'));

  /// Allows only digit characters 0–9.
  /// Real-world use: OTP fields, phone numbers, PIN inputs.
  static final TextInputFormatter digitsOnly =
      FilteringTextInputFormatter.digitsOnly;

  /// Converts all input to uppercase on each keystroke.
  /// Real-world use: coupon codes, reference numbers.
  static final TextInputFormatter upperCase = UpperCaseFormatter();
}
