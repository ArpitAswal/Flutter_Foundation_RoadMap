import 'package:graphql_flutter/graphql_flutter.dart';

// =============================================================================
// 🕸️ GraphQLClient Setup
// =============================================================================
//
// WHY GRAPHQL?
//   Instead of hitting multiple endpoints (GET /users, GET /posts),
//   GraphQL hits ONE endpoint and you ask ONLY for the exact fields you need.
//   This prevents "Overfetching" and "Underfetching".
// =============================================================================

class AppGraphQLClient {
  static GraphQLClient createClient() {
    // HttpLink defines the single endpoint for GraphQL queries/mutations
    final httpLink = HttpLink(
      'https://countries.trevorblades.com/',
    );

    // The client manages caching and the link execution
    return GraphQLClient(
      cache: GraphQLCache(), // Advanced apps use HiveStore() here for persistence
      link: httpLink,
    );
  }
}
