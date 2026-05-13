import 'package:flutter/material.dart';
import '../data/secure_storage/secure_storage_service.dart';

class SecureStorageScreen extends StatefulWidget {
  const SecureStorageScreen({super.key});

  @override
  State<SecureStorageScreen> createState() => _SecureStorageScreenState();
}

class _SecureStorageScreenState extends State<SecureStorageScreen> {
  final SecureStorageService _service = SecureStorageService();
  String _logs = "Ready.\n";
  String? _token;

  void _log(String message) {
    setState(() {
      _logs += "-> $message\n";
    });
  }

  Future<void> _saveToken() async {
    try {
      await _service.saveToken("secret_jwt_abc123");
      _log("Saved JWT Token securely.");
      _readToken();
    } catch (e) {
      _log("Error saving: $e");
    }
  }

  Future<void> _readToken() async {
    try {
      final token = await _service.getToken();
      setState(() {
        _token = token;
      });
      _log("Read Token: $_token");
    } catch (e) {
      _log("Error reading: $e");
    }
  }

  Future<void> _deleteToken() async {
    try {
      await _service.deleteToken();
      _log("Deleted Token.");
      _readToken();
    } catch (e) {
      _log("Error deleting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Storage')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Uses iOS KeyChain and Android KeyStore. Used strictly for sensitive data like JWT tokens and passwords.",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(onPressed: _saveToken, child: const Text("Save Token")),
              ElevatedButton(onPressed: _readToken, child: const Text("Read Token")),
              ElevatedButton(
                onPressed: _deleteToken,
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete Token"),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text("Current State"),
            subtitle: Text("Token: ${_token ?? 'null'}"),
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
