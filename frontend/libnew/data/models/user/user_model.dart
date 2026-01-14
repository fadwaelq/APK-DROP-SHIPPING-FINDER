import '../../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final int? profitabilityScore;
  final String? subscriptionPlan;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.profitabilityScore,
    this.subscriptionPlan,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      profitabilityScore: json['profitability_score']?.toInt(),
      subscriptionPlan: json['subscription_plan'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'avatar': avatar,
      'profitability_score': profitabilityScore,
      'subscription_plan': subscriptionPlan,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      profitabilityScore: profitabilityScore,
      subscriptionPlan: subscriptionPlan,
      createdAt: createdAt,
    );
  }

  static UserModel fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatar: entity.avatar,
      profitabilityScore: entity.profitabilityScore,
      subscriptionPlan: entity.subscriptionPlan,
      createdAt: entity.createdAt,
    );
  }
}