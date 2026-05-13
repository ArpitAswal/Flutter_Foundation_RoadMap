import 'package:flutter/material.dart';
import '../models/hive_product.dart';
import '../data/hive/hive_service.dart';

class HiveScreen extends StatefulWidget {
  const HiveScreen({super.key});

  @override
  State<HiveScreen> createState() => _HiveScreenState();
}

class _HiveScreenState extends State<HiveScreen> {
  final HiveService _service = HiveService();
  String _logs = "Awaiting Hive Box open...\n";
  String _codeSnippet = "// Code snippet will appear here...";
  List<HiveProduct> _products = [];

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

  Future<void> _initBox() async {
    _updateCode(
      '''
// 1. Open a Box (similar to a table in SQL)
_box = await Hive.openBox<HiveProduct>('productsBox');
    '''
          .trim(),
    );
    try {
      await _service.initBox();
      _log("Hive Box 'productsBox' Opened!");
      _readData(_codeSnippet);
    } catch (e) {
      _log("Error opening box: $e");
    }
  }

  void _readData(String? s) {
    _updateCode(
      s ??
          '''
// 2. Read all values from the Box
final products = _box!.values.toList();
    '''
              .trim(),
    );
    try {
      setState(() {
        _products = _service.getAllProducts();
      });
      _log("Read Data: ${_products.length} products found.");
    } catch (e) {
      _log("Error reading data: $e");
    }
  }

  Future<void> _addMockData() async {
    _updateCode(
      '''
// 3. Put multiple items (Upsert)
await _box!.putAll({
  "p1": HiveProduct(id: "p1", name: "Laptop", ...),
  "p2": HiveProduct(id: "p2", name: "Mouse", ...),
});
    '''
          .trim(),
    );
    try {
      final p1 = HiveProduct(id: "p1", name: "Laptop", price: 1200.0);
      final p2 = HiveProduct(id: "p2", name: "Mouse", price: 25.0);
      await _service.addProducts([p1, p2]);
      _log("Added Mock Products: Laptop, Mouse.");
      _readData(_codeSnippet);
    } catch (e) {
      debugPrint("error -> $e");
      _log("Error adding data: $e");
    }
  }

  Future<void> _deleteLaptop() async {
    _updateCode(
      '''
// 4. Delete item by key
await _box!.delete("p1");
    '''
          .trim(),
    );
    try {
      await _service.deleteProduct("p1");
      _log("Deleted product with ID 'p1'.");
      _readData(_codeSnippet);
    } catch (e) {
      _log("Error deleting product: $e");
    }
  }

  Future<void> _clearBox() async {
    _updateCode(
      '''
// 5. Clear all data from Box
await _box!.clear();
    '''
          .trim(),
    );
    try {
      await _service.clearBox();
      _log("Cleared all data in Hive Box.");
      _readData(_codeSnippet);
    } catch (e) {
      _log("Error clearing box: $e");
    }
  }

  Future<void> _closeBox() async {
    _updateCode(
      '''
// 6. Close the Box
await _box!.close();
    '''
          .trim(),
    );
    try {
      await _service.closeBox();
      setState(() {
        _products = [];
      });
      _log("Hive Box Closed. Must re-init to use again.");
    } catch (e) {
      _log("Error closing box: $e");
    }
  }

  @override
  void dispose() {
    _service.closeBox();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hive (NoSQL)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Hive is a fast, pure-Dart NoSQL database. Good for offline product caching.",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _initBox,
                child: const Text("Init Box"),
              ),
              ElevatedButton(
                onPressed: _addMockData,
                child: const Text("Write Data"),
              ),
              ElevatedButton(
                onPressed: () => _readData(null),
                child: const Text("Read Data"),
              ),
              ElevatedButton(
                onPressed: _deleteLaptop,
                child: const Text("Delete P1"),
              ),
              ElevatedButton(
                onPressed: _clearBox,
                child: const Text("Clear All"),
              ),
              ElevatedButton(
                onPressed: _closeBox,
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Close Box"),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final p = _products[index];
                return ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(p.name),
                  subtitle: Text("ID: ${p.id} - \$${p.price}"),
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.black87,
              child: SingleChildScrollView(
                child: Text(
                  _logs,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
