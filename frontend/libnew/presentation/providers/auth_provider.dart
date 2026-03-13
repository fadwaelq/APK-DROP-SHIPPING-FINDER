import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/services/google_auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserEntity? _user;
  String? _token;
  bool _isLoading = false;
  bool _isCheckingInitialAuth = true; // Flag to indicate initial auth check is pending
  String? _error;

  UserEntity? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading || _isCheckingInitialAuth;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final LogoutUsecase _logoutUsecase;
  final GoogleAuthService _googleAuthService;

  AuthProvider({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required LogoutUsecase logoutUsecase,
    required GoogleAuthService googleAuthService,
  }) : _loginUsecase = loginUsecase,
       _registerUsecase = registerUsecase,
       _logoutUsecase = logoutUsecase,
       _googleAuthService = googleAuthService {
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
      // TODO: Load stored auth from local storage
      // This is a placeholder implementation
      _isCheckingInitialAuth = false; // Mark initial auth check as complete
      notifyListeners();
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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _loginUsecase.execute(email, password);
      
      if (success) {
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return true;
      } else {
        _error = 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _registerUsecase.execute(fullName, email, password);
      
      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _logoutUsecase.execute();
      
      // Sign out from Google if signed in
      if (await _googleAuthService.isSignedIn()) {
        await _googleAuthService.signOut();
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _token = null;
      _isLoading = false;
      notifyListeners();
    }
    
    return true;
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _googleAuthService.signIn();
      
      if (result['success'] == true) {
        // Call the usecase to login with Google
        final authResult = await _loginUsecase.loginWithGoogle(
          result['access_token'],
          idToken: result['id_token'],
        );
        
        if (authResult != null) {
          _user = authResult.user;
          _token = authResult.accessToken;
          _isLoading = false;
          notifyListeners();
          return {'success': true};
        } else {
          _error = 'Failed to authenticate with Google';
          _isLoading = false;
          notifyListeners();
          return {'success': false, 'message': 'Google authentication failed'};
        }
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return result;
      }
    } catch (e) {
      _error = 'Google login error: ${e.toString()}';
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
      final result = await _loginUsecase.repository.verifyOTP(email, otp);
      
      if (result != null) {
        _isLoading = false;
        notifyListeners();
        return {'success': true};
      } else {
        _error = 'Failed to verify OTP';
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'Verification failed'};
      }
    } catch (e) {
      _error = 'Verification error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<Map<String, dynamic>> resendOTP(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _loginUsecase.repository.resendOTP(email);
      
      _isLoading = false;
      notifyListeners();
      
      if (success) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to resend OTP'};
      }
    } catch (e) {
      _error = 'Resend error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<bool> updateProfile(String fullName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual profile update
      // This is a placeholder implementation
      if (_user != null) {
        _user = _user!.copyWith(name: fullName);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}