import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/services/heavy_computation_service.dart';

// =============================================================================
// 🧠 AdvancedAsyncViewModel — Completer, StreamController & Isolates
// =============================================================================
//
// WHAT THIS VIEWMODEL DOES:
//   1. Completer demo: Manual future control
//   2. StreamController demo: Creating streams manually
//   3. Isolate demo: Parallel CPU work via compute()
// =============================================================================

class AdvancedAsyncViewModel extends ChangeNotifier {
  final HeavyComputationService _computationService = HeavyComputationService();

  // ---------------------------------------------------------------------------
  // 🏁 1. Completer Demo
  // ---------------------------------------------------------------------------
  Completer<String>? _completer;
  String completerStatus = "Idle";

  /// Returns a future that is controlled MANUALLY by a Completer.
  Future<String> startCompleterTask() {
    _completer = Completer<String>();
    completerStatus = "Waiting for manual completion...";
    notifyListeners();
    return _completer!.future;
  }

  void completeTaskSuccessfully() {
    _completer?.complete("✅ Task finished manually!");
    completerStatus = "Completed";
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🕹️ 2. StreamController Demo
  // ---------------------------------------------------------------------------
  final StreamController<String> _chatController = StreamController<String>.broadcast();
  Stream<String> get chatStream => _chatController.stream;

  void sendMessage(String msg) {
    _chatController.add("User: $msg");
  }

  // ---------------------------------------------------------------------------
  // ⚡ 3. Isolate Demo
  // ---------------------------------------------------------------------------
  bool isComputing = false;
  String computationResult = "No results yet";

  Future<void> runCpuIntensiveTask({required bool useIsolate}) async {
    isComputing = true;
    computationResult = "Computing...";
    notifyListeners();

    try {
      final stopwatch = Stopwatch()..start();
      int result;

      if (useIsolate) {
        // Offload to worker thread
        result = await _computationService.runHeavyTaskOnIsolate(100000000);
      } else {
        // Run on UI thread (WARNING: UI WILL FREEZE)
        result = _computationService.runHeavyTaskOnMainThread(100000000);
      }

      stopwatch.stop();
      computationResult = "Result: $result (Took ${stopwatch.elapsedMilliseconds}ms)";
    } finally {
      isComputing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _chatController.close(); // Crucial: Always close controllers
    super.dispose();
  }
}
