import 'package:flutter/material.dart';
import 'mock_api.dart';
import 'product_repository.dart';
import '../data/hive/hive_service.dart';
import '../models/hive_product.dart';

class OfflineFirstScreen extends StatefulWidget {
  const OfflineFirstScreen({super.key});

  @override
  State<OfflineFirstScreen> createState() => _OfflineFirstScreenState();
}

class _OfflineFirstScreenState extends State<OfflineFirstScreen> {
  late ProductRepository _repository;
  String _logs = "Awaiting interaction...\n";
  List<HiveProduct> _data = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = ProductRepository(MockApi(), HiveService());
  }

  void _log(String message) {
    setState(() {
      _logs += "-> $message\n";
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _data = []; // Clear for demo purposes
    });
    _log("Requested data from Repository...");
    
    // Listen to the stream
    _repository.getProductsCacheFirst().listen((products) {
      setState(() {
        _data = products;
        _isLoading = false;
      });
      _log("Received stream update: ${products.length} items.");
    });
  }

  Future<void> _clearCache() async {
    await _repository.clearCache();
    setState(() {
      _data = [];
    });
    _log("Local cache cleared.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline-First Architecture')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Cache-First Strategy: The repository instantly returns local data (if any), then fetches fresh data from the API in the background (takes 2 seconds), saves it locally, and updates the UI.",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchData,
                child: const Text("Fetch Data (Cache First)"),
              ),
              ElevatedButton(
                onPressed: _clearCache,
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Clear Cache"),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: _data.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _data.isEmpty
                    ? const Center(child: Text("No Data. Press Fetch."))
                    : ListView.builder(
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          final item = _data[index];
                          return ListTile(
                            leading: const Icon(Icons.cloud_done, color: Colors.blue),
                            title: Text(item.name),
                            subtitle: Text("ID: ${item.id} - \$${item.price}"),
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
