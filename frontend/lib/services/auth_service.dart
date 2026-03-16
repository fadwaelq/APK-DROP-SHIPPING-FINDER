// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthResult {
  final bool success;
  final String? message;
  final UserModel? user;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
  });
}

class AuthService {
  
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await ApiService().login(email, password);
      if (response['success'] == true && response['access'] != null) {
        final accessToken = response['access'];
        final refreshToken = response['refresh'];
        
        await _saveToken(accessToken);
        ApiService().setAuthToken(accessToken);
        
        final prefs = await SharedPreferences.getInstance();
        if (refreshToken != null) {
          await prefs.setString('auth_refresh_token', refreshToken);
        }
        
        // Fetch user profile to get real data
        final profileResponse = await ApiService().getUserProfile();
        String firstName = email.split('@').first;
        String lastName = '';
        String id = '';
        
        if (profileResponse['success'] == true) {
          id = profileResponse['id']?.toString() ?? '';
          if (profileResponse['full_name'] != null && profileResponse['full_name'].toString().isNotEmpty) {
              firstName = profileResponse['full_name'];
          } else {
              firstName = profileResponse['first_name'] ?? firstName;
              lastName = profileResponse['last_name'] ?? lastName;
          }
        }

        return AuthResult(
          success: true,
          user: UserModel(id: id.isNotEmpty ? id : '1', firstName: firstName, lastName: lastName, email: email),
        );
      }
      return AuthResult(success: false, message: response['message'] ?? 'Erreur de connexion');
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      
      if (googleUser == null) {
        return const AuthResult(success: false, message: 'Connexion annulée');
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? token = googleAuth.idToken;
      
      if (token == null) {
         return const AuthResult(success: false, message: 'Impossible d\'obtenir le token Google');
      }

      final response = await ApiService().loginWithGoogleV2(token);
      if (response['success'] == true && response['access'] != null) {
        final accessToken = response['access'];
        final refreshToken = response['refresh'];
        
        await _saveToken(accessToken);
        ApiService().setAuthToken(accessToken);
        
        final prefs = await SharedPreferences.getInstance();
        if (refreshToken != null) {
          await prefs.setString('auth_refresh_token', refreshToken);
        }

        return AuthResult(
          success: true,
          user: UserModel(
            id: googleUser.id,
            firstName: googleUser.displayName ?? 'Utilisateur',
            lastName: '',
            email: googleUser.email,
          ),
        );
      }
      return AuthResult(success: false, message: response['message'] ?? 'Erreur connexion Google avec le backend');
    } catch (e) {
      final Uri url = Uri.parse('https://accounts.google.com/signin');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return const AuthResult(success: true, message: 'Redirection vers Google lancée');
      }
      return AuthResult(success: false, message: 'Erreur Google Sign-In: $e');
    }
  }

  Future<AuthResult> register(String fullName, String email, String password) async {
    try {
      final response = await ApiService().register(fullName, email, password);
      if (response['success'] == true) {
         return const AuthResult(success: true, message: 'Inscription réussie');
      }
      return AuthResult(success: false, message: response['message'] ?? 'Erreur lors de l\'inscription');
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  Future<AuthResult> verifyOtp(String email, String otpCode) async {
    try {
      final response = await ApiService().verifyOTP(email, otpCode);
      if (response['success'] == true) {
         // Si l'API renvoie des tokens dès la vérification de l'OTP, on les sauvegarde
         if (response['tokens'] != null && response['tokens']['access'] != null) {
            final tokens = response['tokens'];
            await _saveToken(tokens['access']);
            ApiService().setAuthToken(tokens['access']);
            
            final prefs = await SharedPreferences.getInstance();
            if (tokens['refresh'] != null) {
              await prefs.setString('auth_refresh_token', tokens['refresh']);
            }
         }
         return const AuthResult(success: true, message: 'Compte vérifié');
      }
      return AuthResult(success: false, message: response['message'] ?? 'Code incorrect');
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  Future<AuthResult> resendOtp(String email) async {
    try {
      final response = await ApiService().resendOTP(email);
      if (response['success'] == true) {
         return const AuthResult(success: true, message: 'Code renvoyé');
      }
      return AuthResult(success: false, message: response['message'] ?? 'Erreur lors du renvoi');
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await ApiService().requestPasswordReset(email);
      if (response['success'] == true) {
         return const AuthResult(success: true, message: 'Lien envoyé');
      }
      return AuthResult(success: false, message: response['message'] ?? 'Erreur lors de la demande');
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  Future<void> logout() async {
    try {
       await ApiService().logoutV2();
    } catch(_) {}
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_refresh_token');
    ApiService().setAuthToken('');
    
    try {
      await GoogleSignIn.instance.signOut();
    } catch(_) {}
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
