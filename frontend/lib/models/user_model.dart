// ============================================================
// lib/models/user_model.dart
// 
// Modèle de données utilisateur.
// L'équipe backend doit adapter les champs selon
// la structure renvoyée par leur API REST.
// ============================================================

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? token; // JWT ou autre token d'authentification
  final String? profilePicture;
  final String? avatarUrl;
  final int coins;
  final int xp;
  final int level;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.token,
    this.profilePicture,
    this.avatarUrl,
    this.coins = 0,
    this.xp = 0,
    this.level = 1,
  });

  /// Crée un UserModel à partir d'une réponse JSON du backend.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? json['access_token'],
      profilePicture: json['profile_picture'] ?? json['profilePicture'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      coins: json['coins'] ?? 0,
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
    );
  }

  /// Convertit le modèle en JSON (pour l'envoi vers le backend).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'profile_picture': profilePicture,
      'avatar_url': avatarUrl,
      'coins': coins,
      'xp': xp,
      'level': level,
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? token,
    String? profilePicture,
    String? avatarUrl,
    int? coins,
    int? xp,
    int? level,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      token: token ?? this.token,
      profilePicture: profilePicture ?? this.profilePicture,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
