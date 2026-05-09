import 'package:flutter/foundation.dart';

// =============================================================================
// ⚡ HeavyComputationService — Isolate & CPU Task Layer
// =============================================================================
//
// WHY ISOLATES EXIST?
//   Dart is single-threaded. Heavy CPU tasks (parsing 20MB JSON, image processing)
//   block the Event Loop, causing the UI to freeze (jank).
//
// WHAT IS AN ISOLATE?
//   A separate "worker" with its own memory heap. It runs in parallel 
//   to the Main Isolate (UI thread).
// =============================================================================

class HeavyComputationService {
  /// Simulates a heavy CPU task: Calculating Nth Prime or parsing huge JSON.
  /// 
  /// This MUST be a top-level or static function to be used with `compute`.
  static int _heavyTask(int iterations) {
    int count = 0;
    for (int i = 0; i < iterations; i++) {
      // Meaningless heavy work
      if (i % 2 == 0) count++;
    }
    return count;
  }

  /// Runs the heavy task on a separate Isolate using Flutter's `compute`.
  /// 
  /// ROLE:
  ///   Offloads work from the UI thread so animations stay smooth.
  Future<int> runHeavyTaskOnIsolate(int iterations) async {
    return await compute(_heavyTask, iterations);
  }

  /// Runs the same task on the MAIN Isolate (UI Thread).
  /// 
  /// WARNING:
  ///   This WILL freeze the UI for the duration of the calculation.
  int runHeavyTaskOnMainThread(int iterations) {
    return _heavyTask(iterations);
  }
}
