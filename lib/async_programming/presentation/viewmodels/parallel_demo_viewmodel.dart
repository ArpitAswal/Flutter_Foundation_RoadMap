import 'package:flutter/foundation.dart';
import '../../core/models/user_post.dart';
import '../../core/services/mock_api_service.dart';

// =============================================================================
// 🧠 ParallelDemoViewModel — Business Logic for Parallel vs Sequential Demo
// =============================================================================
//
// WHAT THIS VIEWMODEL DOES:
//   - Runs sequential async operations and measures total elapsed time
//   - Runs parallel async operations (Future.wait) and measures elapsed time
//   - Exposes results for both modes to the UI
//
// THE PERFORMANCE DIFFERENCE EXPLAINED:
//
//   Sequential:
//     await fetchUser();  → starts, waits 1.5s, finishes
//     await fetchPosts(); → starts, waits 2.0s, finishes
//     Total: ~3.5 seconds
//     (Each operation must wait for the previous one to complete)
//
//   Parallel:
//     Future.wait([fetchUser(), fetchPosts()]) → BOTH start simultaneously
//     fetchUser  finishes at 1.5s ──┐
//     fetchPosts finishes at 2.0s ──┘ → both complete together
//     Total: ~2.0 seconds (the longest one)
//
//   WHY PARALLEL IS FASTER:
//     I/O operations in Dart don't block the thread. They register a callback
//     and let the event loop continue. Starting both futures immediately means
//     their network requests run in parallel at the OS/network level.
//     Future.wait simply waits until ALL registered futures have completed.
//
// WHEN TO USE PARALLEL vs SEQUENTIAL:
//   Parallel  → when operations are independent (user profile + post list)
//   Sequential → when operation B needs the result of operation A
//                (e.g., fetchUser then fetchUserPosts(userId: user.id))
// =============================================================================

/// Encapsulates the result of one execution run (sequential or parallel).
class FetchResult {
  /// Combined user + posts data.
  final UserWithPosts data;

  /// Total wall-clock time for this run.
  final Duration elapsed;

  const FetchResult({required this.data, required this.elapsed});
}

/// ViewModel for the parallel vs sequential demonstration screen.
class ParallelDemoViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // 📦 Dependencies
  // ---------------------------------------------------------------------------

  final MockApiService _apiService;

  // ---------------------------------------------------------------------------
  // 🔄 State
  // ---------------------------------------------------------------------------

  /// Result from the last sequential run. Null before first run.
  FetchResult? sequentialResult;

  /// Result from the last parallel run. Null before first run.
  FetchResult? parallelResult;

  /// True while a sequential fetch is in progress.
  bool isSequentialRunning = false;

  /// True while a parallel fetch is in progress.
  bool isParallelRunning = false;

  /// Last error encountered in either run, for UI display.
  String? errorMessage;

  // ---------------------------------------------------------------------------
  // 🔨 Constructor
  // ---------------------------------------------------------------------------

  ParallelDemoViewModel({MockApiService? apiService})
      : _apiService = apiService ?? MockApiService();

  // ---------------------------------------------------------------------------
  // 🎮 Public Actions (called by the View)
  // ---------------------------------------------------------------------------

  /// Fetches user and posts one after the other (sequential).
  ///
  /// await fetchUser()  → waits for completion
  /// await fetchPosts() → only starts AFTER fetchUser is done
  ///
  /// Total time ≈ latency(fetchUser) + latency(fetchPosts) = ~3.5 seconds
  Future<void> runSequential() async {
    isSequentialRunning = true;
    sequentialResult = null;
    errorMessage = null;
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    try {
      // 🔴 SEQUENTIAL: Each await suspends this function until the future resolves.
      // fetchPosts does NOT start until fetchUser has FULLY COMPLETED.
      debugPrint('[ParallelDemo] Sequential — fetchUser starting...');
      final user = await _apiService.fetchUser();

      debugPrint('[ParallelDemo] Sequential — fetchPosts starting...');
      final posts = await _apiService.fetchPosts();

      stopwatch.stop();
      debugPrint('[ParallelDemo] Sequential — done in ${stopwatch.elapsed}');

      sequentialResult = FetchResult(
        data: UserWithPosts(user: user, posts: posts),
        elapsed: stopwatch.elapsed,
      );
    } catch (e, stackTrace) {
      // Always handle async errors. Unhandled Future errors crash apps silently.
      debugPrint('[ParallelDemo] Sequential error: $e\n$stackTrace');
      errorMessage = 'Sequential fetch failed: $e';
    } finally {
      // finally blocks run regardless of success or failure — perfect for cleanup
      isSequentialRunning = false;
      notifyListeners();
    }
  }

  /// Fetches user and posts simultaneously (parallel).
  ///
  /// Future.wait() starts ALL futures immediately and waits for ALL to finish.
  ///
  /// Total time ≈ max(latency(fetchUser), latency(fetchPosts)) = ~2.0 seconds
  Future<void> runParallel() async {
    isParallelRunning = true;
    parallelResult = null;
    errorMessage = null;
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    try {
      // 🟢 PARALLEL: Both futures are created (and thus started) immediately.
      // They run concurrently at the I/O level. Future.wait suspends until
      // the LAST one completes. The result list preserves insertion order.
      debugPrint('[ParallelDemo] Parallel — both fetches starting simultaneously...');

      final results = await Future.wait([
        _apiService.fetchUser(),   // starts at t=0
        _apiService.fetchPosts(),  // also starts at t=0
      ]);

      stopwatch.stop();
      debugPrint('[ParallelDemo] Parallel — done in ${stopwatch.elapsed}');

      // results[0] corresponds to fetchUser(), results[1] to fetchPosts()
      // We need to cast because Future.wait returns List<Object?> for mixed types.
      final user = results[0] as AppUser;
      final posts = results[1] as List<PostSummary>;

      parallelResult = FetchResult(
        data: UserWithPosts(user: user, posts: posts),
        elapsed: stopwatch.elapsed,
      );
    } catch (e, stackTrace) {
      // IMPORTANT: If ANY future in Future.wait fails, the entire wait fails.
      // Use Future.wait with eagerError:false or individual try/catches if
      // you want partial results on failure.
      debugPrint('[ParallelDemo] Parallel error: $e\n$stackTrace');
      errorMessage = 'Parallel fetch failed: $e';
    } finally {
      isParallelRunning = false;
      notifyListeners();
    }
  }

  /// Calculates how much faster the parallel run was vs sequential.
  ///
  /// Returns null if both results aren't available yet.
  String? get timeSavingsSummary {
    if (sequentialResult == null || parallelResult == null) return null;
    final saved = sequentialResult!.elapsed - parallelResult!.elapsed;
    final percent = ((saved.inMilliseconds / sequentialResult!.elapsed.inMilliseconds) * 100).round();
    return '${saved.inMilliseconds}ms faster ($percent% improvement)';
  }
}
