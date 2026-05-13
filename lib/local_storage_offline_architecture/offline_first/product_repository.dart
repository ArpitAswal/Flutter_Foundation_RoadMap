import 'dart:async';
import 'package:flutter/foundation.dart';
import 'mock_api.dart';
import '../data/hive/hive_service.dart';
import '../models/hive_product.dart';

/// Educational Note:
/// The Repository acts as the single source of truth.
/// The UI asks the Repository for data. The Repository decides
/// whether to get it from the local cache (Hive) or the network (API).
/// 
/// We implement a "Cache-First" strategy here:
/// 1. Instantly return local cached data to the UI.
/// 2. Fetch fresh data from API in background.
/// 3. Update local cache and return fresh data.
class ProductRepository {
  final MockApi api;
  final HiveService localDb;

  ProductRepository(this.api, this.localDb);

  /// Streams data to the UI so it can update when fresh data arrives.
  Stream<List<HiveProduct>> getProductsCacheFirst() async* {
    if (!localDb.isBoxOpen) {
      await localDb.initBox();
    }

    // 1. Instantly yield local data if available
    final localData = localDb.getAllProducts();
    if (localData.isNotEmpty) {
      yield localData;
    }

    // 2. Fetch from remote API in background
    try {
      final remoteJson = await api.fetchProducts();
      
      // Convert JSON to Hive Objects
      final remoteProducts = remoteJson.map((json) {
        return HiveProduct(
          id: json['id'],
          name: json['name'],
          price: json['price'],
        );
      }).toList();

      // 3. Save fresh data to local cache
      await localDb.addProducts(remoteProducts);

      // 4. Yield the fresh data
      yield localDb.getAllProducts();
    } catch (e) {
      // If offline/API fails, we just don't yield the fresh data.
      // The UI already got the cached data.
      debugPrint("Network error, falling back to cache only.");
    }
  }

  /// Clears the local cache to demonstrate fetching from API again.
  Future<void> clearCache() async {
    if (!localDb.isBoxOpen) {
      await localDb.initBox();
    }
    await localDb.clearBox();
  }
}
