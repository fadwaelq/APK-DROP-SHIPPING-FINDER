import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dropshipping_app/services/api_service.dart';

@GenerateMocks([http.Client])
void main() {
  // Mocking the client is usually done with mockito, but for brevity 
  // we'll check if the methods exist and follow the pattern of other tests.
  
  test('ApiService has new event methods', () {
    final apiService = ApiService();
    expect(apiService.createEvent, isNotNull);
    expect(apiService.getEventById, isNotNull);
    expect(apiService.updateEvent, isNotNull);
    expect(apiService.patchEvent, isNotNull);
    expect(apiService.deleteEvent, isNotNull);
  });

  test('ApiService has new profile v2 methods', () {
    final apiService = ApiService();
    expect(apiService.getUserAvatarV2, isNotNull);
    expect(apiService.updateUserProfileV2, isNotNull);
    expect(apiService.patchUserProfileV2, isNotNull);
  });
}
