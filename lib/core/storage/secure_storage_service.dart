import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Delete token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Save user data
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: 'user_data', value: userData);
  }

  // Get user data
  Future<String?> getUserData() async {
    return await _storage.read(key: 'user_data');
  }

  // Delete user data
  Future<void> deleteUserData() async {
    await _storage.delete(key: 'user_data');
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Generic save
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Generic read
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Generic delete
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
