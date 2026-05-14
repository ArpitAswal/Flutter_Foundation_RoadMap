import 'package:flutter/material.dart';
import '../data/drift/drift_database.dart';

class DriftScreen extends StatefulWidget {
  const DriftScreen({super.key});

  @override
  State<DriftScreen> createState() => _DriftScreenState();
}

class _DriftScreenState extends State<DriftScreen> {
  late AppDatabase _db;
  String _logs = "Initializing Drift...\n";
  String _codeSnippet = "// Code snippet will appear here...";

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _log("Drift Database Opened. Observing stream...");
  }

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

  Future<void> _insertData() async {
    _updateCode('''
// 1. Insert or Update data via DAO
await _db.insertOrUpdateProduct(
  DriftProduct(id: "d1", name: "Drift Book", price: 30.5)
);
    '''.trim());
    try {
      await _db.insertOrUpdateProduct(
          DriftProduct(id: "d1", name: "Drift Book", price: 30.5));
      await _db.insertOrUpdateProduct(
          DriftProduct(id: "d2", name: "Drift Course", price: 99.9));
      _log("Inserted Drift Book & Course.");
    } catch (e) {
      _log("Error inserting: $e");
    }
  }

  Future<void> _deleteBook() async {
    _updateCode('''
// 2. Delete data (Generates: DELETE FROM table WHERE id = 'd1')
await _db.deleteProduct("d1");
// UI StreamBuilder updates automatically!
    '''.trim());
    try {
      await _db.deleteProduct("d1");
      _log("Deleted Book (d1). Stream will auto-update UI.");
    } catch (e) {
      _log("Error deleting: $e");
    }
  }

  Future<void> _clearAll() async {
    _updateCode('''
// 3. Clear all products
await _db.clearProducts();
    '''.trim());
    try {
      await _db.clearProducts();
      _log("Cleared all products.");
    } catch (e) {
      _log("Error clearing: $e");
    }
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drift (Type-safe SQL)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Drift wraps SQLite and adds reactive streams and type safety. Note how the UI below updates automatically when data changes.",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(onPressed: _insertData, child: const Text("Insert Data")),
              ElevatedButton(onPressed: _deleteBook, child: const Text("Delete Book")),
              ElevatedButton(
                onPressed: _clearAll,
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Clear DB"),
              ),
            ],
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.blueGrey.shade900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Code Snippet:",
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _codeSnippet,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: StreamBuilder<List<DriftProduct>>(
              stream: _db.watchAllProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final data = snapshot.data!;
                if (data.isEmpty) return const Center(child: Text("No data in Stream."));
                
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return ListTile(
                      leading: const Icon(Icons.stream),
                      title: Text(item.name),
                      subtitle: Text("ID: ${item.id} - \$${item.price}"),
                    );
                  },
                );
              },
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
