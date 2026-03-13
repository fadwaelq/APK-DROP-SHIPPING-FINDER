class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final int? profitabilityScore;
  final String? subscriptionPlan;
  final DateTime? createdAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.profitabilityScore,
    this.subscriptionPlan,
    this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    int? profitabilityScore,
    String? subscriptionPlan,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      profitabilityScore: profitabilityScore ?? this.profitabilityScore,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}