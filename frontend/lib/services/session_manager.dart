import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';
import '../services/api_service.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  UserModel? _user;
  String? _token;

  UserModel? get user => _user;
  String? get token => _token;

  Future<void> setUser(UserModel? user, {String? token, String? refreshToken}) async {
    _user = user;
    if (token != null) {
      _token = token;
    }
    
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString('current_user', jsonEncode(user.toJson()));
      if (_token != null) {
        await prefs.setString('auth_token', _token!);
        ApiService().setAuthToken(_token!);
      }
      if (refreshToken != null) {
        await prefs.setString('auth_refresh_token', refreshToken);
      }
    } else {
      await prefs.remove('current_user');
      await prefs.remove('auth_token');
      await prefs.remove('auth_refresh_token');
      _token = null;
      ApiService().setAuthToken('');
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateUserField({
    String? firstName,
    String? lastName,
    String? email,
    String? profilePicture,
  }) async {
    if (_user != null) {
      // 1. Appeler le backend si le nom change
      if (firstName != null && firstName != _user!.firstName) {
        final result = await ApiService().updateProfile(firstName);
        if (result['success'] == false) {
          return result; // Retourner l'erreur pour affichage dans l'UI
        }
      }

      // 2. Mettre à jour l'état local après succès API
      final updatedUser = _user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        profilePicture: profilePicture,
      );
      await setUser(updatedUser);
      return {'success': true};
    }
    return {'success': false, 'message': 'Pas d\'utilisateur connecté'};
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    final savedToken = prefs.getString('auth_token');

    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
      if (savedToken != null) {
        _token = savedToken;
        ApiService().setAuthToken(savedToken);
      }
      notifyListeners();
    }
  }

  bool get isLoggedIn => _user != null;
}
