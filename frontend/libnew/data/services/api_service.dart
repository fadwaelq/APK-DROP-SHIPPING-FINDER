import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';

class ApiService {
  final http.Client _client;
  
  ApiService(this._client);

  String? _token;
  
  void setToken(String? token) {
    _token = token;
  }
  
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null && _token!.isNotEmpty) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('GET request failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('POST request failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('PUT request failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.patch(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('PATCH request failed: $e');
      return null;
    }
  }

  Future<bool> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: _headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('DELETE request failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginWithGoogle(String accessToken, {String? idToken}) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}/auth/google/login/'),
        headers: _headers,
        body: jsonEncode({
          'access_token': accessToken,
          if (idToken != null) 'id_token': idToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Google login request failed: $e');
      return null;
    }
  }
}