import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dropshipping_app/services/api_service.dart';

void main() {
  group('Product API Tests (Mock)', () {
    late ApiService apiService;

    setUp(() async {
      // Mock environment variables
      dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost:8000/api');
      apiService = ApiService();
    });

    test('getTrendingProducts uses correct filters', () async {
      apiService.client = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.toString(), contains('/products/?is_winner=true&ordering=-trend_score'));
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final result = await apiService.getTrendingProducts();
      expect(result['success'], isTrue);
    });

    test('getTopRatedProducts uses correct ordering', () async {
      apiService.client = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.toString(), contains('/products/?ordering=-potential_profit'));
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final result = await apiService.getTopRatedProducts();
      expect(result['success'], isTrue);
    });

    test('searchProducts uses correct search param', () async {
      apiService.client = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.toString(), contains('/products/?search=iphone'));
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final result = await apiService.searchProducts('iphone');
      expect(result['success'], isTrue);
    });

    test('toggleProductFavorite uses correct key "product"', () async {
      apiService.client = MockClient((request) async {
        expect(request.method, equals('POST'));
        final body = jsonDecode(request.body);
        expect(body['product'], equals('123'));
        return http.Response(jsonEncode({'id': 1, 'product': '123'}), 201);
      });

      final result = await apiService.toggleProductFavorite('123');
      expect(result['success'], isTrue);
    });

    test('analyzeProduct uses detail endpoint', () async {
      apiService.client = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.toString(), endsWith('/products/123/'));
        return http.Response(jsonEncode({'id': '123', 'ai_analysis_summary': 'Good'}), 200);
      });

      final result = await apiService.analyzeProduct('123');
      expect(result['success'], isTrue);
    });
  });
}
