import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserProfile();
  Future<UserEntity?> updateUserProfile(String fullName);
  Future<bool> updateNotificationSettings(bool enabled);
}