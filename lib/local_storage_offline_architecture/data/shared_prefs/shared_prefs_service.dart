import 'package:shared_preferences/shared_preferences.dart';

/// A service class to handle SharedPreferences operations.
/// 
/// Educational Note:
/// SharedPreferences loads the ENTIRE preference file into memory.
/// Therefore, it should ONLY be used for small data:
/// - theme mode
/// - auth token
/// - language
/// - first launch flags
class SharedPrefsService {
  SharedPreferences? _prefs;

  /// Initializes the SharedPreferences instance.
  /// 
  /// Step 1: Call `SharedPreferences.getInstance()`
  /// This reads the XML (Android) or NSUserDefaults (iOS) and loads it into memory.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Checks if initialized.
  bool get isInitialized => _prefs != null;

  /// Saves a string value.
  /// 
  /// Step 2: Use `setString` to store a value asynchronously to disk.
  Future<void> saveToken(String token) async {
    if (!isInitialized) throw Exception("SharedPreferences not initialized!");
    await _prefs!.setString('token', token);
  }

  /// Retrieves a string value.
  /// 
  /// Step 3: Use `getString`. Note this is SYNCHRONOUS because data is already in memory.
  String? getToken() {
    if (!isInitialized) throw Exception("SharedPreferences not initialized!");
    return _prefs!.getString('token');
  }

  /// Saves a boolean value.
  Future<void> saveThemeMode(bool isDark) async {
    if (!isInitialized) throw Exception("SharedPreferences not initialized!");
    await _prefs!.setBool('isDark', isDark);
  }

  /// Retrieves a boolean value.
  bool? getThemeMode() {
    if (!isInitialized) throw Exception("SharedPreferences not initialized!");
    return _prefs!.getBool('isDark');
  }

  /// Deletes a specific key.
  Future<void> deleteToken() async {
    if (!isInitialized) throw Exception("SharedPreferences not initialized!");
    await _prefs!.remove('token');
  }

  /// Clears ALL data in SharedPreferences.
  Future<void> clearAll() async {
    if (!isInitialized) throw Exception("SharedPreferences not initialized!");
    await _prefs!.clear();
  }
}
