import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// A service class to handle raw SQLite operations.
///
/// Educational Note:
/// SQLite provides relational data handling with indexing and complex queries.
/// It is ideal for:
/// - Banking apps
/// - Inventory systems
/// - Apps with many relational tables
class SqliteService {
  static Database? _database;

  /// Initializes the SQLite database and creates tables.
  /// 
  /// Step 1: `getDatabasesPath()` gets the system directory for databases.
  /// Step 2: `join()` creates the full path for the db file.
  /// Step 3: `openDatabase()` creates the file if it doesn't exist.
  /// Step 4: The `onCreate` callback runs ONLY on the first creation to set up the SQL tables.
  Future<void> initDatabase() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Run raw SQL to create the table
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            price REAL NOT NULL
          )
        ''');
      },
    );
  }

  bool get isDbOpen => _database != null && _database!.isOpen;

  /// Insert a product
  /// 
  /// Step 5: `_database!.insert` is a convenience method mapping a Dart Map into a SQL INSERT statement.
  /// We use `ConflictAlgorithm.replace` to achieve "Upsert" behavior (Update if exists, else Insert).
  Future<void> insertProduct(String id, String name, double price) async {
    if (!isDbOpen) throw Exception("Database not opened!");
    
    // We can use the raw query or the convenience helper
    await _database!.insert(
      'products',
      {'id': id, 'name': name, 'price': price},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Query all products using SQL
  /// 
  /// Step 6: `rawQuery` allows you to write literal SQL strings. 
  /// Here we read all rows and sort them descending by price.
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    if (!isDbOpen) throw Exception("Database not opened!");
    return await _database!.rawQuery('SELECT * FROM products ORDER BY price DESC');
  }

  /// Search products with complex condition
  /// 
  /// Step 7: We use the helper `query` and parameterized variables (`?`).
  /// Security Note: Using `?` and `whereArgs` prevents SQL Injection attacks!
  Future<List<Map<String, dynamic>>> searchProductsGreaterThan(double minPrice) async {
    if (!isDbOpen) throw Exception("Database not opened!");
    return await _database!.query(
      'products',
      where: 'price > ?',
      whereArgs: [minPrice],
    );
  }

  /// Delete a specific product
  /// 
  /// Step 8: `delete` maps to SQL DELETE. Again, always use parameterized queries.
  Future<void> deleteProduct(String id) async {
    if (!isDbOpen) throw Exception("Database not opened!");
    await _database!.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Destroy the database entirely
  /// 
  /// Step 9: To completely reset SQLite, close the connection then use `deleteDatabase(path)`.
  /// This wipes the file from the OS entirely.
  Future<void> destroyDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
  }
}
