import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dropshipping_app/services/api_service.dart';

void main() {
  group('Tests Intégration API (Mock) - Couverture Totale', () {
    late ApiService apiService;

    setUp(() async {
      dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost:8000/api');
      apiService = ApiService();
    });

    // ─── SPY & ANALYTICS ───
    test('Spy & Analytics', () async {
      apiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });
      expect((await apiService.getAdsMonitoring())['success'], true);
      expect((await apiService.getDashboardStats())['success'], true);
      expect((await apiService.getDashboardRecentActivity())['success'], true);
      expect((await apiService.calculateROI({'inv': 100}))['success'], true);
    });

    // ─── RECHERCHE & SCRAPERS ───
    test('Recherche & Scrapers', () async {
      apiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });
      expect((await apiService.search('test'))['success'], true);
      expect((await apiService.bulkSearch(['a', 'b']))['success'], true);
      expect((await apiService.scrapeProductAsync('url'))['success'], true);
      expect((await apiService.getAsyncScrapeStatus('id'))['success'], true);
      expect((await apiService.getCategoryTrends('cat'))['success'], true);
    });

    // ─── UTILISATEUR V2 ───
    test('Utilisateur V2 & Auth', () async {
      apiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });
      expect((await apiService.loginV2('e', 'p'))['success'], true);
      expect((await apiService.getUserProfileV2())['success'], true);
      expect((await apiService.getUserBadges())['success'], true);
      expect((await apiService.refreshTokenV2('token'))['success'], true);
    });

    // ─── COMMUNAUTÉ & ÉVÉNEMENTS ───
    test('Communauté & Événements', () async {
      apiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });
      expect((await apiService.getCommunityPosts())['success'], true);
      expect((await apiService.getEvents())['success'], true);
      expect((await apiService.registerForEvent('id'))['success'], true);
    });

    // ─── RÉCOMPENSES & SUBSCRIPTIONS ───
    test('Récompenses & Abonnements', () async {
      apiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });
      expect((await apiService.getRewards())['success'], true);
      expect((await apiService.getSubscriptionPlans())['success'], true);
      expect((await apiService.checkoutSubscription({}))['success'], true);
    });

    // ─── PRODUITS & FAVORIS ───
    test('Produits & Favoris', () async {
      apiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });
      expect((await apiService.getProducts())['success'], true);
      expect((await apiService.getTrendingProducts())['success'], true);
      expect((await apiService.getProductsFavorites())['success'], true);
      expect((await apiService.toggleProductFavorite('id'))['success'], true);
    });

    // ─── SUPPORT ───
    test('Support Client', () async {
      apiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });
      expect((await apiService.getSupportTickets())['success'], true);
      expect((await apiService.createSupportTicket({}))['success'], true);
    });
  });
}
