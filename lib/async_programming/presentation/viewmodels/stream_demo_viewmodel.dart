import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/services/mock_api_service.dart';

// =============================================================================
// 🧠 StreamDemoViewModel — Business Logic for Stream Counter Screen
// =============================================================================
//
// WHAT THIS VIEWMODEL DOES:
//   - Manages the lifecycle of a Stream<int>
//   - Owns the StreamSubscription for memory-safe cancellation
//   - Exposes start/stop controls to the View
//   - Ensures the subscription is cancelled in dispose() to prevent memory leaks
//
// MEMORY LEAK DANGER — WHY WE CANCEL StreamSubscription:
//   When a widget is removed from the tree, its ViewModel is disposed.
//   If a stream is still emitting values and a listener is active, the
//   callback will fire on a disposed object → state-after-dispose errors,
//   silent crashes, or worse: callbacks that reference deallocated memory.
//
//   ❌ LEAK:
//     stream.listen((value) { /* do something */ });
//     // No cancel → subscription lives forever, holds reference to ViewModel
//
//   ✅ SAFE:
//     _subscription = stream.listen(...)
//     @override void dispose() { _subscription?.cancel(); super.dispose(); }
//
// BROADCAST STREAM EXPLAINED:
//   The raw counterStream() from the service is a single-subscription stream.
//   We convert it to broadcast here so both the StreamBuilder in the View AND
//   any secondary listener can subscribe without an error.
// =============================================================================

/// ViewModel for the live counter stream demonstration.
///
/// Controls a [Stream<int>] counter, manages the [StreamSubscription] for
/// proper resource cleanup, and exposes the stream for the View's StreamBuilder.
class StreamDemoViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // 📦 Dependencies
  // ---------------------------------------------------------------------------

  final MockApiService _apiService;

  // ---------------------------------------------------------------------------
  // 🔄 State
  // ---------------------------------------------------------------------------

  /// Whether the counter stream is currently running.
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  /// The latest value emitted by the stream.
  /// Exposed for display purposes in addition to the StreamBuilder.
  int _currentCount = 0;
  int get currentCount => _currentCount;

  /// Maximum count the counter will reach before stopping automatically.
  final int maxCount;

  /// The active broadcast stream exposed to the View's StreamBuilder.
  ///
  /// WHY BROADCAST?
  ///   StreamBuilder is one listener. But if we also maintain a subscription
  ///   here in the ViewModel (to track _currentCount), that's two listeners.
  ///   Single-subscription streams throw [StateError] on a second listener.
  ///   Converting to broadcast allows both to coexist safely.
  Stream<int>? _activeStream;
  Stream<int>? get activeStream => _activeStream;

  /// The subscription handle for the ViewModel's own listener.
  ///
  /// CRITICAL: This is what we cancel in dispose() to prevent the leak.
  StreamSubscription<int>? _subscription;

  // ---------------------------------------------------------------------------
  // 🔨 Constructor
  // ---------------------------------------------------------------------------

  StreamDemoViewModel({
    MockApiService? apiService,
    this.maxCount = 10,
  }) : _apiService = apiService ?? MockApiService();

  // ---------------------------------------------------------------------------
  // 🎮 Public Actions (called by the View)
  // ---------------------------------------------------------------------------

  /// Starts the counter stream from the beginning.
  ///
  /// Creates a fresh broadcast stream and subscribes to it to track
  /// the current count value in the ViewModel's own state.
  void startCounter() {
    if (_isRunning) return; // Idempotent — don't start if already running

    _isRunning = true;
    _currentCount = 0;

    // Get a single-subscription stream from the service and convert to broadcast.
    // asBroadcastStream() wraps it in a controller that fans out to N listeners.
    _activeStream = _apiService
        .counterStream(maxCount: maxCount)
        .asBroadcastStream();

    // The ViewModel subscribes to track state internally.
    // The StreamBuilder in the View also subscribes — two listeners, thus broadcast.
    _subscription = _activeStream!.listen(
      (value) {
        // Update internal state so UI can also reflect count via notifyListeners
        _currentCount = value;
        notifyListeners();
      },
      onDone: () {
        // Stream completed naturally (reached maxCount)
        _isRunning = false;
        notifyListeners();
      },
      onError: (Object error) {
        // Stream errored — in production you'd log this and show a snackbar
        debugPrint('[StreamDemoViewModel] Stream error: $error');
        _isRunning = false;
        notifyListeners();
      },
    );

    notifyListeners(); // Notify immediately so UI updates to "running" state
  }

  /// Stops the counter stream mid-emission.
  ///
  /// Cancels the subscription, which stops the listener from receiving values.
  /// The stream source may still emit internally, but nobody is listening.
  /// For production streams (WebSocket, GPS), always cancel when not needed.
  void stopCounter() {
    _cancelSubscription();
    _activeStream = null;
    _isRunning = false;
    notifyListeners();
  }

  /// Resets the counter back to zero and stops any running stream.
  void reset() {
    stopCounter();
    _currentCount = 0;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🗑️ Disposal — THE MOST IMPORTANT PART
  // ---------------------------------------------------------------------------

  void _cancelSubscription() {
    // cancel() is a Future but we don't need to await it here.
    // Dart's subscription cancel is synchronous in most stream implementations.
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    // 🔑 CRITICAL: Always cancel subscriptions before calling super.dispose()
    // Failing to do this is the #1 cause of stream memory leaks in Flutter.
    _cancelSubscription();
    super.dispose();
  }
}
