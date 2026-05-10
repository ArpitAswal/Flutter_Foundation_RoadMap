import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/dtos/product_dto.dart';
import '../network/app_exceptions.dart';
import '../network/dio_client.dart';

// =============================================================================
// 🌐 Product Remote Data Source — Full CRUD (DTO Layer)
// =============================================================================
//
// ARCHITECTURE RULE: This class is ONLY aware of network protocols (HTTP/Dio).
// It returns raw DTOs (Data Transfer Objects) to the Repository.
// It NEVER returns Domain Models. That is the Repository's job.
//
// METHODS BY TRANSPORT:
//   HTTP  → getProductsHttp, getProductByIdHttp, createProductHttp,
//           updateProductHttp, deleteProductHttp
//   Dio   → getProductsDio, getProductByIdDio, createProductDio,
//           updateProductDio, deleteProductDio
// =============================================================================

abstract class IProductRemoteDataSource {
  // --- HTTP CRUD ---
  Future<List<ProductDto>> getProductsHttp();
  Future<ProductDto> getProductByIdHttp(int id);
  Future<ProductDto> createProductHttp(String title, double price);
  Future<ProductDto> updateProductHttp(int id, String title);
  Future<bool> deleteProductHttp(int id);

  // --- Dio CRUD ---
  Future<List<ProductDto>> getProductsDio({CancelToken? cancelToken});
  Future<ProductDto> getProductByIdDio(int id, {CancelToken? cancelToken});
  Future<ProductDto> createProductDio(String title, double price);
  Future<ProductDto> updateProductDio(int id, String title);
  Future<bool> deleteProductDio(int id);
}

class ProductRemoteDataSource implements IProductRemoteDataSource {
  final AppDioClient _dioClient;
  static const String _baseUrl = 'https://dummyjson.com';

  ProductRemoteDataSource({AppDioClient? dioClient})
      : _dioClient = dioClient ?? AppDioClient();

  // ============================================================
  // 📦 HTTP CRUD OPERATIONS
  // ============================================================
  // WHY HTTP HERE?
  //   To demonstrate the "raw" way of networking — no middleware,
  //   manual JSON decoding, manual URI construction.
  // ============================================================

  @override
  Future<List<ProductDto>> getProductsHttp() async {
    final uri = Uri.parse('$_baseUrl/products?limit=10&select=id,title,price,thumbnail,description');
    try {
      final response = await http.get(uri);
      _checkHttpStatus(response.statusCode);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final productsJson = data['products'] as List<dynamic>;
      return productsJson.map((json) => ProductDto.fromJson(json)).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw const NetworkException();
    }
  }

  @override
  Future<ProductDto> getProductByIdHttp(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    try {
      final response = await http.get(uri);
      _checkHttpStatus(response.statusCode);
      return ProductDto.fromJson(jsonDecode(response.body));
    } catch (e) {
      if (e is AppException) rethrow;
      throw const NetworkException();
    }
  }

  @override
  Future<ProductDto> createProductHttp(String title, double price) async {
    final uri = Uri.parse('$_baseUrl/products/add');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'price': price}),
      );
      _checkHttpStatus(response.statusCode);
      return ProductDto.fromJson(jsonDecode(response.body));
    } catch (e) {
      if (e is AppException) rethrow;
      throw const NetworkException();
    }
  }

  @override
  Future<ProductDto> updateProductHttp(int id, String title) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title}),
      );
      _checkHttpStatus(response.statusCode);
      return ProductDto.fromJson(jsonDecode(response.body));
    } catch (e) {
      if (e is AppException) rethrow;
      throw const NetworkException();
    }
  }

  @override
  Future<bool> deleteProductHttp(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    try {
      final response = await http.delete(uri);
      _checkHttpStatus(response.statusCode);
      // DummyJSON returns the deleted product with `isDeleted: true`
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['isDeleted'] == true;
    } catch (e) {
      if (e is AppException) rethrow;
      throw const NetworkException();
    }
  }

  // ============================================================
  // 🚀 DIO CRUD OPERATIONS
  // ============================================================
  // WHY DIO HERE?
  //   To demonstrate the enterprise way — automatic JSON parsing,
  //   interceptors, CancelTokens, and BaseOptions pre-configured.
  // ============================================================

  @override
  Future<List<ProductDto>> getProductsDio({CancelToken? cancelToken}) async {
    try {
      final response = await _dioClient.instance.get(
        '/products',
        queryParameters: {'limit': 10, 'select': 'id,title,price,thumbnail,description'},
        cancelToken: cancelToken,
      );
      final productsJson = response.data['products'] as List<dynamic>;
      return productsJson.map((json) => ProductDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ProductDto> getProductByIdDio(int id, {CancelToken? cancelToken}) async {
    try {
      final response = await _dioClient.instance.get(
        '/products/$id',
        cancelToken: cancelToken,
      );
      return ProductDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ProductDto> createProductDio(String title, double price) async {
    try {
      // Dio auto-serializes the Map to JSON body. No jsonEncode needed!
      final response = await _dioClient.instance.post(
        '/products/add',
        data: {'title': title, 'price': price},
      );
      return ProductDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ProductDto> updateProductDio(int id, String title) async {
    try {
      final response = await _dioClient.instance.put(
        '/products/$id',
        data: {'title': title},
      );
      return ProductDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<bool> deleteProductDio(int id) async {
    try {
      final response = await _dioClient.instance.delete('/products/$id');
      return response.data['isDeleted'] == true;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // 🛠️ HELPERS
  // ---------------------------------------------------------------------------

  /// Validates HTTP status codes and throws typed AppExceptions.
  /// REST Principle: 2xx = success, 4xx = client error, 5xx = server error.
  void _checkHttpStatus(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return;
    if (statusCode == 401) throw const UnauthorizedException();
    if (statusCode == 404) throw const ServerException(404, 'Resource not found.');
    if (statusCode >= 400 && statusCode < 500) throw ServerException(statusCode, 'Client error.');
    throw ServerException(statusCode, 'Server error. Try again later.');
  }

  /// Maps DioException types into structured AppExceptions.
  AppException _mapDioError(DioException e) {
    if (e.response?.statusCode == 401) return const UnauthorizedException();
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutAppException();
      case DioExceptionType.badResponse:
        return ServerException(e.response?.statusCode);
      case DioExceptionType.cancel:
        return const CancelledByUserException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      default:
        return const UnknownAppException();
    }
  }
}
