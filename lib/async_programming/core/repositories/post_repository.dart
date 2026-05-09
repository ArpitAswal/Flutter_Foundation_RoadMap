import 'dart:async';
import '../data_sources/remote_data_source.dart';
import '../models/user_post.dart';

// =============================================================================
// 🏛️ PostRepository — Repository Layer
// =============================================================================
//
// ROLE IN PRODUCTION ARCHITECTURE:
//   The "Brain" of the data layer. It orchestrates multiple data sources 
//   (Remote vs Local Cache). It transforms raw data into domain models.
//
// WHY THIS MATTERS:
//   ViewModels only talk to Repositories. This hides the complexity of 
//   data fetching from the UI logic.
// =============================================================================

abstract class IPostRepository {
  Future<UserPost> getUserPost({bool simulateError = false});
  Future<UserWithPosts> getUserAndPosts();
  Future<AppUser> fetchUser();
  Future<List<PostSummary>> fetchPosts();
  Stream<int> getCounterStream({int maxCount = 10});
}

class PostRepository implements IPostRepository {
  final IPostRemoteDataSource _remoteDataSource;

  PostRepository({IPostRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? PostRemoteDataSource();

  @override
  Future<UserPost> getUserPost({bool simulateError = false}) {
    return _remoteDataSource.fetchUserPost(simulateError: simulateError);
  }

  @override
  Future<AppUser> fetchUser() => _remoteDataSource.fetchUser();

  @override
  Future<List<PostSummary>> fetchPosts() => _remoteDataSource.fetchPosts();

  @override
  Future<UserWithPosts> getUserAndPosts() async {
    // Using Modern Dart 3.0+ Records for parallel execution wait
    // This replaces manual List<Object?> casting
    final (user, posts) = await (
      _remoteDataSource.fetchUser(),
      _remoteDataSource.fetchPosts(),
    ).wait;

    return UserWithPosts(user: user, posts: posts);
  }

  @override
  Stream<int> getCounterStream({int maxCount = 10}) {
    return _remoteDataSource.getCounterStream(maxCount: maxCount);
  }
}
