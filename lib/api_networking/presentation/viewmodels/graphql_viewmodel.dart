import 'package:flutter/foundation.dart';
import '../../core/models/country.dart';
import '../../core/models/domain/product.dart';
import '../../core/repositories/networking_repository.dart';

// =============================================================================
// 🧠 GraphQL ViewModel — Single Responsibility
// =============================================================================
//
// This ViewModel owns ALL state for the GraphQL Demo Screen.
// It demonstrates Query (read) and Mutation (write) patterns.
// =============================================================================

class GraphqlViewModel extends ChangeNotifier {
  final INetworkingRepository _repository;

  GraphqlViewModel({INetworkingRepository? repository})
      : _repository = repository ?? NetworkingRepository();

  // ---------------------------------------------------------------------------
  // STATE: QUERY — Get Countries (READ)
  // ---------------------------------------------------------------------------
  List<Country> countries = [];
  bool isLoadingCountries = false;
  String? countriesError;

  Future<void> fetchCountries() async {
    isLoadingCountries = true;
    countriesError = null;
    notifyListeners();
    try {
      countries = await _repository.getCountriesGraphQL();
    } catch (e) {
      countriesError = e.toString();
    } finally {
      isLoadingCountries = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // STATE: MUTATION — Create Product (WRITE)
  // ---------------------------------------------------------------------------
  Product? mutationResult;
  bool isMutating = false;
  String? mutationError;
  bool mutationSuccess = false;

  Future<void> createProduct(String title, double price) async {
    isMutating = true;
    mutationError = null;
    mutationResult = null;
    mutationSuccess = false;
    notifyListeners();
    try {
      mutationResult = await _repository.createProductGraphQL(title, price);
      mutationSuccess = true;
    } catch (e) {
      mutationError = e.toString();
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }

  void resetMutation() {
    mutationResult = null;
    mutationError = null;
    mutationSuccess = false;
    notifyListeners();
  }

  @override
  void dispose() {
    if (kDebugMode) print('🗑️ GraphqlViewModel disposed.');
    super.dispose();
  }
}
