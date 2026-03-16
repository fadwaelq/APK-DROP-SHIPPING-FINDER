import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'package:dropshipping_app/screens/product_details_screen.dart';
import '../utils/theme.dart';

class ProductCardList extends StatelessWidget {
  final Product product;

  const ProductCardList({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.lightGray,
                      Colors.red,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    if (product.imageUrl.isNotEmpty)
                      Image.network(
                        product.imageUrl,
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackImage();
                        },
                      )
                    else
                      _buildFallbackImage(),
                    // Score badge
                    Positioned(
                      top: AppTheme.spacingS,
                      left: AppTheme.spacingS,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                          vertical: AppTheme.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(product.score),
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusCircle),
                          boxShadow: [
                            BoxShadow(
                              color: _getScoreColor(product.score)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.score}',
                              style: AppTheme.labelMedium.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: AppTheme.bodyMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Consumer<ProductProvider>(
                          builder: (context, provider, child) {
                            return IconButton(
                              icon: Icon(
                                product.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: product.isFavorite
                                    ? AppTheme.errorRed
                                    : AppTheme.textTertiary,
                                size: 20,
                              ),
                              onPressed: () {
                                provider.toggleFavorite(product.id);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            );
                          },
                        ),
                      ],
                    ),
                    // const SizedBox(height: AppTheme.spacingS),
                  Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prix',
              style: AppTheme.labelMedium.copyWith(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),

            // Ligne ancien + nouveau prix
            Row(
              children: [
                Text(
                  '${product.price.toStringAsFixed(2)}€',
                  style: AppTheme.titleMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 2,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${(product.price - product.profit).toStringAsFixed(2)}€',
                  style: AppTheme.titleMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ),

    const SizedBox(width: 24),

    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profit',
          style: AppTheme.labelMedium.copyWith(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${product.profit.toStringAsFixed(2)}€',
          style: AppTheme.titleMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.successGreen,
          ),
        ),
      ],
    ),
  ],
                  ),

                    // const SizedBox(height: AppTheme.spacingS),
                    Row(
                      children: [
                        Icon(
                          product.trendPercentage >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: _getTrendColor(product.trendPercentage),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.trendPercentage >= 0 ? '+' : ''}${product.trendPercentage.toStringAsFixed(0)}% cette semaine',
                          style: AppTheme.labelMedium.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getTrendColor(product.trendPercentage),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 40,
            color: AppTheme.primaryOrange.withOpacity(0.3),
          ),
          const SizedBox(height: 4),
          Text(
            product.name.split(' ').first,
            style: AppTheme.labelMedium.copyWith(
              fontSize: 10,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppTheme.successGreen;
    if (score >= 75) return const Color(0xFF94D82D);
    if (score >= 60) return AppTheme.warningYellow;
    return AppTheme.errorRed;
  }

  Color _getTrendColor(double percentage) {
    return percentage >= 0 ? AppTheme.successGreen : AppTheme.errorRed;
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: {
          'imageUrl': product.imageUrl,
          'title': product.name,
          'price': '${product.price}€',
          'profit': '${product.profit}€',
          'score': product.score.toString(),
        }),
      ),
    );
//    Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => ProductDetailScreen(
//       productId: product.id,
//     ),
//   ),
// );

  }
}
