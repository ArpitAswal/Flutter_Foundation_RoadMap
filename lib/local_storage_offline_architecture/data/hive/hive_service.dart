import 'package:hive_flutter/hive_flutter.dart';
import '../../models/hive_product.dart';

/// A service class to handle Hive local NoSQL storage.
///
/// Educational Note:
/// Hive is extremely fast and stores data as binary serialized objects.
/// It works in "Boxes" (similar to tables in SQL or collections in NoSQL).
/// Best used for:
/// - Offline caching of API data
/// - Local notes, cart systems
class HiveService {
  static const String boxName = 'productsBox';
  Box<HiveProduct>? _box;

  /// Initializes Hive Box.
  /// 
  /// Step 1: Hive.initFlutter() must be called first (usually in main.dart).
  /// Step 2: Register Adapters (e.g. Hive.registerAdapter(HiveProductAdapter())).
  /// Step 3: Open the box using Hive.openBox<T>('boxName'). This creates a file on disk
  /// and loads the data into memory.
  Future<void> initBox() async {
    _box = await Hive.openBox<HiveProduct>(boxName);
  }

  /// Check if box is open.
  bool get isBoxOpen => _box != null && _box!.isOpen;

  /// Add a single product.
  /// 
  /// Step 4: Write data using `put(key, value)`. 
  /// Hive uses a key-value structure inside the box. If the key already exists, 
  /// the data is updated (Upsert). If not, it is created.
  Future<void> addProduct(HiveProduct product) async {
    if (!isBoxOpen) throw Exception("Hive Box not open!");
    await _box!.put(product.id, product);
  }

  /// Add multiple products (fast batch write).
  /// 
  /// Step 5: For writing multiple items, `putAll` is highly optimized.
  /// It writes everything to disk in a single transaction, avoiding multiple disk writes.
  Future<void> addProducts(List<HiveProduct> products) async {
    if (!isBoxOpen) throw Exception("Hive Box not open!");
    final Map<String, HiveProduct> map = {
      for (var p in products) p.id: p
    };
    await _box!.putAll(map);
  }

  /// Get all products.
  /// 
  /// Step 6: Read data using `box.values`. 
  /// Notice this is synchronous (no `await`). Why? Because when `openBox` was called, 
  /// all data was loaded directly into RAM, making reads instant.
  List<HiveProduct> getAllProducts() {
    if (!isBoxOpen) throw Exception("Hive Box not open!");
    return _box!.values.toList();
  }

  /// Delete a product.
  /// 
  /// Step 7: Delete an entry using `box.delete(key)`. 
  /// This removes it from memory and flags it as deleted on disk.
  Future<void> deleteProduct(String id) async {
    if (!isBoxOpen) throw Exception("Hive Box not open!");
    await _box!.delete(id);
  }

  /// Close the box.
  Future<void> closeBox() async {
    if (isBoxOpen) {
      await _box!.close();
    }
  }

  /// Clear all data in the box.
  Future<void> clearBox() async {
    if (isBoxOpen) {
      await _box!.clear();
    }
  }
}
