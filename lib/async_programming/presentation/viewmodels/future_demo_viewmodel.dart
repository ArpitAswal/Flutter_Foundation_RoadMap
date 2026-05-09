import 'package:flutter/foundation.dart';
import '../../core/models/user_post.dart';
import '../../core/services/mock_api_service.dart';

// =============================================================================
// 🧠 FutureDemoViewModel — Business Logic for FutureBuilder Screen
// =============================================================================
//
// WHAT THIS VIEWMODEL DOES:
//   - Owns the Future<UserPost> reference
//   - Handles error simulation toggling
//   - Provides a retry() method that replaces the future
//
// CRITICAL PATTERN — WHY FUTURE IS NOT IN BUILD():
//   ❌ WRONG (rebuilds trigger new API calls):
//     FutureBuilder(future: mockApi.fetchUserPost(), ...)
//
//   ✅ CORRECT (future is stable across rebuilds):
//     // In ViewModel:
//     late final Future<UserPost> _userPostFuture;
//     // Initialize once in constructor or initState
//     // Pass this stable reference to FutureBuilder
//
//   When Flutter rebuilds a widget (e.g., due to theme change, parent rebuild),
//   the build() method runs again. If you call an API inside build(), you get
//   a brand-new Future each time → infinite reload loop → wasted API calls.
//   The fix: create the Future ONCE outside build() and reuse the same instance.
//
// RETRY PATTERN:
//   Retry works by assigning a NEW future to `_userPostFuture` and calling
//   notifyListeners(). The FutureBuilder receives a fresh Future and starts
//   from the waiting state again — clean, no hacks needed.
// =============================================================================

/// ViewModel for the FutureBuilder demonstration screen.
///
/// Manages the lifecycle of a [Future<UserPost>] and exposes controls for
/// error simulation and retry, following the MVVM architecture.
class FutureDemoViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // 📦 Dependencies
  // ---------------------------------------------------------------------------

  /// The service that simulates the real API boundary.
  /// In production, this would be injected via get_it or a constructor parameter.
  final MockApiService _apiService;

  // ---------------------------------------------------------------------------
  // 🔄 State
  // ---------------------------------------------------------------------------

  /// The primary Future that drives the FutureBuilder in the View.
  ///
  /// WHY `late`?
  ///   We initialize this in the constructor body. `late` tells Dart the field
  ///   will be assigned before it's first read, avoiding the nullable `?` type.
  ///   This keeps the type as `Future<UserPost>` (not `Future<UserPost>?`),
  ///   making consumption in the View simpler.
  late Future<UserPost> userPostFuture;

  /// Whether the next API call should simulate a server error.
  ///
  /// The View exposes a toggle to flip this, demonstrating error handling.
  bool _simulateError = false;
  bool get simulateError => _simulateError;

  // ---------------------------------------------------------------------------
  // 🔨 Constructor
  // ---------------------------------------------------------------------------

  FutureDemoViewModel({MockApiService? apiService})
      : _apiService = apiService ?? MockApiService() {
    // Initialize the future immediately so the screen starts loading on mount.
    // This is the equivalent of calling an API in initState() of a StatefulWidget.
    _loadUserPost();
  }

  // ---------------------------------------------------------------------------
  // ⚙️ Private Methods
  // ---------------------------------------------------------------------------

  /// Creates a fresh [Future<UserPost>] from the service and stores it.
  ///
  /// By assigning a new Future reference, FutureBuilder will detect the change
  /// on the next rebuild (triggered by notifyListeners) and restart.
  void _loadUserPost() {
    // Sync the error flag with the service before every call
    _apiService.shouldSimulateError = _simulateError;
    // Assign the new future — the View's FutureBuilder will pick this up
    userPostFuture = _apiService.fetchUserPost();
  }

  // ---------------------------------------------------------------------------
  // 🎮 Public Actions (called by the View)
  // ---------------------------------------------------------------------------

  /// Retries the API call by creating a new Future and notifying the UI.
  ///
  /// Called when the user taps the Retry button after an error.
  /// This is the correct pattern: replace the future, let FutureBuilder react.
  void retry() {
    _loadUserPost();
    notifyListeners(); // Tells FutureBuilder's parent to rebuild with new future
  }

  /// Toggles error simulation and immediately retries the call.
  ///
  /// Allows the learner to toggle between success and error states to
  /// verify that the UI handles both correctly.
  void toggleErrorSimulation() {
    _simulateError = !_simulateError;
    retry(); // Apply the new flag by re-fetching
  }
}
