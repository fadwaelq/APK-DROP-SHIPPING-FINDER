import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';
import '../services/google_auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isCheckingInitialAuth = true; // Flag to indicate initial auth check is pending
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading || _isCheckingInitialAuth;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  final ApiService _apiService = ApiService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final GoogleAuthService _googleAuth = GoogleAuthService();

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // _isCheckingInitialAuth is already true by default
    // Use Future.delayed to ensure UI can catch the loading state
    await Future.delayed(Duration.zero);
    notifyListeners();
    
    // Load stored auth (this will set _isCheckingInitialAuth to false when done)
    await _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      _token = await _secureStorage.getAuthToken();
      final userJson = await _secureStorage.getUserData();

      if (_token != null && userJson != null) {
        try {
          _user = User.fromJson(jsonDecode(userJson));
          _apiService.setAuthToken(_token!);
        } catch (e) {
          debugPrint('Error parsing stored user data: $e');
          await logout();
        }
      }
    } catch (e) {
      debugPrint('Error loading stored auth: $e');
      await logout();
    } finally {
      // Set loading to false and notify listeners when done
      _isLoading = false;
      _isCheckingInitialAuth = false; // Mark initial auth check as complete
      notifyListeners();
    }
  }

  
Future<Map<String, dynamic>> login(String email, String password, {bool rememberMe = false}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final response = await _apiService.login(email, password, rememberMe: rememberMe);

    if (response['success']) {
      final token = response['token'];
      final refresh = response['refresh'];
      final userData = response['user'];

      if (token == null) {
        throw Exception('Token manquant dans la réponse API');
      }

      _token = token;
      _user = User.fromJson(userData);

      // Sauvegarde sécurisée
      await _secureStorage.saveAuthToken(_token!);
      await _secureStorage.saveRefreshToken(refresh);
      await _secureStorage.saveUserData(jsonEncode(userData));

      _apiService.setAuthToken(_token!);

      _isLoading = false;
      notifyListeners();
      return {'success': true};
    } else {
      _error = response['message'] ?? response['message_code'] ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': _error,
        'message_code': response['message_code'],
      };
    }
  } catch (e) {
    _error = 'Network error: ${e.toString()}';
    _isLoading = false;
    notifyListeners();
    return {'success': false, 'message': _error};
  }
}

  /// Google Sign-In
  Future<Map<String, dynamic>> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Sign in with Google
      final googleResult = await _googleAuth.signIn();
      
      if (!googleResult['success']) {
        _error = googleResult['message'];
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': _error,
        };
      }

      // Step 2: Send access token and id token to backend
      final response = await _apiService.loginWithGoogle(
        googleResult['access_token'],
        idToken: googleResult['id_token'],
      );

      if (response['success']) {
        // Backend returns: {success: true, message_code: "success_login", data: {user: {...}, tokens: {...}}}
        final data = response['data'];
        final tokens = data['tokens'];
        _token = tokens['access'];
        _user = User.fromJson(data['user']);

        // Store credentials
        await _secureStorage.saveAuthToken(_token!);
        await _secureStorage.saveRefreshToken(tokens['refresh']);
        await _secureStorage.saveUserData(jsonEncode(data['user']));
        _apiService.setAuthToken(_token!);

        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return {'success': true};
      } else {
        _error = response['message'] ?? response['message_code'] ?? 'Google login failed';
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': _error,
          'message_code': response['message_code'],
        };
      }
    } catch (e) {
      _error = 'Google login error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(fullName, email, password);

      if (response['success']) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message_code': response['message_code'],
          'user': response['data']['user'],
        };
      } else {
        _error = response['message'] ?? response['message_code'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': _error,
          'message_code': response['message_code'],
          'errors': response['errors'],
        };
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.verifyOTP(email, otp);
      _isLoading = false;
      notifyListeners();

      if (response['success']) {
        return {'success': true, 'message_code': response['message_code']};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? response['message_code'],
          'message_code': response['message_code'],
        };
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<Map<String, dynamic>> resendOTP(String email) async {
    try {
      final response = await _apiService.resendOTP(email);
      return response;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.requestPasswordReset(email);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset(String email, String otp, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.confirmPasswordReset(email, otp, newPassword);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    // Sign out from Google if signed in
    if (await _googleAuth.isSignedIn()) {
      await _googleAuth.signOut();
    }

    _user = null;
    _token = null;

    await _secureStorage.clearAll();
    notifyListeners();
  }

  Future<void> updateProfile(String fullName) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.updateProfile(fullName);

      if (response['success']) {
        final userData = response['data']['user'];
        _user = User.fromJson(userData);
        await _secureStorage.saveUserData(jsonEncode(userData));
      }
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}