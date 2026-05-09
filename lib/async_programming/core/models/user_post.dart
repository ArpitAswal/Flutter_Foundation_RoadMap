// =============================================================================
// 📦 UserPost — Data Model
// =============================================================================
//
// This is a pure Dart data class. No Flutter, no UI dependencies.
// Following the MVVM architecture: Models live in the "core" layer and are
// completely agnostic of how they are displayed.
//
// WHY SEPARATE MODEL FILES?
//   In production apps, each entity (User, Post, Comment) has its own file.
//   This follows the Single Responsibility Principle (SRP) — one class, one job.
// =============================================================================

/// Represents a combined API response containing user info and a blog post.
///
/// In production this would be deserialized from JSON using fromJson/toJson,
/// but for this learning module we construct it directly in the service layer.
class UserPost {
  /// The display name of the user who created the post.
  final String authorName;

  /// The main title of the blog post.
  final String title;

  /// The body content of the blog post.
  final String body;

  /// ISO 8601 timestamp string representing when the post was created.
  final String createdAt;

  /// Number of likes on the post, simulating engagement data.
  final int likes;

  const UserPost({
    required this.authorName,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.likes,
  });

  /// Creates a [UserPost] instance from a raw JSON map.
  ///
  /// The `as` keyword performs an explicit cast — Dart's type system will throw
  /// a [TypeError] at runtime if the actual type does not match, which is safer
  /// than a silent null and helps catch API contract violations early.
  factory UserPost.fromJson(Map<String, dynamic> json) {
    return UserPost(
      authorName: json['authorName'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: json['createdAt'] as String,
      likes: json['likes'] as int,
    );
  }

  /// Converts this instance to a JSON-compatible map.
  /// Used for caching, logging, or sending data to a backend.
  Map<String, dynamic> toJson() {
    return {
      'authorName': authorName,
      'title': title,
      'body': body,
      'createdAt': createdAt,
      'likes': likes,
    };
  }

  @override
  String toString() {
    return 'UserPost(author: $authorName, title: $title)';
  }
}

/// Represents an individual user profile, used in the parallel fetch demo.
class AppUser {
  final String id;
  final String name;
  final String email;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
  });
}

/// Represents a minimal blog post summary, used in the parallel fetch demo.
class PostSummary {
  final String id;
  final String title;
  final int commentCount;

  const PostSummary({
    required this.id,
    required this.title,
    required this.commentCount,
  });
}

/// Combined result of a parallel fetch (User + Posts).
///
/// Bundling both results into a single class avoids a Tuple/pair hack and
/// makes the data contract explicit and self-documenting.
class UserWithPosts {
  final AppUser user;
  final List<PostSummary> posts;

  const UserWithPosts({required this.user, required this.posts});
}
