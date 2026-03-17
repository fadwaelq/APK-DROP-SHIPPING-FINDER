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
      expect((await apiService.checkoutSubscription('plan_1', 'card'))['success'], true);
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

    // ─── BLOC 3 : GROWTH & VIRALITÉ (PARRAINAGE) ───
    test('Bloc 3 — Referral APIs', () async {
      apiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true, 'data': []}), 200);
      });
      expect((await apiService.getReferrals())['success'], true);
      expect((await apiService.sendReferralInvite(email: 'friend@example.com'))['success'], true);
      expect((await apiService.getReferralLeaderboard())['success'], true);
      expect((await apiService.getReferralRewards())['success'], true);
      expect((await apiService.claimReferralReward('reward_1'))['success'], true);
    });

    // ─── BLOC 4 : ANALYSE PRODUIT AVANCÉE ───
    test('Bloc 4 — Advanced Product APIs', () async {
      apiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true, 'data': []}), 200);
      });
      expect((await apiService.getProductSuppliers('42'))['success'], true);
      expect((await apiService.getProductPerformance('42'))['success'], true);
      expect((await apiService.getProductReviews('42'))['success'], true);
      expect((await apiService.contactSupplier('42', {'message': 'Bonjour'}))['success'], true);
    });

    // ─── BLOC 5 : FINANCES & SUPPORT ───
    test('Bloc 5 — Finance & Support APIs (Economy V2)', () async {
      late String lastPath;
      apiService.client = MockClient((request) async {
        lastPath = request.url.path;
        return http.Response(jsonEncode({'success': true, 'data': []}), 200);
      });
      
      // Economy / Finance
      await apiService.getCoinsBalance();
      expect(lastPath, contains('/api/economy/user/coins-balance/'));

      await apiService.transferCoins(recipientUsername: 'user1', amount: 100);
      expect(lastPath, contains('/api/economy/user/coins/transfer/'));

      await apiService.getCoinsTransactionLog();
      expect(lastPath, contains('/api/economy/user/coins/transaction-log/'));

      await apiService.earnCoins('daily', 10);
      expect(lastPath, contains('/api/economy/user/coins/earn/'));

      await apiService.spendCoins('shop', 50);
      expect(lastPath, contains('/api/economy/user/coins/spend/'));

      await apiService.checkoutEconomyPayment({'plan': 'pro'});
      expect(lastPath, contains('/api/economy/payments/checkout/'));
      
      // Support
      await apiService.getSupportCategories();
      expect(lastPath, contains('/api/support/categories/'));

      await apiService.closeTicket('ticket_123');
      expect(lastPath, contains('/api/support/tickets/ticket_123/close/'));
    });
  });
}
