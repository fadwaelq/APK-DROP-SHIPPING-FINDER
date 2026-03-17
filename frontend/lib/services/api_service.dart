import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Client HTTP utilisé pour les requêtes (permet le mocking dans les tests)
  http.Client client = http.Client();



  // Load API URL from environment variable with fallback
  String get baseUrl {
    try {
      return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
    } catch (_) {
      return 'http://localhost:8000/api';
    }
  }

  String? _authToken;

  void setAuthToken(String token) {
    print('🔑 ApiService.setAuthToken appelé avec: ${token.isNotEmpty ? token.substring(0, token.length > 15 ? 15 : token.length) + "..." : "VIDE"}');
    _authToken = token.isNotEmpty ? token : null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
    print('🌐 ApiService utilise Headers: ${headers.keys.toList()} | Token présent? ${_authToken != null}');
    return headers;
  }

  Map<String, String> get headers => _headers;

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password,
      {bool rememberMe = false}) async {
    // --- BYPASS MOCK POUR DÉVELOPPEMENT ---
    if (email.toLowerCase() == 'fadwa.elq1@gmail.com') {
      return {
        'success': true,
        'access': 'mock_access_token_for_fadwa',
        'refresh': 'mock_refresh_token_for_fadwa',
        'user': {
          'id': 1,
          'email': email,
          'full_name': 'Fadwa Elq',
        }
      };
    }
    // --------------------------------------

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/login/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'remember_me': rememberMe,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
      String fullName, String email, String password) async {
    try {
      // Générer un username à partir de l'email
      final username = email.split('@').first + '_' + DateTime.now().millisecondsSinceEpoch.toString().substring(8);

      final payload = {
        'username': username,
        'full_name': fullName,
        'email': email,
        'password': password,
        'password_confirm': password,
      };

      print('📤 REGISTER PAYLOAD: $payload');

      final response = await http.post(
        Uri.parse('$baseUrl/user/register/'),
        headers: {
          'Content-Type': 'application/json', // 🔥 IMPORTANT
        },
        body: jsonEncode(payload),
      );

      print('📥 REGISTER STATUS: ${response.statusCode}');
      print('📥 REGISTER BODY: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/verify-otp/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'otp_code': otp,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resendOTP(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/resend-otp/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/token/refresh/'),
        headers: _headers,
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/password-reset/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/password-reset-confirm/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
          'new_password_confirm': newPassword,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user/profile/'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile(String fullName) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/user/profile/'),
        headers: _headers,
        body: jsonEncode({'full_name': fullName}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Products
  Future<Map<String, dynamic>> getProducts(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/?page=$page'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getTrendingProducts() async {
    try {
      // Endpoint dédié si disponible
      final response = await client.get(
        Uri.parse('$baseUrl/products/trending/'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      // Fallback: ancienne logique "simulée" si /products/trending/ n'est pas déployé
      try {
        final response = await client.get(
          Uri.parse('$baseUrl/products/?is_winner=true&ordering=-trend_score'),
          headers: _headers,
        );
        return _handleResponse(response);
      } catch (e2) {
        return {'success': false, 'message': e2.toString()};
      }
    }
  }

  Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      // Correction du paramètre : ?search= au lieu de ?q=
      final response = await client.get(
        Uri.parse('$baseUrl/products/?search=$query'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/$id/'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getTopRatedProducts() async {
    try {
      // Utilise l'endpoint standard avec tri par profit potentiel
      final response = await client.get(
        Uri.parse('$baseUrl/products/?ordering=-potential_profit'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> analyzeProduct(String id) async {
    try {
      // Utilise les détails du produit (incluent déjà l'analyse)
      final response = await client.get(
        Uri.parse('$baseUrl/products/$id/'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCategoryTrends(String category) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/?category=$category'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/products/category-trends/ — tendances par catégorie (endpoint dédié)
  Future<Map<String, dynamic>> getCategoryTrendsV2() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/category-trends/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/products/history/ — historique (consultations / recherches / etc.)
  Future<Map<String, dynamic>> getProductsHistory() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/history/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/products/benchmark/products/ — liste benchmark
  Future<Map<String, dynamic>> getBenchmarkProducts() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/benchmark/products/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/products/benchmark/summary/ — résumé benchmark
  Future<Map<String, dynamic>> getBenchmarkSummary() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/benchmark/summary/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }



  // ─── NEW API INTEGRATIONS (Spy, Analytics, Scrapers) ───

  // Spy
  Future<Map<String, dynamic>> getAdsMonitoring() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/ads/monitoring/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Business Analytics
  Future<Map<String, dynamic>> calculateROI(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/analytics/calculator/roi/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getDashboardRecentActivity() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/analytics/dashboard/recent-activity/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/analytics/dashboard/stats/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Scraper Asynchrone
  Future<Map<String, dynamic>> bulkScrapePuppeteerAsync(List<String> urls) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/bulk-scrape-puppeteer/'),
        headers: _headers,
        body: jsonEncode({'urls': urls}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> scrapeProductAsync(String url) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/products/scrape/'),
        headers: _headers,
        body: jsonEncode({'url': url}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAsyncScrapeStatus(String taskId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/scrape-status/$taskId/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Scraper Synchrone
  Future<Map<String, dynamic>> bulkSearch(List<String> keywords) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/bulk-search/'),
        headers: _headers,
        body: jsonEncode({'keywords': keywords}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> search(String query) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/search/'),
        headers: _headers,
        body: jsonEncode({'query': query}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Phase 2: Community, Events, Products, Rewards ───

  // Community
  Future<Map<String, dynamic>> getCommunityPosts() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/community/posts/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createCommunityPost(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/community/posts/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> togglePostLike(String postId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/posts/$postId/like/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Events
  Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/events/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/events/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getEventById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/events/$id/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/events/$id/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> patchEvent(String id, Map<String, dynamic> data) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/events/$id/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteEvent(String id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/events/$id/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/events/$eventId/register/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Products (Additional)
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/products/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProductsFavorites() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/favorites/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> toggleProductFavorite(String productId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/products/favorites/'),
        headers: _headers,
        body: jsonEncode({'product': int.tryParse(productId) ?? productId}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteFromWatchlist(String id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/products/watchlist/$id/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Rewards
  Future<Map<String, dynamic>> getRewards() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/rewards/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Rewards & Missions
  Future<Map<String, dynamic>> getDailyMissions() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/missions/daily/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> completeMission(String missionId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/missions/complete/'),
        headers: _headers,
        body: jsonEncode({'mission_id': missionId}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUserXP() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user/xp/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getShopItems() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/shop/items/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> applyRewardCode(String code) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/rewards/apply-code/'),
        headers: _headers,
        body: jsonEncode({'code': code}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Phase 3: Subscriptions, Support, User (V2) ───



  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/subscriptions/plans/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Support
  Future<Map<String, dynamic>> getSupportTickets() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/support/tickets/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createSupportTicket(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/support/tickets/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> replyToSupportTicket(String ticketId, String message) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/support/tickets/$ticketId/reply/'),
        headers: _headers,
        body: jsonEncode({'message': message}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Economy & Wallet
  Future<Map<String, dynamic>> getCoinsBalance() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/economy/user/coins-balance/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCoinsHistory() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user/coins-history/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> earnCoins(String action, int amount) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/economy/user/coins/earn/'),
        headers: _headers,
        body: jsonEncode({'action': action, 'amount': amount}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> spendCoins(String reason, int amount) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/economy/user/coins/spend/'),
        headers: _headers,
        body: jsonEncode({'reason': reason, 'amount': amount}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // User (V2)
  Future<Map<String, dynamic>> getUserBadges() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user/badges/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> changePasswordV2(String oldPassword, String newPassword) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/user/change-password/'),
        headers: _headers,
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginWithGoogleV2(String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/google-login/'),
        headers: _headers,
        body: jsonEncode({'token': token}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginV2(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/login/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> logoutV2() async {
    try {
      // Récupérer le refresh token depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('auth_refresh_token') ?? '';

      final response = await client.post(
        Uri.parse('$baseUrl/user/logout/'),
        headers: _headers,
        body: jsonEncode({'refresh': refreshToken}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> requestPasswordResetV2(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/password-reset/'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> confirmPasswordResetV2(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/password-reset-confirm/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUserProfileV2() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user/profile/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUserAvatarV2() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user/profile/v2/avatar/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateUserProfileV2(Map<String, dynamic> data) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/user/profile/v2/update/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> patchUserProfileV2(Map<String, dynamic> data) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/user/profile/v2/update/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> registerV2(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/register/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> refreshTokenV2(String refreshToken) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/token/refresh/'),
        headers: _headers,
        body: jsonEncode({'refresh': refreshToken}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOtpV2(String email, String otp) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/verify-otp/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }





  // Favorites
  Future<Map<String, dynamic>> getFavorites() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/favorites/'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> toggleFavorite(String productId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/favorites/toggle/'),
        headers: _headers,
        body: jsonEncode({'product_id': productId}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Subscription & Checkout
  Future<Map<String, dynamic>> checkoutSubscription(String planId, String paymentMethod) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/subscriptions/checkout/'),
        headers: _headers,
        body: jsonEncode({
          'plan_id': planId,
          'payment_method': paymentMethod,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /api/economy/payments/checkout/ — Paiement économie direct
  Future<Map<String, dynamic>> checkoutEconomyPayment(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/economy/payments/checkout/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateSubscription(String planName) async {
    try {
      // Endpoint for updating an existing subscription
      final response = await client.post(
        Uri.parse('$baseUrl/subscriptions/update/'),
        headers: _headers,
        body: jsonEncode({'plan_name': planName}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Donations
  Future<Map<String, dynamic>> recordDonation(double amount, String provider) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/donations/record/'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'provider': provider,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  Future<Map<String, dynamic>> updateNotificationSettings(bool enabled) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/settings/notifications/'),
        headers: _headers,
        body: jsonEncode({'enabled': enabled}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Bloc 5 : Finances & Support ───

  // 5.1 Économie et Transactions

  /// POST /api/economy/user/coins/transfer/ — Transfert sécurisé P2P entre portefeuilles
  Future<Map<String, dynamic>> transferCoins({
    required String recipientUsername,
    required int amount,
    String? note,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/economy/user/coins/transfer/'),
        headers: _headers,
        body: jsonEncode({
          'recipient_username': recipientUsername,
          'amount': amount,
          if (note != null) 'note': note,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/economy/user/coins/transaction-log/ — Exportation historique (JSON & CSV)
  Future<Map<String, dynamic>> getCoinsTransactionLog({String format = 'json'}) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/economy/user/coins/transaction-log/?format=$format'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 5.2 Support Client

  /// GET /api/support/categories/ — Liste dynamique des types de requêtes
  Future<Map<String, dynamic>> getSupportCategories() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/support/categories/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /api/support/tickets/{id}/close/ — Clôture autonome des tickets
  Future<Map<String, dynamic>> closeTicket(String ticketId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/support/tickets/$ticketId/close/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Bloc 3 : Growth & Viralité (Parrainage) ───

  /// GET /api/user/referrals/ — Liste exhaustive des filleuls
  Future<Map<String, dynamic>> getReferrals() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user/referrals/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /api/user/referral-invite/ — Génération de codes uniques et liens profonds
  Future<Map<String, dynamic>> sendReferralInvite({String? email}) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/referral-invite/'),
        headers: _headers,
        body: jsonEncode(email != null ? {'email': email} : {}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/user/referral-leaderboard/ — Classement compétitif des parrains
  Future<Map<String, dynamic>> getReferralLeaderboard() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user/referral-leaderboard/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/user/referral/rewards/ — Consultation des paliers de gains
  Future<Map<String, dynamic>> getReferralRewards() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user/referral/rewards/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /api/user/referral/claim-reward/ — Activation des récompenses
  Future<Map<String, dynamic>> claimReferralReward(String rewardId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/user/referral/claim-reward/'),
        headers: _headers,
        body: jsonEncode({'reward_id': rewardId}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Bloc 4 : Analyse Produit Avancée ───

  /// GET /api/products/{id}/suppliers/ — Comparatif multi-fournisseurs
  Future<Map<String, dynamic>> getProductSuppliers(String productId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/$productId/suppliers/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/products/{id}/performance/ — Scores de rentabilité (0-100)
  Future<Map<String, dynamic>> getProductPerformance(String productId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/$productId/performance/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/products/{id}/reviews/ — Agrégation d'avis clients réels
  Future<Map<String, dynamic>> getProductReviews(String productId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/$productId/reviews/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /api/products/{id}/contact-supplier/ — Tunnel de communication proxy
  Future<Map<String, dynamic>> contactSupplier(
      String productId, Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/products/$productId/contact-supplier/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Helper method to handle responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        // Handle both list and map responses
        if (data is List) {
          return {'success': true, 'data': data};
        } else if (data is Map) {
          // Backend returns {success: true, message_code: ..., data: {...}}
          // We preserve the structure but ensure success is true
          if (data.containsKey('success')) {
            print(data.length);
            return Map<String, dynamic>.from(data);
          }
          return {'success': true, ...data};
        } else {
          return {'success': true, 'data': data};
        }
      } else {
        // Try to parse error as JSON
        try {
          final error = jsonDecode(response.body);
          // Backend returns {success: false, message_code: ..., errors: {...}}
          if (error is Map) {
            return {
              'success': false,
              'message_code': error['message_code'],
              'message': error['message'] ??
                  error['detail'] ??
                  error['message_code'] ??
                  'Request failed',
              'errors': error['errors'],
            };
          }
          return {
            'success': false,
            'message': error['message'] ?? error['detail'] ?? 'Request failed',
          };
        } catch (e) {
          // If response is not JSON (e.g., HTML error page)
          return {
            'success': false,
            'message':
                'Server error (${response.statusCode}): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: $e',
      };
    }
  }

  /// Google Sign-In
  Future<Map<String, dynamic>> loginWithGoogle(String accessToken,
      {String? idToken}) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/google/login/'),
        headers: _headers,
        body: jsonEncode({
          'access_token': accessToken,
          if (idToken != null) 'id_token': idToken,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Apple Sign-In (for future implementation)
  Future<Map<String, dynamic>> loginWithApple(String identityToken) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/apple/login/'),
        headers: _headers,
        body: jsonEncode({
          'id_token': identityToken,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Payment Methods
  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/subscriptions/payment-methods/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deletePaymentMethod(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/subscriptions/payment-methods/$id/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/subscriptions/payment-methods/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}