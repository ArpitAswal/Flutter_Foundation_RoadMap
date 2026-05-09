import 'dart:async';
import '../models/user_post.dart';

// =============================================================================
// 🌐 RemoteDataSource — Data Source Layer
// =============================================================================
//
// ROLE IN PRODUCTION ARCHITECTURE:
//   This is the "lowest" level of the data layer. It only knows about
//   raw data retrieval (HTTP, Firebase, local DB). It doesn't handle
//   logic, caching, or data transformation.
//
// WHY SEPARATE FROM REPOSITORY?
//   If you change your backend from REST to GraphQL, you only change the 
//   RemoteDataSource. The Repository remains untouched.
// =============================================================================

abstract class IPostRemoteDataSource {
  Future<UserPost> fetchUserPost({required bool simulateError});
  Future<AppUser> fetchUser();
  Future<List<PostSummary>> fetchPosts();
  Stream<int> getCounterStream({required int maxCount});
}

class PostRemoteDataSource implements IPostRemoteDataSource {
  @override
  Future<UserPost> fetchUserPost({required bool simulateError}) async {
    await Future.delayed(const Duration(seconds: 2));

    if (simulateError) {
      throw Exception('Server error: (HTTP 500)');
    }

    return const UserPost(
      authorName: 'John Doe',
      title: 'Mastering Async Programming in Dart',
      body: 'Understanding Dart\'s event loop model...',
      createdAt: '2026-05-09',
      likes: 342,
    );
  }

  @override
  Future<AppUser> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return const AppUser(
      id: 'usr_001',
      name: 'JohnDoe',
      email: 'doe@flutter.dev',
    );
  }

  @override
  Future<List<PostSummary>> fetchPosts() async {
    await Future.delayed(const Duration(seconds: 2));
    return const [
      PostSummary(id: 'p1', title: 'Dart Isolates Explained', commentCount: 47),
      PostSummary(id: 'p2', title: 'Flutter State Management', commentCount: 91),
    ];
  }

  @override
  Stream<int> getCounterStream({required int maxCount}) async* {
    for (int i = 1; i <= maxCount; i++) {
      await Future.delayed(const Duration(seconds: 1));
      yield i;
    }
  }
}
