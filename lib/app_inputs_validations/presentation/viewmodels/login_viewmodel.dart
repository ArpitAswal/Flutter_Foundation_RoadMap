import 'package:flutter/foundation.dart';

/// ViewModel responsible for handling the business logic of the Login screen.
/// Decoupling state from the UI makes our application production-ready.
class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Simulates an authentication request. 
  /// In a real app, this would call an AuthenticationRepository/Data Source.
  Future<bool> authenticateUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Command the UI to show the loading state

    try {
      // Simulate network latency
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate successful login
      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Authentication failed. Please try again.";
      notifyListeners();
      return false; // Failure
    }
  }
}
