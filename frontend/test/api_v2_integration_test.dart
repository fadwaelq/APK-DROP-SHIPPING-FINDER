import 'package:flutter_test/flutter_test.dart';
import 'package:dropshipping_app/services/api_service.dart';

void main() {
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
