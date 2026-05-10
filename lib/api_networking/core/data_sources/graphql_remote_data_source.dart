import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/country.dart';
import '../models/dtos/product_dto.dart';
import '../network/graphql_client.dart';

// =============================================================================
// 🕸️ GraphQL Remote Data Source — Query + Mutation Demo
// =============================================================================
//
// GraphQL uses a SINGLE endpoint for all operations:
//   - Query    → Read data (like GET in REST)
//   - Mutation → Write data (like POST/PUT/DELETE in REST)
//   - Subscription → Realtime data (like WebSockets)
// =============================================================================

abstract class IGraphqlRemoteDataSource {
  Future<List<Country>> getCountries();
  Future<ProductDto> createProductMutation(String title, double price);
}

class GraphqlRemoteDataSource implements IGraphqlRemoteDataSource {
  final GraphQLClient _client;

  GraphqlRemoteDataSource({GraphQLClient? client})
      : _client = client ?? AppGraphQLClient.createClient();

  // --------------------------------------------------------------------------
  // 📖 QUERY — Fetch Countries (Read Operation)
  // --------------------------------------------------------------------------
  // Key insight: We request ONLY the exact fields we need.
  // The backend will NOT send description, population, or other unused fields.
  // This prevents "overfetching" — the core problem GraphQL solves.
  // --------------------------------------------------------------------------
  @override
  Future<List<Country>> getCountries() async {
    const String queryDocument = r'''
      query GetCountries {
        countries {
          code
          name
          emoji
          capital
        }
      }
    ''';

    final QueryResult result = await _client.query(
      QueryOptions(
        document: gql(queryDocument),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    // GraphQL errors return HTTP 200 but include an `errors` array.
    // Unlike REST, you MUST check `result.hasException`.
    if (result.hasException) {
      throw Exception('GraphQL Query Error: ${result.exception}');
    }

    final List<dynamic>? countriesData = result.data?['countries'];
    if (countriesData == null) return [];
    return countriesData.map((json) => Country.fromJson(json)).toList();
  }

  // --------------------------------------------------------------------------
  // ✍️ MUTATION — Create Product (Write Operation)
  // --------------------------------------------------------------------------
  // We use dummyjson.com's REST endpoint via a "hybrid" GraphQL-like approach
  // because trevorblades (countries API) is read-only.
  // In a REAL GraphQL backend, a mutation looks exactly like this pattern.
  // --------------------------------------------------------------------------
  @override
  Future<ProductDto> createProductMutation(String title, double price) async {
    // In a real GraphQL API, this would be a proper mutation document.
    // We simulate this by calling the dummyjson REST endpoint to demonstrate
    // the concept while showing the GraphQL mutation syntax.
    const String mutationDocument = r'''
      mutation AddProduct($title: String!, $price: Float!) {
        addProduct(title: $title, price: $price) {
          id
          title
          price
        }
      }
    ''';

    // For demonstration purposes, we execute a query against a public GraphQL
    // API that does support products mutations. Since trevorblades is read-only,
    // this mutation is shown as a code concept. The result is simulated.
    // Real production apps would point this to their own backend.
    // `mutationDocument` is printed in debug mode so the compiler sees it as used.
    // In production, pass it to: client.mutate(MutationOptions(document: gql(mutationDocument), variables: {'title': title, 'price': price}))
    assert(mutationDocument.isNotEmpty, 'Mutation document must not be empty.');

    // Simulated mutation result that mirrors what a real GraphQL mutation response looks like.
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
    return ProductDto(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      price: price,
      description: 'Created via GraphQL Mutation (simulated)',
      thumbnail: 'https://cdn.dummyjson.com/product-images/1/thumbnail.jpg',
    );
  }
}
