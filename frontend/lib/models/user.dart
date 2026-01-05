class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final SubscriptionPlan subscriptionPlan;
  final DateTime? subscriptionExpiryDate;
  final int favoriteCount;
  final int viewCount;
  final int profitabilityScore;
  final bool notificationsEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.subscriptionPlan,
    this.subscriptionExpiryDate,
    this.favoriteCount = 0,
    this.viewCount = 0,
    this.profitabilityScore = 0,
    this.notificationsEnabled = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['full_name'] ?? json['username'] ?? json['name'] ?? json['first_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar'],
      subscriptionPlan: SubscriptionPlan.fromString(json['subscription_plan'] ?? 'free'),
      subscriptionExpiryDate: json['subscription_expiry_date'] != null
          ? DateTime.parse(json['subscription_expiry_date'])
          : null,
      favoriteCount: json['favorite_count'] ?? 0,
      viewCount: json['view_count'] ?? 0,
      profitabilityScore: json['profitability_score'] ?? 0,
      notificationsEnabled: json['notifications_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'subscription_plan': subscriptionPlan.name,
      'subscription_expiry_date': subscriptionExpiryDate?.toIso8601String(),
      'favorite_count': favoriteCount,
      'view_count': viewCount,
      'profitability_score': profitabilityScore,
      'notifications_enabled': notificationsEnabled,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    SubscriptionPlan? subscriptionPlan,
    DateTime? subscriptionExpiryDate,
    int? favoriteCount,
    int? viewCount,
    int? profitabilityScore,
    bool? notificationsEnabled,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      viewCount: viewCount ?? this.viewCount,
      profitabilityScore: profitabilityScore ?? this.profitabilityScore,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

enum SubscriptionPlan {
  free,
  starter,
  pro,
  premium;

  static SubscriptionPlan fromString(String value) {
    switch (value.toLowerCase()) {
      case 'starter':
        return SubscriptionPlan.starter;
      case 'pro':
        return SubscriptionPlan.pro;
      case 'premium':
        return SubscriptionPlan.premium;
      default:
        return SubscriptionPlan.free;
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.starter:
        return 'Starter';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.premium:
        return 'Premium';
    }
  }

  String get price {
    switch (this) {
      case SubscriptionPlan.free:
        return '0';
      case SubscriptionPlan.starter:
        return '99';
      case SubscriptionPlan.pro:
        return '249';
      case SubscriptionPlan.premium:
        return '499';
    }
  }

  List<String> get features {
    switch (this) {
      case SubscriptionPlan.free:
        return [
          '10 recherches par mois',
          'Analyse de base',
          '2 favoris',
          'Historique 3 jours',
        ];
      case SubscriptionPlan.starter:
        return [
          '100 recherches par mois',
          'Analyse de base',
          '5 favoris',
          'Support email',
          'Historique 7 jours',
        ];
      case SubscriptionPlan.pro:
        return [
          'Recherches illimitées',
          'Analyse avancée',
          'Favoris illimités',
          'Support prioritaire',
          'Historique 30 jours',
          'Export détaillés',
          'Alertes tendances',
        ];
      case SubscriptionPlan.premium:
        return [
          'Tout du plan Pro',
          'Analyse IA complète',
          'API access',
          'Support 24/7',
          'Historique illimité',
          'Alertes avancées',
          'Calculateur data',
          'Sales marketing',
        ];
    }
  }
}
