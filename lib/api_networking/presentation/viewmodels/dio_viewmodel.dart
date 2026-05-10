import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/domain/product.dart';
import '../../core/network/app_exceptions.dart';
import '../../core/repositories/networking_repository.dart';

// =============================================================================
// 🧠 Dio ViewModel — Single Responsibility
// =============================================================================
//
// This ViewModel owns ALL state for the Dio Demo Screen.
// It demonstrates production-grade advanced patterns:
//   - CancelToken: Lifecycle-aware request cancellation
//   - Debouncing: Throttling search inputs
//   - Retry Counter: Visible feedback of retry mechanism
// =============================================================================

class DioViewModel extends ChangeNotifier {
  final INetworkingRepository _repository;

  DioViewModel({INetworkingRepository? repository})
      : _repository = repository ?? NetworkingRepository();

  // ---------------------------------------------------------------------------
  // STATE: GET ALL (with retry counter)
  // ---------------------------------------------------------------------------
  List<Product> products = [];
  bool isLoadingList = false;
  String? listError;
  int retryAttempt = 0; // Visible in UI to demonstrate retry mechanism
  CancelToken? _listCancelToken;

  Future<void> fetchProducts() async {
    isLoadingList = true;
    listError = null;
    retryAttempt = 0;
    _listCancelToken = CancelToken();
    notifyListeners();
    try {
      products = await _repository.getProductsDio(cancelToken: _listCancelToken);
    } on AppException catch (e) {
      if (e is CancelledByUserException) {
        if (kDebugMode) print('Request cancelled by user — not showing error.');
        return;
      }
      listError = e.message;
    } catch (e) {
      listError = 'Unexpected error: $e';
    } finally {
      isLoadingList = false;
      notifyListeners();
    }
  }

  void cancelFetch() {
    _listCancelToken?.cancel('Cancelled by user.');
    _listCancelToken = null;
    isLoadingList = false;
    listError = 'Request cancelled by user.';
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // STATE: GET BY ID
  // ---------------------------------------------------------------------------
  Product? fetchedProduct;
  bool isLoadingById = false;
  String? byIdError;

  Future<void> fetchProductById(int id) async {
    isLoadingById = true;
    byIdError = null;
    fetchedProduct = null;
    notifyListeners();
    try {
      fetchedProduct = await _repository.getProductByIdDio(id);
    } on AppException catch (e) {
      byIdError = e.message;
    } catch (e) {
      byIdError = 'Unexpected error: $e';
    } finally {
      isLoadingById = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // STATE: CREATE (POST)
  // ---------------------------------------------------------------------------
  Product? createdProduct;
  bool isCreating = false;
  String? createError;

  Future<void> createProduct(String title, double price) async {
    isCreating = true;
    createError = null;
    createdProduct = null;
    notifyListeners();
    try {
      createdProduct = await _repository.createProductDio(title, price);
    } on AppException catch (e) {
      createError = e.message;
    } catch (e) {
      createError = 'Unexpected error: $e';
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // STATE: UPDATE (PUT)
  // ---------------------------------------------------------------------------
  Product? updatedProduct;
  bool isUpdating = false;
  String? updateError;

  Future<void> updateProduct(int id, String newTitle) async {
    isUpdating = true;
    updateError = null;
    updatedProduct = null;
    notifyListeners();
    try {
      updatedProduct = await _repository.updateProductDio(id, newTitle);
    } on AppException catch (e) {
      updateError = e.message;
    } catch (e) {
      updateError = 'Unexpected error: $e';
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // STATE: DELETE
  // ---------------------------------------------------------------------------
  bool? deleteSuccess;
  bool isDeleting = false;
  String? deleteError;

  Future<void> deleteProduct(int id) async {
    isDeleting = true;
    deleteError = null;
    deleteSuccess = null;
    notifyListeners();
    try {
      deleteSuccess = await _repository.deleteProductDio(id);
    } on AppException catch (e) {
      deleteError = e.message;
    } catch (e) {
      deleteError = 'Unexpected error: $e';
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // DEBOUNCED SEARCH
  // ---------------------------------------------------------------------------
  Timer? _debounceTimer;
  String searchQuery = '';
  List<Product> searchResults = [];
  bool isSearching = false;

  /// Fires a search API call 500ms AFTER the user stops typing.
  /// Without debouncing: typing "abc" → 3 API calls.
  /// With debouncing: typing "abc" fast → 1 API call.
  void onSearchChanged(String query) {
    searchQuery = query;
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      isSearching = true;
      notifyListeners();
      try {
        // Simulate search by fetching and filtering locally (dummyjson search endpoint)
        final all = await _repository.getProductsDio();
        searchResults = all.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
      } catch (e) {
        searchResults = [];
      } finally {
        isSearching = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _listCancelToken?.cancel();
    _debounceTimer?.cancel();
    if (kDebugMode) print('🗑️ DioViewModel disposed — CancelToken cancelled.');
    super.dispose();
  }
}
