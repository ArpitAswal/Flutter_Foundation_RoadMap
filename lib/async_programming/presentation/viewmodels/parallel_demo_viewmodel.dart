import 'package:flutter/foundation.dart';
import '../../core/models/user_post.dart';
import '../../core/repositories/post_repository.dart';

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

  final IPostRepository _repository;

  // ---------------------------------------------------------------------------
  // 🔄 State
  // ---------------------------------------------------------------------------

  FetchResult? sequentialResult;
  FetchResult? parallelResult;
  bool isSequentialRunning = false;
  bool isParallelRunning = false;
  String? errorMessage;

  // ---------------------------------------------------------------------------
  // 🔨 Constructor
  // ---------------------------------------------------------------------------

  ParallelDemoViewModel({IPostRepository? repository})
      : _repository = repository ?? PostRepository();

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
      // 🔴 SEQUENTIAL: We await each future one by one.
      final user = await _repository.fetchUser();
      final posts = await _repository.fetchPosts();

      stopwatch.stop();

      sequentialResult = FetchResult(
        data: UserWithPosts(user: user, posts: posts),
        elapsed: stopwatch.elapsed,
      );
    } catch (e) {
      errorMessage = 'Sequential fetch failed: $e';
    } finally {
      isSequentialRunning = false;
      notifyListeners();
    }
  }

  Future<void> runParallel() async {
    isParallelRunning = true;
    parallelResult = null;
    errorMessage = null;
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    try {
      // 🟢 PARALLEL: We use the repository method that uses Records .wait
      final resultData = await _repository.getUserAndPosts();

      stopwatch.stop();

      parallelResult = FetchResult(
        data: resultData,
        elapsed: stopwatch.elapsed,
      );
    } catch (e) {
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
