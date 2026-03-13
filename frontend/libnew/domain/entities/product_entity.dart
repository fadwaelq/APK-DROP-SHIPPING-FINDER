class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final double profit;
  final String imageUrl;
  final int score;
  final double trendPercentage;
  final String category;
  final List<String> availableColors;
  final ProductSource source;
  final Supplier supplier;
  final PerformanceMetrics performanceMetrics;
  final DateTime addedDate;
  final bool isFavorite;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.profit,
    required this.imageUrl,
    required this.score,
    required this.trendPercentage,
    required this.category,
    this.availableColors = const [],
    required this.source,
    required this.supplier,
    required this.performanceMetrics,
    required this.addedDate,
    this.isFavorite = false,
  });

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? profit,
    String? imageUrl,
    int? score,
    double? trendPercentage,
    String? category,
    List<String>? availableColors,
    ProductSource? source,
    Supplier? supplier,
    PerformanceMetrics? performanceMetrics,
    DateTime? addedDate,
    bool? isFavorite,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      profit: profit ?? this.profit,
      imageUrl: imageUrl ?? this.imageUrl,
      score: score ?? this.score,
      trendPercentage: trendPercentage ?? this.trendPercentage,
      category: category ?? this.category,
      availableColors: availableColors ?? this.availableColors,
      source: source ?? this.source,
      supplier: supplier ?? this.supplier,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      addedDate: addedDate ?? this.addedDate,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get daysAgoText {
    final difference = DateTime.now().difference(addedDate);
    if (difference.inDays == 0) return "Aujourd'hui";
    if (difference.inDays == 1) return "Il y a 1 jour";
    return "Il y a ${difference.inDays} jours";
  }
}

enum ProductSource {
  aliexpress,
  amazon,
  shopify;

  static ProductSource fromString(String value) {
    switch (value.toLowerCase()) {
      case 'amazon':
        return ProductSource.amazon;
      case 'shopify':
        return ProductSource.shopify;
      default:
        return ProductSource.aliexpress;
    }
  }

  String get displayName {
    switch (this) {
      case ProductSource.aliexpress:
        return 'AliExpress';
      case ProductSource.amazon:
        return 'Amazon';
      case ProductSource.shopify:
        return 'Shopify';
    }
  }
}

class Supplier {
  final String name;
  final double rating;
  final int reviewCount;

  Supplier({
    required this.name,
    required this.rating,
    required this.reviewCount,
  });

  Supplier copyWith({
    String? name,
    double? rating,
    int? reviewCount,
  }) {
    return Supplier(
      name: name ?? this.name,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  factory Supplier.empty() {
    return Supplier(
      name: 'Unknown',
      rating: 0.0,
      reviewCount: 0,
    );
  }
}

class PerformanceMetrics {
  final int demandLevel;
  final int popularity;
  final int competition;
  final int profitability;

  PerformanceMetrics({
    required this.demandLevel,
    required this.popularity,
    required this.competition,
    required this.profitability,
  });

  PerformanceMetrics copyWith({
    int? demandLevel,
    int? popularity,
    int? competition,
    int? profitability,
  }) {
    return PerformanceMetrics(
      demandLevel: demandLevel ?? this.demandLevel,
      popularity: popularity ?? this.popularity,
      competition: competition ?? this.competition,
      profitability: profitability ?? this.profitability,
    );
  }

  factory PerformanceMetrics.empty() {
    return PerformanceMetrics(
      demandLevel: 0,
      popularity: 0,
      competition: 0,
      profitability: 0,
    );
  }
}

class ProductCategory {
  static const String all = 'Tout';
  static const String tech = 'Tech';
  static const String sport = 'Sport';
  static const String home = 'Maison';
  static const String fashion = 'Mode';
  static const String beauty = 'Beauté';
  static const String toys = 'Jouets';
  static const String health = 'Santé';

  static List<String> get allCategories => [
        all,
        tech,
        sport,
        home,
        fashion,
        beauty,
        toys,
        health,
      ];
  
  // Mapping French display names to backend category keys
  static String toBackendKey(String displayName) {
    switch (displayName) {
      case 'Tech':
        return 'tech';
      case 'Sport':
        return 'sport';
      case 'Maison':
        return 'home';
      case 'Mode':
        return 'fashion';
      case 'Beauté':
        return 'beauty';
      case 'Jouets':
        return 'toys';
      case 'Santé':
        return 'health';
      default:
        return displayName.toLowerCase();
    }
  }
}