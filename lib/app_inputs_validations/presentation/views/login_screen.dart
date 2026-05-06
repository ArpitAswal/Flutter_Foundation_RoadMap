import 'package:flutter/material.dart';
import '../viewmodels/login_viewmodel.dart';
import '../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 💡 CORE CONCEPT: Form API & GlobalKey
  // The GlobalKey uniquely identifies the Form widget, allowing programmatic validation.
  final _formKey = GlobalKey<FormState>();
  
  // 💡 CORE CONCEPT: Controllers
  // Used to read/write field values. MUST be disposed to prevent memory leaks.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ViewModel instance (In production, inject this via GetIt/Provider/Riverpod)
  final _viewModel = LoginViewModel();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    // ⚠️ CRITICAL: Always dispose controllers when the widget is removed from the tree
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Dismiss keyboard on submit for better UX
    FocusScope.of(context).unfocus();

    // 💡 VALIDATION FLOW: Trigger all validators simultaneously.
    if (_formKey.currentState?.validate() ?? false) {
      final success = await _viewModel.authenticateUser(
        _emailController.text,
        _passwordController.text,
      );

      // Ensure widget is still mounted before interacting with the BuildContext
      if (!mounted) return;

      if (success) {
        // 💡 UX BEST PRACTICE: Snackbar on success
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
              // 💡 UX BEST PRACTICE: Validate on user interaction after first submission attempt
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

                  // --- EMAIL FIELD ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: AppValidators.validateEmail,
                    // 💡 FOCUS MANAGEMENT: Move to password field automatically
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 20),

                  // --- PASSWORD FIELD ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      // 💡 UX BEST PRACTICE: Hide/Show password toggle
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured 
                              ? Icons.visibility_off 
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                      ),
                    ),
                    validator: AppValidators.validatePassword,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 20),

                  // --- CONFIRM PASSWORD FIELD ---
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmPasswordObscured,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordObscured 
                              ? Icons.visibility_off 
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                      ),
                    ),
                    // Validates against the current value of the password controller
                    validator: (value) => AppValidators.validateConfirmPassword(
                      value, 
                      _passwordController.text,
                    ),
                    onFieldSubmitted: (_) => _submitForm(),
                  ),
                  const SizedBox(height: 40),

                  // --- SUBMIT BUTTON ---
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, child) {
                      final isLoading = _viewModel.isLoading;
                      return ElevatedButton(
                        // 💡 UX BEST PRACTICE: Disable button while loading to prevent double-submit
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
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      );
                    },
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
