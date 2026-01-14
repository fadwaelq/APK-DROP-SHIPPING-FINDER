import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity?> login(String email, String password);
  Future<AuthEntity?> register(String fullName, String email, String password);
  Future<bool> logout();
  Future<AuthEntity?> verifyOTP(String email, String otp);
  Future<bool> resendOTP(String email);
  Future<bool> requestPasswordReset(String email);
  Future<bool> confirmPasswordReset(String email, String otp, String newPassword);
  Future<AuthEntity?> loginWithGoogle(String accessToken, {String? idToken});
  Future<UserEntity?> updateProfile(String fullName);
  Future<UserEntity?> getUserProfile();
}