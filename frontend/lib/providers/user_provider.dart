import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  void setUser(User? user) {
    // Skip if no real change
    if (_user?.id == user?.id && identical(_user, user)) {
      return;
    }
    
    _user = user;
    
    // Don't notify listeners here - let the proxy provider handle it
    // The ChangeNotifierProxyProvider will automatically notify listeners
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getUserProfile();
     
      if (response['success']) {
        _user = User.fromJson(response['user']);
      } else {
        _error = response['message'] ?? 'Failed to load profile';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(String fullName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.updateProfile(fullName);
      if (response['success']) {
        final userData = response['data']['user'];
        _user = User.fromJson(userData);
      } else {
        _error = response['message'] ?? 'Failed to update profile';
        throw Exception(_error);
      }
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateSubscription(SubscriptionPlan plan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.updateSubscription(plan.name);
     
      if (response['success'] && _user != null) {
        _user = _user!.copyWith(
          subscriptionPlan: plan,
          subscriptionExpiryDate: DateTime.now().add(const Duration(days: 30)),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update subscription';
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

  Future<void> toggleNotifications(bool enabled) async {
    if (_user == null) return;

    // Optimistic update
    _user = _user!.copyWith(notificationsEnabled: enabled);
    notifyListeners();

    try {
      final response = await _apiService.updateNotificationSettings(enabled);
     
      if (!response['success']) {
        // Revert on failure
        _user = _user!.copyWith(notificationsEnabled: !enabled);
        notifyListeners();
      }
    } catch (e) {
      // Revert on error
      _user = _user!.copyWith(notificationsEnabled: !enabled);
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}