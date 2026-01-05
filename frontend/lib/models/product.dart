class Product {
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

  Product({
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

  factory Product.fromJson(Map<String, dynamic> json) {
  // Convert id to string if it's an int
  final idValue = json['id'];
  final id = idValue != null ? idValue.toString() : '';
  
  // Extract category name from nested object or use fallback
  String categoryName = '';
  if (json['category'] != null) {
    if (json['category'] is Map) {
      // Use French name if available, otherwise English name
      categoryName = json['category']['name_fr'] ?? 
                    json['category']['name'] ?? 
                    '';
    } else if (json['category'] is String) {
      categoryName = json['category'];
    }
  }
  
  return Product(
    id: id,
    name: json['name'] ?? json['name_fr'] ?? '',
    description: json['description'] ?? '',
    price: _parseDouble(json['price']),
    profit: _parseDouble(json['profit_amount'] ?? json['profit']), // Use profit_amount from API
    imageUrl: json['main_image'] ?? json['image_url'] ?? '',
    score: json['score'] ?? 0,
    trendPercentage: _parseDouble(json['trend_percentage']),
    category: categoryName,
    availableColors: List<String>.from(json['available_colors'] ?? []),
    source: ProductSource.fromString(json['source'] ?? 'aliexpress'),
    supplier: json['supplier'] != null 
        ? Supplier.fromJson(json['supplier'])
        : Supplier.empty(),
    performanceMetrics: json['performance_metrics'] != null
        ? PerformanceMetrics.fromJson(json['performance_metrics'])
        : PerformanceMetrics.empty(),
    addedDate: json['added_date'] != null || json['created_at'] != null
        ? DateTime.parse(json['added_date'] ?? json['created_at'])
        : DateTime.now(),
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
    'name_fr': name, // Add French name if you need it
    'description': description,
    'price': price.toString(),
    'profit_margin': profit.toString(), // Map profit to profit_margin for API
    'profit_amount': profit.toString(),
    'main_image': imageUrl,
    'image_url': imageUrl, // Keep both for compatibility
    'score': score,
    'trend_percentage': trendPercentage.toString(),
    'category': {
      'name': category,
      'name_fr': category,
    },
    'available_colors': availableColors,
    'source': source.name,
    'supplier': supplier.toJson(),
    'performance_metrics': performanceMetrics.toJson(),
    'added_date': addedDate.toIso8601String(),
    'created_at': addedDate.toIso8601String(), // Add created_at for API compatibility
    'is_favorite': isFavorite,
  };
}

  Product copyWith({
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
    return Product(
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
  
  factory PerformanceMetrics.empty() {
    return PerformanceMetrics(
      demandLevel: 0,
      popularity: 0,
      competition: 0,
      profitability: 0,
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
