import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/isar_product.dart';

/// Educational Note:
/// Isar is a high-performance NoSQL database for Flutter.
/// It supports fast indexed queries, full-text search, and reactive streams.
/// Best used for: Huge datasets, complex offline-first sync.
class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    /// Step 1: Check if an instance is already open. Isar runs as a singleton.
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      /// Step 2: Open the database, passing in the generated Schemas.
      return await Isar.open(
        [IsarProductSchema],
        directory: dir.path,
        inspector: true, // Enables the Isar Inspector tool for debugging in browser
      );
    }
    return Future.value(Isar.getInstance());
  }

  /// Write a product
  /// 
  /// Step 3: ACID Transactions. 
  /// Any changes (put, delete, clear) MUST be wrapped in `writeTxn`.
  /// This ensures that if the app crashes halfway, the database isn't corrupted.
  Future<void> saveProduct(IsarProduct product) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.isarProducts.put(product); // 'put' works as an Upsert
    });
  }

  /// Watch all products (Reactive Stream)
  /// 
  /// Step 4: Reactive Streams.
  /// `watch(fireImmediately: true)` acts like a BehaviorSubject. It immediately yields 
  /// the current data, and then yields again every time the collection changes.
  Stream<List<IsarProduct>> watchAllProducts() async* {
    final isar = await db;
    yield* isar.isarProducts.where().watch(fireImmediately: true);
  }

  /// Search by name prefix (Indexed search)
  /// 
  /// Step 5: Advanced Queries.
  /// Isar supports `.filter()` chains to do complex querying incredibly fast.
  Future<List<IsarProduct>> searchProducts(String prefix) async {
    final isar = await db;
    return await isar.isarProducts
        .filter()
        .nameStartsWith(prefix)
        .findAll();
  }

  /// Delete by ID
  Future<void> deleteProduct(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.isarProducts.delete(id);
    });
  }

  /// Clear Collection
  Future<void> clearAll() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.isarProducts.clear();
    });
  }
}
