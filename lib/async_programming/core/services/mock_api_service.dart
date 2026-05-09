import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_post.dart';

// =============================================================================
// 🌐 MockApiService — Repository / Data Source Layer
// =============================================================================
//
// ROLE IN MVVM:
//   This is the "Model" / "Repository" layer. It is responsible for all data
//   retrieval and streaming. ViewModels call this service; they never know
//   WHERE data comes from (mock, REST API, Firestore — it doesn't matter).
//
// WHY A SEPARATE SERVICE?
//   ┌───────────────┐
//   │     UI View   │  ← knows nothing about data fetching
//   ├───────────────┤
//   │   ViewModel   │  ← orchestrates async calls, manages state
//   ├───────────────┤
//   │  MockApiSvc   │  ← THIS FILE — simulates the real API boundary
//   └───────────────┘
//   Swapping MockApiService with a real HttpApiService requires only one line
//   change in the ViewModel — the UI never changes.
//
// ASYNC CONCEPTS DEMONSTRATED:
//   1. Future<T>        — single async value
//   2. Stream<T>        — continuous sequence of async values (async*)
//   3. Future.delayed   — simulates real network latency
//   4. Error simulation — mirrors real 4xx/5xx server responses
// =============================================================================

/// Simulates a backend API + real-time data source.
///
/// Every method in this class adds an artificial delay to replicate
/// what happens when you call a real REST API or read from a database.
class MockApiService {
  /// Controls whether [fetchUserPost] will throw an error.
  /// Toggle this in the ViewModel to demonstrate error handling.
  bool shouldSimulateError;

  MockApiService({this.shouldSimulateError = false});

  // ---------------------------------------------------------------------------
  // 📡 Future-Based Methods (Single async value)
  // ---------------------------------------------------------------------------

  /// Fetches a simulated blog post from the "server".
  ///
  /// Returns a [Future<UserPost>] that completes after 2 seconds.
  ///
  /// WHY FUTURE?
  ///   An HTTP GET request returns a single response. It either succeeds
  ///   (with data) or fails (with an error) — never multiple values.
  ///   [Future<T>] maps exactly to this "one value, eventually" contract.
  ///
  /// LIFECYCLE:
  ///   Uncompleted → (2 seconds) → Completed with value OR Completed with error
  Future<UserPost> fetchUserPost() async {
    // Simulate network round-trip time
    await Future.delayed(const Duration(seconds: 2));

    // Simulate a server error (HTTP 500 / network failure)
    if (shouldSimulateError) {
      throw Exception('Server error: Unable to fetch post. (HTTP 500)');
    }

    // Return mock data — in production this is JSON deserialization
    return const UserPost(
      authorName: 'John Doe',
      title: 'Mastering Async Programming in Dart',
      body:
          'Understanding Dart\'s event loop model is the foundation of writing '
          'responsive Flutter apps. The single-threaded, event-driven runtime '
          'means every async operation must cooperate — it never blocks the UI '
          'thread. This post explores Futures, Streams, microtasks, and the '
          'real cost of unhandled async errors in production apps.',
      createdAt: '2026-05-09',
      likes: 342,
    );
  }

  /// Fetches a user profile from the "server".
  ///
  /// Simulates a separate /users endpoint with 1.5 second latency.
  /// Used in the parallel fetch demonstration.
  Future<AppUser> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    debugPrint('[MockApiService] fetchUser ✅ completed');
    return const AppUser(
      id: 'usr_001',
      name: 'Doe User',
      email: 'doe@flutter.dev',
    );
  }

  /// Fetches a list of post summaries from the "server".
  ///
  /// Simulates a separate /posts endpoint with 2 second latency.
  /// Used in the parallel fetch demonstration.
  Future<List<PostSummary>> fetchPosts() async {
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('[MockApiService] fetchPosts ✅ completed');
    return const [
      PostSummary(id: 'p1', title: 'Dart Isolates Explained', commentCount: 47),
      PostSummary(id: 'p2', title: 'Flutter State Management Deep Dive', commentCount: 91),
      PostSummary(id: 'p3', title: 'Streams vs Futures', commentCount: 33),
    ];
  }

  // ---------------------------------------------------------------------------
  // 📺 Stream-Based Methods (Continuous async values)
  // ---------------------------------------------------------------------------

  /// Produces a stream of integer values from 1 to [maxCount].
  ///
  /// WHY STREAM?
  ///   A live counter emits multiple values over time, not just one.
  ///   [Stream<int>] maps to this "many values, over time" contract.
  ///
  /// ASYNC GENERATOR (async*):
  ///   The `async*` keyword marks this as an asynchronous generator function.
  ///   Instead of returning a single Future, it returns a Stream.
  ///   The `yield` keyword emits one value into that stream.
  ///   Execution pauses at each `await`, giving the event loop time to run
  ///   UI frames, process touches, etc.
  ///
  /// SINGLE SUBSCRIPTION STREAM:
  ///   By default, streams created with async* are single-subscription.
  ///   Only ONE listener can subscribe at a time. This is correct for most
  ///   use cases (one StreamBuilder per stream instance).
  Stream<int> counterStream({int maxCount = 10}) async* {
    for (int i = 1; i <= maxCount; i++) {
      // Pause for 1 second between each emission (simulates sensor data, etc.)
      await Future.delayed(const Duration(seconds: 1));

      // yield pushes the value into the stream for any listener to receive
      yield i;
    }
  }

  /// Creates a broadcast stream from [counterStream].
  ///
  /// BROADCAST vs SINGLE-SUBSCRIPTION:
  ///   Single-subscription: One listener, throws if you try to add a second.
  ///   Broadcast: Multiple listeners, each receives all future events.
  ///
  /// WHEN TO USE BROADCAST:
  ///   When multiple widgets or ViewModels need the same stream data
  ///   (e.g., an event bus, WebSocket shared across screens).
  Stream<int> broadcastCounterStream({int maxCount = 10}) {
    return counterStream(maxCount: maxCount).asBroadcastStream();
  }
}
