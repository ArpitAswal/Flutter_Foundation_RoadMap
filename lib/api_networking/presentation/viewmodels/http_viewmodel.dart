import 'package:flutter/foundation.dart';
import '../../core/models/domain/product.dart';
import '../../core/network/app_exceptions.dart';
import '../../core/repositories/networking_repository.dart';

// =============================================================================
// 🧠 HTTP ViewModel — Single Responsibility
// =============================================================================
//
// This ViewModel owns ALL state for the HTTP Demo Screen.
// It only knows about the Repository interface and Domain Models.
// It has ZERO knowledge of `http` package, DTOs, or JSON.
// =============================================================================

class HttpViewModel extends ChangeNotifier {
  final INetworkingRepository _repository;

  HttpViewModel({INetworkingRepository? repository})
      : _repository = repository ?? NetworkingRepository();

  // ---------------------------------------------------------------------------
  // STATE: GET ALL
  // ---------------------------------------------------------------------------
  List<Product> products = [];
  bool isLoadingList = false;
  String? listError;

  Future<void> fetchProducts() async {
    isLoadingList = true;
    listError = null;
    notifyListeners();
    try {
      products = await _repository.getProductsHttp();
    } on AppException catch (e) {
      listError = e.message;
    } catch (e) {
      listError = 'Unexpected error: $e';
    } finally {
      isLoadingList = false;
      notifyListeners();
    }
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
      fetchedProduct = await _repository.getProductByIdHttp(id);
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
      createdProduct = await _repository.createProductHttp(title, price);
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
      updatedProduct = await _repository.updateProductHttp(id, newTitle);
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
      deleteSuccess = await _repository.deleteProductHttp(id);
    } on AppException catch (e) {
      deleteError = e.message;
    } catch (e) {
      deleteError = 'Unexpected error: $e';
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (kDebugMode) print('🗑️ HttpViewModel disposed.');
    super.dispose();
  }
}
