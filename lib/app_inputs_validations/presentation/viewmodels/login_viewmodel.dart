import 'dart:async';
import 'package:flutter/foundation.dart';

// =============================================================================
// 🧠 LoginViewModel — Business Logic Layer (MVVM)
// =============================================================================
//
// WHAT THIS FILE DOES:
//  - Owns all state that the LoginScreen needs (loading, errors, async results)
//  - Completely decoupled from the UI — no BuildContext, no widgets
//  - Implements debouncing and async validation at the ViewModel level,
//    keeping validators.dart pure/synchronous (as Flutter requires)
//
// NEW CONCEPTS IN THIS VERSION:
//  1. Debouncing    — Timer delays API call until typing stops
//  2. Async Validation — email uniqueness check simulation
//  3. ValueNotifier — isolates password-visibility rebuilds to single fields
// =============================================================================

/// ViewModel responsible for handling the business logic of the Login screen.
/// Decoupling state from the UI makes our application production-ready.
class LoginViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // 🔄 Authentication State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // 🔑 Field-Level Rebuild Optimization — ValueNotifier
  //
  // WHY VALUENOTIFIER INSTEAD OF SETSTATE?
  //   setState() on the parent widget rebuilds the *entire* form — all fields,
  //   all decorations, all validators. For a small form this is acceptable, but
  //   for forms with 20+ fields it causes unnecessary rendering work.
  //
  //   ValueNotifier<T> + ValueListenableBuilder rebuilds ONLY the widget that
  //   wraps it. Toggling password visibility will no longer rebuild the email
  //   field, the submit button, or anything else.
  //
  // PLACEMENT IN VIEWMODEL:
  //   These notifiers live here (not in the View) so they can be tested and
  //   so the View stays purely declarative.
  // ---------------------------------------------------------------------------

  /// Controls whether the password field shows plain text.
  final ValueNotifier<bool> passwordObscured = ValueNotifier(true);

  /// Controls whether the confirm-password field shows plain text.
  final ValueNotifier<bool> confirmPasswordObscured = ValueNotifier(true);

  void togglePasswordVisibility() {
    passwordObscured.value = !passwordObscured.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordObscured.value = !confirmPasswordObscured.value;
  }

  // ---------------------------------------------------------------------------
  // ⏱️ Debouncing — Async Email Availability Check
  //
  // THE PROBLEM WITHOUT DEBOUNCING:
  //   User types "john@gmail.com" (15 characters) → 15 API calls fire
  //   Backend cost explodes. Race conditions occur. UI flickers.
  //
  // THE SOLUTION:
  //   A Timer resets on every keystroke. The API call only fires AFTER the
  //   user pauses for [_debounceDuration]. Typically 400–600ms is ideal:
  //   fast enough to feel responsive, slow enough to avoid spam.
  //
  // RACE CONDITION HANDLING:
  //   We cancel any in-flight timer before starting a new one. This prevents
  //   stale callbacks from overwriting results from a newer request.
  // ---------------------------------------------------------------------------

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 500);

  /// Async email validation error exposed to the UI.
  /// null = no error. Non-null = show this error string near the email field.
  String? emailAvailabilityError;

  /// Validates email availability, debounced.
  ///
  /// Called from the email field's [onChanged] callback. It cancels any
  /// pending timer and starts a fresh one. When the timer fires, it simulates
  /// an API call to check if the email is already registered.
  void onEmailChanged(String value) {
    // Reset any previous async error immediately (field is being edited)
    if (emailAvailabilityError != null) {
      emailAvailabilityError = null;
      notifyListeners();
    }

    // Cancel the previous timer to prevent stale calls
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Only fire the API check if the input looks like it could be an email
    if (value.contains('@') && value.contains('.')) {
      _debounceTimer = Timer(_debounceDuration, () {
        _checkEmailAvailability(value);
      });
    }
  }

  /// Simulates a server-side email uniqueness check.
  ///
  /// In a real app, this calls an AuthRepository method that hits an endpoint.
  /// WHY NOT PUT THIS IN THE VALIDATOR?
  ///   Flutter's [FormField.validator] is synchronous. The framework calls it
  ///   during a build cycle and expects an immediate String?. Making it async
  ///   would require awaiting inside a build, which Flutter does not allow and
  ///   which introduces race conditions.
  ///   The correct pattern is: manage async results externally in the ViewModel,
  ///   expose an error state, and display it via an [ErrorText] or inline UI.
  Future<void> _checkEmailAvailability(String email) async {
    // Simulate network latency (replace with real repo call)
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate a "taken" email for demonstration
    if (email.toLowerCase() == 'test@gmail.com') {
      emailAvailabilityError = 'This email is already registered';
    } else {
      emailAvailabilityError = null;
    }

    notifyListeners(); // Trigger UI update with new async error state
  }

  // ---------------------------------------------------------------------------
  // 🔐 Authentication
  // ---------------------------------------------------------------------------

  /// Simulates an authentication request.
  /// In a real app, this would call an AuthenticationRepository/Data Source.
  Future<bool> authenticateUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Command the UI to show the loading state

    try {
      // Simulate network latency
      await Future.delayed(const Duration(seconds: 2));

      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Authentication failed. Please try again.';
      notifyListeners();
      return false; // Failure
    }
  }

  // ---------------------------------------------------------------------------
  // 🗑️ Disposal — CRITICAL
  //
  // ValueNotifiers must be disposed just like TextEditingControllers.
  // The debounce Timer must be cancelled to avoid callbacks firing after
  // the ViewModel is removed from memory (would cause state-after-dispose errors).
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _debounceTimer?.cancel(); // Prevent ghost API calls after widget dies
    passwordObscured.dispose();
    confirmPasswordObscured.dispose();
    super.dispose();
  }
}
