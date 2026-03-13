// ============================================================
// lib/services/api_config.dart
//
// Configuration centrale de l'API.
// TODO ─ Équipe Backend: remplacez BASE_URL par l'URL de votre serveur.
// ============================================================

class ApiConfig {
  // ─── TODO ─ Équipe Backend : Modifier ici l'URL de base ───
  static const String baseUrl = 'https://api.dropshippingfinder.com/v1';
  // static const String baseUrl = 'http://127.0.0.1:8000/api'; // dev local

  // Endpoints d'authentification
  static const String loginEndpoint      = '$baseUrl/auth/login';
  static const String registerEndpoint   = '$baseUrl/auth/register';
  static const String verifyOtpEndpoint  = '$baseUrl/auth/verify-otp';
  static const String resendOtpEndpoint  = '$baseUrl/auth/resend-otp';
  static const String forgotPassword     = '$baseUrl/auth/forgot-password';
  static const String resetPassword      = '$baseUrl/auth/reset-password';

  // Endpoints produits (pour usage futur)
  static const String productsEndpoint   = '$baseUrl/products';
  static const String trendingEndpoint   = '$baseUrl/products/trending';
  static const String alertsEndpoint     = '$baseUrl/alerts';

  // Headers communs
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
