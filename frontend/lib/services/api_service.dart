import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Load API URL from environment variable with fallback
  String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password,
      {bool rememberMe = false}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'remember_me': rememberMe,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
      String fullName, String email, String password) async {
    try {
      final payload = {
        'full_name': fullName, // ✅ CORRECTION ICI : Le tiret du bas est bien présent
        'email': email,
        'password': password,
        'password_confirm': password,
      };

      print('📤 REGISTER PAYLOAD: $payload');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {
          'Content-Type': 'application/json', // 🔥 IMPORTANT
        },
        body: jsonEncode(payload),
      );

      print('📥 REGISTER STATUS: ${response.statusCode}');
      print('📥 REGISTER BODY: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'otp_code': otp,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-otp/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/token/refresh/'),
        headers: _headers,
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/password-reset/request/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/password-reset/confirm/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
          'new_password_confirm': newPassword,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile(String fullName) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: _headers,
        body: jsonEncode({'full_name': fullName}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Products
  Future<Map<String, dynamic>> getProducts(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/?page=$page'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getTrendingProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/?is_trending=true'),
        headers: _headers,
      );

      print('📦 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> products = [];

        // ✅ CORRECTION ICI : Gère la réponse qu'elle soit une Liste ou un Dictionnaire
        if (decoded is List) {
          products = decoded;
        } else if (decoded is Map && decoded.containsKey('results')) {
          products = decoded['results'];
        }

        return {
          'success': true,
          'data': products,
        };
      } else {
        return {
          'success': false,
          'message': 'Server error ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getTrendingProducts: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search/?q=$query'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id/'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Favorites
  Future<Map<String, dynamic>> getFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> toggleFavorite(String productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favorites/toggle/'),
        headers: _headers,
        body: jsonEncode({'product_id': productId}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Subscription
  Future<Map<String, dynamic>> updateSubscription(String plan) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscription/update/'),
        headers: _headers,
        body: jsonEncode({'plan': plan}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Settings
  Future<Map<String, dynamic>> updateNotificationSettings(bool enabled) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/settings/notifications/'),
        headers: _headers,
        body: jsonEncode({'enabled': enabled}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Helper method to handle responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        // Handle both list and map responses
        if (data is List) {
          return {'success': true, 'data': data};
        } else if (data is Map) {
          // Backend returns {success: true, message_code: ..., data: {...}}
          // We preserve the structure but ensure success is true
          if (data.containsKey('success')) {
            print(data.length);
            return Map<String, dynamic>.from(data);
          }
          return {'success': true, ...data};
        } else {
          return {'success': true, 'data': data};
        }
      } else {
        // Try to parse error as JSON
        try {
          final error = jsonDecode(response.body);
          // Backend returns {success: false, message_code: ..., errors: {...}}
          if (error is Map) {
            return {
              'success': false,
              'message_code': error['message_code'],
              'message': error['message'] ??
                  error['detail'] ??
                  error['message_code'] ??
                  'Request failed',
              'errors': error['errors'],
            };
          }
          return {
            'success': false,
            'message': error['message'] ?? error['detail'] ?? 'Request failed',
          };
        } catch (e) {
          // If response is not JSON (e.g., HTML error page)
          return {
            'success': false,
            'message':
                'Server error (${response.statusCode}): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: $e',
      };
    }
  }

  /// Google Sign-In
  Future<Map<String, dynamic>> loginWithGoogle(String accessToken,
      {String? idToken}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google/login/'),
        headers: _headers,
        body: jsonEncode({
          'access_token': accessToken,
          if (idToken != null) 'id_token': idToken,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Apple Sign-In (for future implementation)
  Future<Map<String, dynamic>> loginWithApple(String identityToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/apple/login/'),
        headers: _headers,
        body: jsonEncode({
          'id_token': identityToken,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}