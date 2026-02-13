class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double profit;
  final double cost;
  final String imageUrl;
  final List<String> images;
  final int score;
  final double trendPercentage;
  final bool isTrending;
  final String category;
  final List<String> availableColors;
  final ProductSource source;
  final String sourceUrl;
  final Supplier supplier;
  final PerformanceMetrics performanceMetrics;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.profit,
    required this.cost,
    required this.imageUrl,
    required this.images,
    required this.score,
    required this.trendPercentage,
    required this.isTrending,
    required this.category,
    this.availableColors = const [],
    required this.source,
    required this.sourceUrl,
    required this.supplier,
    required this.performanceMetrics,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';

    // Supplier fallback intelligent
    Supplier supplier;
    if (json['supplier'] != null) {
      supplier = Supplier.fromJson(json['supplier']);
    } else {
      supplier = Supplier(
        name: json['supplier_name'] ?? '',
        rating: _parseDouble(json['supplier_rating']),
        reviewCount: json['supplier_review_count'] ?? 0,
      );
    }

    // Performance fallback si performance_metrics absent
    PerformanceMetrics metrics;
    if (json['performance_metrics'] != null) {
      metrics = PerformanceMetrics.fromJson(json['performance_metrics']);
    } else {
      metrics = PerformanceMetrics(
        demandLevel: json['demand_level'] ?? 0,
        popularity: json['popularity'] ?? 0,
        competition: json['competition'] ?? 0,
        profitability: json['profitability'] ?? 0,
      );
    }

    return Product(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: _parseDouble(json['price']),
      profit: _parseDouble(json['profit']),
      cost: _parseDouble(json['cost']),
      imageUrl: json['image_url'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      score: json['score'] ?? 0,
      trendPercentage: _parseDouble(json['trend_percentage']),
      isTrending: json['is_trending'] ?? false,
      category: json['category'] ?? '',
      availableColors: List<String>.from(json['available_colors'] ?? []),
      source: ProductSource.fromString(json['source'] ?? 'aliexpress'),
      sourceUrl: json['source_url'] ?? '',
      supplier: supplier,
      performanceMetrics: metrics,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price.toString(),
      'profit': profit.toString(),
      'cost': cost.toString(),
      'image_url': imageUrl,
      'images': images,
      'score': score,
      'trend_percentage': trendPercentage.toString(),
      'is_trending': isTrending,
      'category': category,
      'available_colors': availableColors,
      'source': source.name,
      'source_url': sourceUrl,
      'supplier': supplier.toJson(),
      'performance_metrics': performanceMetrics.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? profit,
    double? cost,
    String? imageUrl,
    List<String>? images,
    int? score,
    double? trendPercentage,
    bool? isTrending,
    String? category,
    List<String>? availableColors,
    ProductSource? source,
    String? sourceUrl,
    Supplier? supplier,
    PerformanceMetrics? performanceMetrics,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      profit: profit ?? this.profit,
      cost: cost ?? this.cost,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      score: score ?? this.score,
      trendPercentage: trendPercentage ?? this.trendPercentage,
      isTrending: isTrending ?? this.isTrending,
      category: category ?? this.category,
      availableColors: availableColors ?? this.availableColors,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      supplier: supplier ?? this.supplier,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get daysAgoText {
    final difference = DateTime.now().difference(createdAt);
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

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      name: json['name'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }

  factory Supplier.empty() {
    return Supplier(
      name: 'Unknown',
      rating: 0.0,
      reviewCount: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rating': rating,
      'review_count': reviewCount,
    };
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

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      demandLevel: json['demand_level'] ?? 0,
      popularity: json['popularity'] ?? 0,
      competition: json['competition'] ?? 0,
      profitability: json['profitability'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'demand_level': demandLevel,
      'popularity': popularity,
      'competition': competition,
      'profitability': profitability,
    };
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
