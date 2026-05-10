import 'package:dio/dio.dart';
import '../data_sources/graphql_remote_data_source.dart';
import '../data_sources/product_remote_data_source.dart';
import '../models/country.dart';
import '../models/domain/product.dart';
import '../models/dtos/product_dto.dart';

// =============================================================================
// 🏛️ Networking Repository — CRUD + DTO Mapping Layer
// =============================================================================
//
// ROLE: The Repository is the ONLY class that knows about both DTOs and
// Domain Models. It maps between them so no ViewModel ever sees a DTO.
//
// RETRY LOGIC lives here (not in the data source or ViewModel).
//
// INTERFACE SEGREGATION: The interface defines the contract. The concrete
// class is the only one that knows about data sources.
// =============================================================================

abstract class INetworkingRepository {
  // --- HTTP CRUD ---
  Future<List<Product>> getProductsHttp();
  Future<Product> getProductByIdHttp(int id);
  Future<Product> createProductHttp(String title, double price);
  Future<Product> updateProductHttp(int id, String title);
  Future<bool> deleteProductHttp(int id);

  // --- Dio CRUD (with retry + cancellation) ---
  Future<List<Product>> getProductsDio({CancelToken? cancelToken});
  Future<Product> getProductByIdDio(int id, {CancelToken? cancelToken});
  Future<Product> createProductDio(String title, double price);
  Future<Product> updateProductDio(int id, String title);
  Future<bool> deleteProductDio(int id);

  // --- GraphQL ---
  Future<List<Country>> getCountriesGraphQL();
  Future<Product> createProductGraphQL(String title, double price);
}

class NetworkingRepository implements INetworkingRepository {
  final IProductRemoteDataSource _productDataSource;
  final IGraphqlRemoteDataSource _graphqlDataSource;

  // DEPENDENCY INJECTION: Accept interfaces, not concrete classes.
  // This makes the repository fully testable via mocks.
  NetworkingRepository({
    IProductRemoteDataSource? productDataSource,
    IGraphqlRemoteDataSource? graphqlDataSource,
  })  : _productDataSource = productDataSource ?? ProductRemoteDataSource(),
        _graphqlDataSource = graphqlDataSource ?? GraphqlRemoteDataSource();

  // ===========================================================================
  // 🔄 THE MAPPER — DTO → DOMAIN MODEL
  // ===========================================================================
  // This is the most important function in this file.
  // The ViewModel asks for `Product`. It gets `Product`.
  // It has NO idea that `ProductDto` even exists.
  //
  // If the backend renames `title` to `product_name` tomorrow,
  // ONLY THIS LINE changes. Zero UI changes required.
  // ===========================================================================
  Product _map(ProductDto dto) {
    return Product(
      id: dto.id ?? 0,
      name: dto.title ?? 'Unknown Product',
      description: dto.description ?? 'No description available.',
      price: (dto.price ?? 0.0).toDouble(),
      imageUrl: dto.thumbnail ?? '',
    );
  }

  // ---------------------------------------------------------------------------
  // HTTP CRUD
  // ---------------------------------------------------------------------------

  @override
  Future<List<Product>> getProductsHttp() async {
    final dto = await _productDataSource.getProductsHttp();
    return dto.map(_map).toList();
  }

  @override
  Future<Product> getProductByIdHttp(int id) async {
    final dto = await _productDataSource.getProductByIdHttp(id);
    return _map(dto);
  }

  @override
  Future<Product> createProductHttp(String title, double price) async {
    final dto = await _productDataSource.createProductHttp(title, price);
    return _map(dto);
  }

  @override
  Future<Product> updateProductHttp(int id, String title) async {
    final dto = await _productDataSource.updateProductHttp(id, title);
    return _map(dto);
  }

  @override
  Future<bool> deleteProductHttp(int id) {
    return _productDataSource.deleteProductHttp(id);
  }

  // ---------------------------------------------------------------------------
  // DIO CRUD (with exponential backoff retry on GET)
  // ---------------------------------------------------------------------------

  @override
  Future<List<Product>> getProductsDio({CancelToken? cancelToken}) async {
    return _withRetry(() async {
      final dto = await _productDataSource.getProductsDio(cancelToken: cancelToken);
      return dto.map(_map).toList();
    });
  }

  @override
  Future<Product> getProductByIdDio(int id, {CancelToken? cancelToken}) async {
    final dto = await _productDataSource.getProductByIdDio(id, cancelToken: cancelToken);
    return _map(dto);
  }

  @override
  Future<Product> createProductDio(String title, double price) async {
    final dto = await _productDataSource.createProductDio(title, price);
    return _map(dto);
  }

  @override
  Future<Product> updateProductDio(int id, String title) async {
    final dto = await _productDataSource.updateProductDio(id, title);
    return _map(dto);
  }

  @override
  Future<bool> deleteProductDio(int id) {
    return _productDataSource.deleteProductDio(id);
  }

  // ---------------------------------------------------------------------------
  // GRAPHQL
  // ---------------------------------------------------------------------------

  @override
  Future<List<Country>> getCountriesGraphQL() {
    return _graphqlDataSource.getCountries();
  }

  @override
  Future<Product> createProductGraphQL(String title, double price) async {
    final dto = await _graphqlDataSource.createProductMutation(title, price);
    return _map(dto);
  }

  // ===========================================================================
  // 🔁 RETRY HELPER — Exponential Backoff
  // ===========================================================================
  // WHY RETRY?
  //   Mobile connections are unreliable. A request may fail due to a brief
  //   network blip, not a persistent failure. Retrying with backoff gives
  //   the network time to recover without hammering the server.
  //
  // BACKOFF: Wait 500ms, then 1000ms, then 1500ms between attempts.
  // ===========================================================================
  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        // Exponential backoff: 500ms × attempt number
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    throw Exception('Unreachable: failed after $maxRetries retries.');
  }
}
