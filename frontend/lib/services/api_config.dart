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

  // Spy
  static const String adsMonitoringEndpoint = '$baseUrl/ads/monitoring/';

  // Business Analytics
  static const String analyticsRoiCalculatorEndpoint = '$baseUrl/analytics/calculator/roi/';

  // Analytics
  static const String analyticsDashboardRecentActivityEndpoint = '$baseUrl/analytics/dashboard/recent-activity/';

  // Dashboard
  static const String analyticsDashboardStatsEndpoint = '$baseUrl/analytics/dashboard/stats/';

  // Scraper Asynchrone
  static const String bulkScrapePuppeteerEndpoint = '$baseUrl/bulk-scrape-puppeteer/';
  static const String productsScrapeEndpoint = '$baseUrl/products/scrape/';
  static const String scrapeStatusEndpoint = '$baseUrl/scrape-status/';

  // Scraper Synchrone
  static const String bulkSearchEndpoint = '$baseUrl/bulk-search/';
  static const String searchEndpoint = '$baseUrl/search/';

  // Community
  static const String communityPostsEndpoint = '$baseUrl/community/posts/';

  // Events
  static const String eventsEndpoint = '$baseUrl/events/';
  static const String eventRegisterEndpoint = '$baseUrl/events/'; // Will append {id}/register/ in service

  // Products (Extra)
  static const String productsFavoritesEndpoint = '$baseUrl/products/favorites/';
  static const String productsWatchlistEndpoint = '$baseUrl/products/watchlist/';

  // Rewards
  static const String rewardsEndpoint = '$baseUrl/rewards/';
  static const String rewardsApplyCodeEndpoint = '$baseUrl/rewards/apply-code/';

  // Subscriptions
  static const String subsCheckoutEndpoint = '$baseUrl/subscriptions/checkout/';
  static const String subsPlansEndpoint = '$baseUrl/subscriptions/plans/';

  // Support
  static const String supportTicketsEndpoint = '$baseUrl/support/tickets/';

  // User (V2)
  static const String userBadgesEndpoint = '$baseUrl/user/badges/';
  static const String userChangePasswordEndpoint = '$baseUrl/user/change-password/';
  static const String userGoogleLoginEndpoint = '$baseUrl/user/google-login/';
  static const String userLoginEndpoint = '$baseUrl/user/login/';
  static const String userLogoutEndpoint = '$baseUrl/user/logout/';
  static const String userPasswordResetEndpoint = '$baseUrl/user/password-reset/';
  static const String userPasswordResetConfirmEndpoint = '$baseUrl/user/password-reset-confirm/';
  static const String userProfileEndpoint = '$baseUrl/user/profile/';
  static const String userRegisterEndpoint = '$baseUrl/user/register/';
  static const String userTokenRefreshEndpoint = '$baseUrl/user/token/refresh/';
  static const String userVerifyOtpEndpoint = '$baseUrl/user/verify-otp/';

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
