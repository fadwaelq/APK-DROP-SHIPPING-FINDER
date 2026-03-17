import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dropshipping_app/services/api_service.dart';

void main() {
  group('Profile API Tests (Mock)', () {
    late ApiService apiService;

    setUp(() async {
      // Mock environment variables
      dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost:8000/api');
      apiService = ApiService();
      apiService.setAuthToken('mock_token');
    });

    test('getUserProfile returns user data on success', () async {
      final mockResponse = {
        'id': 1,
        'email': 'test@example.com',
        'username': 'testuser',
        'first_name': 'Test',
        'last_name': 'User',
        'is_email_verified': true,
      };

      apiService.client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/user/profile/');
        expect(request.headers['Authorization'], 'Bearer mock_token');
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final result = await apiService.getUserProfile();

      expect(result['success'], true);
      expect(result['email'], 'test@example.com');
      expect(result['username'], 'testuser');
    });

    test('updateProfile sends PATCH request with data', () async {
      final mockResponse = {
        'id': 1,
        'first_name': 'New Name',
      };

      apiService.client = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/user/profile/');
        final body = jsonDecode(request.body);
        expect(body['full_name'], 'New Name');
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final result = await apiService.updateProfile('New Name');

      expect(result['success'], true);
      expect(result['first_name'], 'New Name');
    });

    test('getUserBadges returns list of badges', () async {
      final mockResponse = [
        {'id': 1, 'name': 'Pioneer', 'description': 'First user', 'icon_url': 'http://link'}
      ];

      apiService.client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/user/badges/');
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final result = await apiService.getUserBadges();

      expect(result['success'], true);
      expect(result['data'], isA<List>());
      expect(result['data'][0]['name'], 'Pioneer');
    });

    test('changePasswordV2 sends PUT request', () async {
      apiService.client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/api/user/change-password/');
        final body = jsonDecode(request.body);
        expect(body['old_password'], 'old123');
        expect(body['new_password'], 'new123');
        return http.Response(jsonEncode({'detail': 'success'}), 200);
      });

      final result = await apiService.changePasswordV2('old123', 'new123');

      expect(result['success'], true);
    });
  });
}
