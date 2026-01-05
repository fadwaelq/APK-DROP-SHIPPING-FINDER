import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Keys for secure storage
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Auth Token
  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
      debugPrint('🔐 Auth token saved securely');
    } catch (e) {
      debugPrint('❌ Error saving auth token: $e');
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final token = await _storage.read(key: _authTokenKey);
      debugPrint('🔐 Auth token retrieved: ${token != null ? 'exists' : 'null'}');
      return token;
    } catch (e) {
      debugPrint('❌ Error reading auth token: $e');
      return null;
    }
  }

  Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
      debugPrint('🔐 Auth token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting auth token: $e');
    }
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      debugPrint('🔐 Refresh token saved securely');
    } catch (e) {
      debugPrint('❌ Error saving refresh token: $e');
      rethrow;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('❌ Error reading refresh token: $e');
      return null;
    }
  }

  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
      debugPrint('🔐 Refresh token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting refresh token: $e');
    }
  }

  // User Data
  Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: _userDataKey, value: userData);
      debugPrint('🔐 User data saved securely');
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
      rethrow;
    }
  }

  Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey);
    } catch (e) {
      debugPrint('❌ Error reading user data: $e');
      return null;
    }
  }

  Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
      debugPrint('🔐 User data deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user data: $e');
    }
  }

  // Clear all secure data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('🔐 All secure data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing secure data: $e');
    }
  }

  // Check if data exists
  Future<bool> hasAuthToken() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
