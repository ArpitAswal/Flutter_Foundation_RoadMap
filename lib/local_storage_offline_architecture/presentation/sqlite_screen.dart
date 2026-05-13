import 'package:flutter/material.dart';
import '../data/sqlite/sqlite_service.dart';

class SqliteScreen extends StatefulWidget {
  const SqliteScreen({super.key});

  @override
  State<SqliteScreen> createState() => _SqliteScreenState();
}

class _SqliteScreenState extends State<SqliteScreen> {
  final SqliteService _service = SqliteService();
  String _logs = "Awaiting SQLite init...\n";
  String _codeSnippet = "// Code snippet will appear here...";
  List<Map<String, dynamic>> _data = [];

  void _log(String message) {
    setState(() {
      _logs += "-> $message\n";
    });
  }

  void _updateCode(String code) {
    setState(() {
      _codeSnippet = code;
    });
  }

  Future<void> _initDb() async {
    _updateCode('''
// 1. Open Database and Create Table
_database = await openDatabase(path, version: 1, 
  onCreate: (db, version) async {
    await db.execute(
      'CREATE TABLE products (id TEXT PRIMARY KEY, name TEXT)'
    );
  }
);
    '''.trim());
    try {
      await _service.initDatabase();
      _log("SQLite DB Initialized & Opened.");
      _readData();
    } catch (e) {
      _log("Error init DB: $e");
    }
  }

  Future<void> _readData() async {
    _updateCode('''
// 2. Read all data using raw SQL query
final data = await _database!.rawQuery(
  'SELECT * FROM products ORDER BY price DESC'
);
    '''.trim());
    try {
      final data = await _service.getAllProducts();
      setState(() {
        _data = data;
      });
      _log("Read Data: ${_data.length} records. (Ordered by price DESC)");
    } catch (e) {
      _log("Error reading data: $e");
    }
  }

  Future<void> _insertMockData() async {
    _updateCode('''
// 3. Insert data using helper method
await _database!.insert(
  'products',
  {'id': '1', 'name': 'Mechanical Keyboard', 'price': 150.0},
  conflictAlgorithm: ConflictAlgorithm.replace,
);
    '''.trim());
    try {
      await _service.insertProduct("1", "Mechanical Keyboard", 150.0);
      await _service.insertProduct("2", "Monitor", 300.0);
      await _service.insertProduct("3", "USB Cable", 10.0);
      _log("Inserted Keyboard, Monitor, Cable via SQL.");
      _readData();
    } catch (e) {
      _log("Error inserting: $e");
    }
  }

  Future<void> _searchExpensive() async {
    _updateCode('''
// 4. Query with where clause and arguments
final results = await _database!.query(
  'products',
  where: 'price > ?',
  whereArgs: [100.0],
);
    '''.trim());
    try {
      final expensive = await _service.searchProductsGreaterThan(100.0);
      setState(() {
        _data = expensive;
      });
      _log("Filtered > \$100: Found ${expensive.length} records.");
    } catch (e) {
      _log("Error searching: $e");
    }
  }

  Future<void> _destroyDb() async {
    _updateCode('''
// 5. Delete database file from disk entirely
await deleteDatabase(path);
    '''.trim());
    try {
      await _service.destroyDatabase();
      setState(() {
        _data = [];
      });
      _log("Database completely destroyed & deleted off disk.");
    } catch (e) {
      _log("Error destroying: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite (Raw)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "SQLite is a relational DB. Good for complex queries, indexing, and joins. Below we see raw SQL operations.",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(onPressed: _initDb, child: const Text("Init DB")),
              ElevatedButton(onPressed: _insertMockData, child: const Text("Insert Data")),
              ElevatedButton(onPressed: _readData, child: const Text("Read All")),
              ElevatedButton(onPressed: _searchExpensive, child: const Text("Filter > \$100")),
              ElevatedButton(
                onPressed: _destroyDb,
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Destroy DB"),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final row = _data[index];
                return ListTile(
                  leading: const Icon(Icons.table_rows),
                  title: Text(row['name'] as String),
                  subtitle: Text("ID: ${row['id']} - \$${row['price']}"),
                );
              },
            ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.blueGrey.shade900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Code Snippet:", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  _codeSnippet,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.black87,
              child: SingleChildScrollView(
                child: Text(
                  _logs,
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
