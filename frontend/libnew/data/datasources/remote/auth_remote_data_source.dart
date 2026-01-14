import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>?> login(String email, String password);
  Future<Map<String, dynamic>?> register(String fullName, String email, String password);
  Future<bool> logout();
  Future<Map<String, dynamic>?> verifyOTP(String email, String otp);
  Future<bool> resendOTP(String email);
  Future<bool> requestPasswordReset(String email);
  Future<bool> confirmPasswordReset(String email, String otp, String newPassword);
  Future<Map<String, dynamic>?> loginWithGoogle(String accessToken, {String? idToken});
  Future<Map<String, dynamic>?> updateProfile(String fullName);
  Future<Map<String, dynamic>?> getUserProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> register(String fullName, String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'password_confirm': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  @override
  Future<bool> logout() async {
    // In mobile apps, logout is typically just clearing local storage
    return true;
  }

  @override
  Future<Map<String, dynamic>?> verifyOTP(String email, String otp) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<bool> resendOTP(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/resend-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/password-reset/request/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to request password reset: $e');
    }
  }

  @override
  Future<bool> confirmPasswordReset(String email, String otp, String newPassword) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/password-reset/confirm/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
          'new_password_confirm': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to confirm password reset: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> loginWithGoogle(String accessToken, {String? idToken}) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/google/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_token': accessToken,
          if (idToken != null) 'id_token': idToken,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to login with Google: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> updateProfile(String fullName) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConstants.getToken()}',
        },
        body: jsonEncode({'full_name': fullName}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: {
          'Authorization': 'Bearer ${ApiConstants.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
}