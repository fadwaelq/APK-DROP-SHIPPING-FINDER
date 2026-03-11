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
  bool _isCheckingInitialAuth = true;
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
    await Future.delayed(Duration.zero);
    notifyListeners();
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
      _isLoading = false;
      _isCheckingInitialAuth = false;
      notifyListeners();
    }
  }

  
  Future<Map<String, dynamic>> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password, rememberMe: rememberMe);

      if (response['success'] == true) {
        // ✅ CORRECTION ICI : Gestion intelligente des clés (access_token au lieu de token)
        final token = response['access_token'] ?? response['access'] ?? response['token'];
        final refresh = response['refresh_token'] ?? response['refresh'];
        final userData = response['user'] ?? (response['data'] != null ? response['data']['user'] : null);

        if (token == null) {
          throw Exception('Token manquant dans la réponse API. Réponse: $response');
        }

        _token = token;
        
        if (userData != null) {
          _user = User.fromJson(userData);
          await _secureStorage.saveUserData(jsonEncode(userData));
        }

        await _secureStorage.saveAuthToken(_token!);
        if (refresh != null) {
          await _secureStorage.saveRefreshToken(refresh);
        }

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

      final response = await _apiService.loginWithGoogle(
        googleResult['access_token'],
        idToken: googleResult['id_token'],
      );

      if (response['success']) {
        final data = response['data'];
        final tokens = data['tokens'];
        _token = tokens['access'];
        _user = User.fromJson(data['user']);

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

      if(response['success'] == true){
        // ✅ CORRECTION ICI : On ne plante plus si l'utilisateur n'est pas renvoyé immédiatement
        final user = response['user'];

        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'user': user,
          'email': response['email'],
          'access_token': response['access_token'] ?? response['token'],
          'otp_expires_in': response['otp_expires_in'],
          'next_step': response['next_step'],
          'message': response['message'] ?? response['confirmation'],
        };
      }else{
        _error = response['message']?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': _error,
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
      
      // ✅ Sécurisation de la vérification OTP aussi
      final token = response['access_token'] ?? response['access'] ?? response['token'];
      final refresh = response['refresh_token'] ?? response['refresh'];
      final userData = response['user'];

      if(token == null && userData == null){
         throw Exception('Token or user data missing in OTP verification response');
      }
      
      if (token != null) _token = token;
      if (userData != null) _user = User.fromJson(userData);

      if (_token != null) {
        await _secureStorage.saveAuthToken(_token!);
        _apiService.setAuthToken(_token!);
      }
      if (refresh != null) {
        await _secureStorage.saveRefreshToken(refresh);
      }
      if (userData != null) {
        await _secureStorage.saveUserData(jsonEncode(userData));
      }

      _isLoading = false;
      notifyListeners();
      return response;

      
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