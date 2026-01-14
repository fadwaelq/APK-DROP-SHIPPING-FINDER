import 'user_entity.dart';

class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  AuthEntity copyWith({
    String? accessToken,
    String? refreshToken,
    UserEntity? user,
  }) {
    return AuthEntity(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}