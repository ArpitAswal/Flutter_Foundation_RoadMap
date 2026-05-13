import 'package:flutter/material.dart';
import '../models/isar_product.dart';
import '../data/isar/isar_service.dart';

class IsarScreen extends StatefulWidget {
  const IsarScreen({super.key});

  @override
  State<IsarScreen> createState() => _IsarScreenState();
}

class _IsarScreenState extends State<IsarScreen> {
  late IsarService _service;
  String _logs = "Initializing Isar Database...\n";
  String _codeSnippet = "// Code snippet will appear here...";

  @override
  void initState() {
    super.initState();
    _service = IsarService();
    _log("Isar Db Open Future created. Observing stream...");
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

  Future<void> _insertMockData() async {
    _updateCode('''
// 1. Write Data within an ACID transaction
await isar.writeTxn(() async {
  await isar.isarProducts.put(IsarProduct()..name="Isar Fast");
});
    '''.trim());
    try {
      final p1 = IsarProduct()..name = "Isar Fast Laptop"..price = 1500.0;
      final p2 = IsarProduct()..name = "Isar Cache Drive"..price = 150.0;
      await _service.saveProduct(p1);
      await _service.saveProduct(p2);
      _log("Inserted two Isar products transactionally.");
    } catch (e) {
      _log("Error inserting: $e");
    }
  }

  Future<void> _searchData() async {
    _updateCode('''
// 2. Perform Indexed Query Search
final results = await isar.isarProducts
  .filter()
  .nameStartsWith("Isar Fast")
  .findAll();
    '''.trim());
    try {
      final results = await _service.searchProducts("Isar Fast");
      _log("Search 'Isar Fast': Found ${results.length} items.");
    } catch (e) {
      _log("Error searching: $e");
    }
  }

  Future<void> _clearAll() async {
    _updateCode('''
// 3. Clear all items
await isar.writeTxn(() async {
  await isar.isarProducts.clear();
});
    '''.trim());
    try {
      await _service.clearAll();
      _log("Cleared Isar collection.");
    } catch (e) {
      _log("Error clearing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isar (Fast NoSQL)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Isar is optimized for Flutter. It supports fast queries, full-text search, and ACID transactions. UI updates reactively via streams.",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(onPressed: _insertMockData, child: const Text("Write Transact")),
              ElevatedButton(onPressed: _searchData, child: const Text("Search 'Isar Fast'")),
              ElevatedButton(
                onPressed: _clearAll,
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Clear DB"),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: StreamBuilder<List<IsarProduct>>(
              stream: _service.watchAllProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final data = snapshot.data!;
                if (data.isEmpty) return const Center(child: Text("No items in Isar collection."));
                
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return ListTile(
                      leading: const Icon(Icons.bolt, color: Colors.orange),
                      title: Text(item.name),
                      subtitle: Text("Isar ID: ${item.id} - \$${item.price}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _service.deleteProduct(item.id);
                          _log("Deleted item ${item.id}");
                        },
                      ),
                    );
                  },
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
