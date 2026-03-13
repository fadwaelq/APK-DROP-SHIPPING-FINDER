// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';
import '../models/user_model.dart';

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
    // Simulation frontend
    await Future.delayed(const Duration(milliseconds: 500));
    final namePart = email.split('@').first.split('.').first;
    final firstName = namePart[0].toUpperCase() + namePart.substring(1).toLowerCase();
    return AuthResult(
      success: true,
      user: UserModel(id: '1', firstName: firstName, lastName: '', email: email),
    );
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      // Use GoogleSignIn.instance and authenticate() for v7.2.0+
      final googleSignIn = GoogleSignIn.instance;
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      
      if (googleUser == null) {
        return const AuthResult(success: false, message: 'Connexion annulée');
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
    } catch (e) {
      // Fallback redirection web
      final Uri url = Uri.parse('https://accounts.google.com/signin');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return const AuthResult(success: true, message: 'Redirection vers Google lancée');
      }
      return AuthResult(success: false, message: 'Erreur Google Sign-In: $e');
    }
  }

  Future<AuthResult> register(String fullName, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const AuthResult(success: true, message: 'Inscription réussie');
  }

  Future<AuthResult> verifyOtp(String email, String otpCode) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const AuthResult(success: true, message: 'Compte vérifié');
  }

  Future<AuthResult> resendOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const AuthResult(success: true, message: 'Code renvoyé');
  }

  Future<AuthResult> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const AuthResult(success: true, message: 'Lien envoyé');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await GoogleSignIn.instance.signOut();
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
