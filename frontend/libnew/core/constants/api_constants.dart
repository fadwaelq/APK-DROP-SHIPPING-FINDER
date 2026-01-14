import '../config/app_config.dart';

class ApiConstants {
  static String get baseUrl => AppConfig.baseUrl;
  
  static String getToken() {
    // This will be implemented to get the token from secure storage
    return '';
  }
  
  // Auth endpoints
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String verifyOtp = '/auth/verify-otp/';
  static const String resendOtp = '/auth/resend-otp/';
  static const String requestPasswordReset = '/auth/password-reset/request/';
  static const String confirmPasswordReset = '/auth/password-reset/confirm/';
  static const String googleLogin = '/auth/google/login/';
  static const String appleLogin = '/auth/apple/login/';
  static const String userProfile = '/auth/profile/';
  static const String updateProfile = '/auth/profile/';
  
  // Product endpoints
  static const String products = '/products/';
  static const String trendingProducts = '/products/trending/';
  static const String searchProducts = '/products/search/';
  static const String productDetail = '/products/';
  
  // Favorites endpoints
  static const String favorites = '/favorites/';
  static const String toggleFavorite = '/favorites/toggle/';
  
  // Subscription endpoints
  static const String updateSubscription = '/subscription/update/';
  
  // Settings endpoints
  static const String notificationSettings = '/settings/notifications/';
}