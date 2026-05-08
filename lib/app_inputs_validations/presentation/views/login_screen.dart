import 'package:flutter/material.dart';
import '../viewmodels/login_viewmodel.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/formatters.dart';

// =============================================================================
// 🖥️ LoginScreen — Presentation Layer (MVVM View)
// =============================================================================
//
// NEW CONCEPTS DEMONSTRATED IN THIS VERSION:
//
//  1. InputFormatters  — Restrict/transform characters as user types
//  2. FocusNode        — Manual focus control for each field (proper disposal)
//  3. Debouncing       — Async email availability (handled in ViewModel)
//  4. ValueNotifier    — Isolated password-visibility rebuilds (no setState)
//  5. Accessibility    — Semantics wrappers for screen readers
//
// This screen contains ZERO business logic — it only reads from/writes to
// the LoginViewModel. All decisions are made in the ViewModel layer.
// =============================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ---------------------------------------------------------------------------
  // 💡 CORE: Form Key
  //    GlobalKey uniquely identifies the Form, enabling programmatic validation.
  // ---------------------------------------------------------------------------
  final _formKey = GlobalKey<FormState>();

  // ---------------------------------------------------------------------------
  // 💡 CORE: TextEditingControllers
  //    Read/write field values. MUST be disposed to prevent memory leaks.
  // ---------------------------------------------------------------------------
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ---------------------------------------------------------------------------
  // 💡 NEW: FocusNode — Manual Focus Management
  //
  // WHY FOCUSNODE INSTEAD OF JUST nextFocus()?
  //   FocusScope.of(context).nextFocus() blindly moves to the next focusable
  //   widget in the tree — which works for simple linear forms but breaks when:
  //     - Form fields are in different widget branches
  //     - You need to skip fields programmatically
  //     - You need to react to focus events (e.g., trigger validation on blur)
  //     - Accessibility tools (screen readers) navigate via focus
  //     - Desktop/web apps require keyboard-first navigation
  //
  //   FocusNode gives you a named handle to a specific field, enabling:
  //     - requestFocus()   → move cursor to this exact field
  //     - unfocus()        → dismiss keyboard
  //     - addListener()    → react when the field gains/loses focus
  //     - hasFocus         → check if this field is currently active
  //
  // RULE: Every FocusNode must be disposed — it registers with the focus system
  // and will leak if not cleaned up.
  // ---------------------------------------------------------------------------
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // ViewModel instance (In production, inject via Riverpod/GetIt/Provider)
  final _viewModel = LoginViewModel();

  // ---------------------------------------------------------------------------
  // 🗑️ DISPOSAL — Critical Memory Management
  //
  // Four categories of things that MUST be disposed:
  //   1. TextEditingControllers — hold TextEditingValue listeners
  //   2. FocusNodes            — registered with the focus tree
  //   3. ViewModel             — cancels debounce timers, disposes ValueNotifiers
  //   (ValueNotifiers inside ViewModel are disposed there — not here)
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 📤 Submit — Orchestrates validation → async auth
  // ---------------------------------------------------------------------------
  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard for better UX

    // Block submission if async email check found an error
    if (_viewModel.emailAvailabilityError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the email error before submitting'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 💡 VALIDATION FLOW: Calls every field's validator simultaneously.
    // Returns true only if ALL validators return null.
    if (_formKey.currentState?.validate() ?? false) {
      final success = await _viewModel.authenticateUser(
        _emailController.text,
        _passwordController.text,
      );

      // ⚠️ Always check mounted after an await — the widget may have been
      // disposed while the async operation was in progress.
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful! Welcome.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage ?? 'Unknown error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 🏗️ BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Form Setup'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              // 💡 UX BEST PRACTICE: Validate on user interaction, not on submit.
              // This avoids yelling at the user before they finish typing.
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // ----------------------------------------------------------------
                  // 📧 EMAIL FIELD
                  //
                  // NEW: FocusNode for precise focus control
                  // NEW: onChanged → debounced async email availability check
                  // NEW: ListenableBuilder → shows async error below the field
                  // NEW: Semantics → screen reader label
                  // ----------------------------------------------------------------
                  Semantics(
                    label: 'Email address input field',
                    child: TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus, // 💡 NEW: Named FocusNode
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: AppValidators.validateEmail,
                      // 💡 NEW: Debounced async email validation
                      // Every keystroke calls onEmailChanged in the ViewModel.
                      // The ViewModel debounces for 500ms, then fires the API check.
                      onChanged: _viewModel.onEmailChanged,
                      // 💡 NEW: FocusNode-based focus transfer (precise, not blind)
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                    ),
                  ),
                  // 💡 NEW: Async error display for email availability
                  // This is SEPARATE from the synchronous Form validator above.
                  // It listens to the ViewModel and rebuilds ONLY this small widget.
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      final error = _viewModel.emailAvailabilityError;
                      if (error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ----------------------------------------------------------------
                  // 🔑 PASSWORD FIELD
                  //
                  // NEW: FocusNode (manual navigation)
                  // NEW: ValueListenableBuilder → isolates visibility toggle rebuilds
                  //      Only THIS widget rebuilds when obscureText changes.
                  //      The email field, confirm-password, and submit button are
                  //      completely unaffected — contrast with old setState approach.
                  // NEW: Semantics wrapper
                  // ----------------------------------------------------------------
                  Semantics(
                    label: 'Password input field',
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _viewModel.passwordObscured,
                      builder: (_, obscure, child) {
                        return TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus, // 💡 NEW: Named FocusNode
                          obscureText: obscure,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure ? Icons.visibility_off : Icons.visibility,
                              ),
                              // 💡 NEW: ViewModel toggles the ValueNotifier
                              // NO setState() — only this builder widget rebuilds
                              onPressed: _viewModel.togglePasswordVisibility,
                            ),
                          ),
                          validator: AppValidators.validatePassword,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_confirmPasswordFocus);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ----------------------------------------------------------------
                  // 🔑 CONFIRM PASSWORD FIELD
                  //
                  // NEW: FocusNode
                  // NEW: ValueListenableBuilder for isolated visibility toggle
                  // NEW: InputFormatters — deny spaces (production pattern)
                  //      Password fields should never allow leading/trailing spaces
                  //      to prevent hard-to-debug "wrong password" user errors.
                  // ----------------------------------------------------------------
                  Semantics(
                    label: 'Confirm password input field',
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _viewModel.confirmPasswordObscured,
                      builder: (_, obscure, child) {
                        return TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus, // 💡 NEW: Named FocusNode
                          obscureText: obscure,
                          textInputAction: TextInputAction.done,
                          // 💡 NEW: InputFormatters in action
                          // Spaces are blocked at the character-entry level.
                          // The user cannot type a space — the formatter silently
                          // discards it before it reaches the field value.
                          inputFormatters: [AppFormatters.noSpaces],
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed:
                                  _viewModel.toggleConfirmPasswordVisibility,
                            ),
                          ),
                          validator: (value) =>
                              AppValidators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          onFieldSubmitted: (_) => _submitForm(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ----------------------------------------------------------------
                  // ✅ SUBMIT BUTTON
                  //
                  // ListenableBuilder watches the ViewModel for isLoading changes.
                  // Semantics provides a screen-reader-friendly label.
                  // ----------------------------------------------------------------
                  Semantics(
                    label: 'Sign up button',
                    button: true,
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, child) {
                        final isLoading = _viewModel.isLoading;
                        return ElevatedButton(
                          // 💡 UX: Disable button while loading to prevent double-submit
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        );
                      },
                    ),
                  ),

                  // ----------------------------------------------------------------
                  // 💡 DEMO SECTION: InputFormatters Showcase
                  // ----------------------------------------------------------------
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'InputFormatters Demo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // DIGITS ONLY — e.g. OTP, phone
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [AppFormatters.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'OTP / PIN (digits only)',
                      hintText: 'Try typing letters — they are blocked',
                      prefixIcon: Icon(Icons.pin_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // UPPERCASE — e.g. coupon codes
                  TextFormField(
                    inputFormatters: [AppFormatters.upperCase],
                    decoration: const InputDecoration(
                      labelText: 'Coupon Code (auto uppercase)',
                      hintText: 'Type anything — it becomes uppercase',
                      prefixIcon: Icon(Icons.discount_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
