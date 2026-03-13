import '../../../domain/entities/auth_entity.dart';
import '../user/user_model.dart';

class AuthModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
      'user': user.toJson(),
    };
  }

  AuthModel copyWith({
    String? accessToken,
    String? refreshToken,
    UserModel? user,
  }) {
    return AuthModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user.toEntity(),
    );
  }

  static AuthModel fromEntity(AuthEntity entity) {
    return AuthModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      user: UserModel.fromEntity(entity.user),
    );
  }
}