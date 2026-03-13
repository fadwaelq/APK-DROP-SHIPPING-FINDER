import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../domain/entities/user_entity.dart';

class UserProvider with ChangeNotifier {
  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual user profile loading
      // This is a placeholder implementation
    } catch (e) {
      _error = 'Failed to load user profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String fullName) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual profile update
      // This is a placeholder implementation
      if (_user != null) {
        _user = _user!.copyWith(name: fullName);
      }
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}