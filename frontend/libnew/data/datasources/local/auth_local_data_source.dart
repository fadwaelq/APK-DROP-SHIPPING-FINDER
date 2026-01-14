import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth/auth_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuth(AuthModel auth);
  Future<AuthModel?> getCachedAuth();
  Future<void> clearAuth();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _cachedAuthKey = 'cached_auth';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<void> cacheAuth(AuthModel auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedAuthKey, jsonEncode({
      'access_token': auth.accessToken,
      'refresh_token': auth.refreshToken,
      'user': auth.user.toJson(),
    }));
  }

  @override
  Future<AuthModel?> getCachedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cachedAuthKey);

    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      return AuthModel(
        accessToken: jsonMap['access_token'],
        refreshToken: jsonMap['refresh_token'],
        user: jsonMap['user'] != null ? jsonMap['user'] : {},
      );
    }
    return null;
  }

  @override
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedAuthKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}