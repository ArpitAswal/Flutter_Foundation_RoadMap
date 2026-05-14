import 'package:flutter/material.dart';
import '../data/shared_prefs/shared_prefs_service.dart';

class SharedPrefsScreen extends StatefulWidget {
  const SharedPrefsScreen({super.key});

  @override
  State<SharedPrefsScreen> createState() => _SharedPrefsScreenState();
}

class _SharedPrefsScreenState extends State<SharedPrefsScreen> {
  final SharedPrefsService _service = SharedPrefsService();
  String _logs = "Awaiting initialization...\n";
  String _codeSnippet = "// Code snippet will appear here...";
  String? _currentToken;
  bool? _currentTheme;

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

  Future<void> _init() async {
    _updateCode('''
// 1. Get the SharedPreferences instance
final prefs = await SharedPreferences.getInstance();
// Now it's loaded into memory
    '''.trim());
    try {
      await _service.init();
      _log("SharedPreferences Initialized!");
      _readData(null);
    } catch (e) {
      _log("Error initializing: $e");
    }
  }

  void _readData(String? s) {
    if(s != null) {
      _updateCode('''
// 2. Read Data synchronously (since it's in memory)
final token = prefs.getString('token');
final isDark = prefs.getBool('isDark');
    '''.trim());
    }
    try {
      setState(() {
        _currentToken = _service.getToken();
        _currentTheme = _service.getThemeMode();
      });
      _log("Read Data: Token=$_currentToken, isDark=$_currentTheme");
    } catch (e) {
      _log("Error reading data: $e");
    }
  }

  Future<void> _saveData() async {
    _updateCode('''
// 3. Save data to disk
await prefs.setString('token', 'user_token_12345');
await prefs.setBool('isDark', true);
    '''.trim());
    try {
      await _service.saveToken("user_token_12345");
      await _service.saveThemeMode(true);
      _log("Saved Token and ThemeMode (true).");
      _readData(null);
    } catch (e) {
      _log("Error saving data: $e");
    }
  }

  Future<void> _deleteToken() async {
    _updateCode('''
// 4. Delete specific key
await prefs.remove('token');
    '''.trim());
    try {
      await _service.deleteToken();
      _log("Deleted Token.");
      _readData(null);
    } catch (e) {
      _log("Error deleting token: $e");
    }
  }

  Future<void> _clearAll() async {
    _updateCode('''
// 5. Clear entirely
await prefs.clear();
    '''.trim());
    try {
      await _service.clearAll();
      _log("Cleared all SharedPreferences data.");
      _readData(null);
    } catch (e) {
      _log("Error clearing data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SharedPreferences')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "SharedPreferences is for simple key-value pairs. It loads everything into memory.",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(onPressed: _init, child: const Text("Init")),
              ElevatedButton(onPressed: _saveData, child: const Text("Save Data")),
              ElevatedButton(onPressed: ()=> _readData(''), child: const Text("Read Data")),
              ElevatedButton(onPressed: _deleteToken, child: const Text("Delete Token")),
              ElevatedButton(
                onPressed: _clearAll,
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Clear All"),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text("Current State"),
            subtitle: Text("Token: ${_currentToken ?? 'null'}\nTheme: ${_currentTheme ?? 'null'}"),
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
