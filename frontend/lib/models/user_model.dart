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

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.token,
  });

  /// Crée un UserModel à partir d'une réponse JSON du backend.
  /// TODO ─ Équipe Backend: adapter les clés JSON selon votre API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? json['access_token'],
    );
  }

  /// Convertit le modèle en JSON (pour l'envoi vers le backend).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
  }
}
