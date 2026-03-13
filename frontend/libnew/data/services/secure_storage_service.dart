import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  Future<void> saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
  }
}