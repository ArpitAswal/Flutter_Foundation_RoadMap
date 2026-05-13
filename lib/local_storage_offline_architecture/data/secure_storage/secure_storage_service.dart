import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Educational Note:
/// flutter_secure_storage provides KeyChain (iOS) and KeyStore (Android) backed storage.
/// NEVER store sensitive data like JWT tokens or passwords in SharedPreferences or Hive.
/// ALWAYS use secure storage for them.
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Step 1: Write sensitive data.
  /// The plugin handles Android Keystore / iOS Keychain encryption under the hood.
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  /// Step 2: Read sensitive data.
  /// This operation is asynchronous because decrypting from the secure hardware takes time.
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  /// Step 3: Delete specific key.
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  /// Step 4: Delete all keys for this app.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
