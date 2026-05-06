/// Pure utility class containing form validation logic.
/// Separating this from the UI adheres to the Single Responsibility Principle,
/// making these validators highly reusable and easily unit-testable.
class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    // Standard robust email regex
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter a valid email address";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }
    // Regex: At least one letter and one number
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$');
    if (!passwordRegex.hasMatch(value)) {
      return "Password must contain at least one letter and one number";
    }
    return null;
  }

  /// Takes both the confirmation value and the original password value to compare them.
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != originalPassword) {
      return "Passwords do not match";
    }
    return null;
  }
}
