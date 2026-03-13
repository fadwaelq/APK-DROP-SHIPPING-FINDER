
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../datasources/local/auth_local_data_source.dart';
import '../models/auth/auth_model.dart';
import '../models/user/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthEntity?> login(String email, String password) async {
    try {
      final result = await remoteDataSource.login(email, password);
      if (result != null) {
        final authModel = AuthModel.fromJson(result);
        await localDataSource.cacheAuth(authModel);
        return authModel.toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  @override
  Future<AuthEntity?> register(String fullName, String email, String password) async {
    try {
      final result = await remoteDataSource.register(fullName, email, password);
      if (result != null) {
        final authModel = AuthModel.fromJson(result);
        await localDataSource.cacheAuth(authModel);
        return authModel.toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await localDataSource.clearAuth();
      return true;
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  @override
  Future<AuthEntity?> verifyOTP(String email, String otp) async {
    try {
      final result = await remoteDataSource.verifyOTP(email, otp);
      if (result != null) {
        final authModel = AuthModel.fromJson(result);
        await localDataSource.cacheAuth(authModel);
        return authModel.toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<bool> resendOTP(String email) async {
    try {
      return await remoteDataSource.resendOTP(email);
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    try {
      return await remoteDataSource.requestPasswordReset(email);
    } catch (e) {
      throw Exception('Failed to request password reset: $e');
    }
  }

  @override
  Future<bool> confirmPasswordReset(String email, String otp, String newPassword) async {
    try {
      return await remoteDataSource.confirmPasswordReset(email, otp, newPassword);
    } catch (e) {
      throw Exception('Failed to confirm password reset: $e');
    }
  }

  @override
  Future<AuthEntity?> loginWithGoogle(String accessToken, {String? idToken}) async {
    try {
      final result = await remoteDataSource.loginWithGoogle(accessToken, idToken: idToken);
      if (result != null) {
        final authModel = AuthModel.fromJson(result);
        await localDataSource.cacheAuth(authModel);
        return authModel.toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to login with Google: $e');
    }
  }

  @override
  Future<UserEntity?> updateProfile(String fullName) async {
    try {
      final result = await remoteDataSource.updateProfile(fullName);
      if (result != null) {
        final userModel = UserModel.fromJson(result);
        // Update cached user data
        final cachedAuth = await localDataSource.getCachedAuth();
        if (cachedAuth != null) {
          final updatedAuth = cachedAuth.copyWith(user: userModel);
          await localDataSource.cacheAuth(updatedAuth);
        }
        return userModel.toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<UserEntity?> getUserProfile() async {
    try {
      final result = await remoteDataSource.getUserProfile();
      if (result != null) {
        final userModel = UserModel.fromJson(result);
        return userModel.toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
}