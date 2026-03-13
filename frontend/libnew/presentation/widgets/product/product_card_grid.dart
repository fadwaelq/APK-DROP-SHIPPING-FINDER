import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/product_provider.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../../core/theme/app_theme.dart';

class ProductCardGrid extends StatelessWidget {
  final ProductEntity product;

  const ProductCardGrid({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingS),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Make height dynamic or use AspectRatio
            AspectRatio(
              aspectRatio: 1.1, // Changed from fixed height to aspect ratio
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
                child: Container(
                  color: AppTheme.lightGray,
                  child: Stack(
                    children: [
                      if (product.imageUrl.isNotEmpty)
                        Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: AppTheme.mediumGray,
                              ),
                            );
                          },
                        )
                      else
                        const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      // Favorite button
                      Positioned(
                        top: AppTheme.spacingS,
                        right: AppTheme.spacingS,
                        child: Consumer<ProductProvider>(
                          builder: (context, provider, child) {
                            return GestureDetector(
                              onTap: () {
                                provider.toggleFavorite(product.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBackground,
                                  shape: BoxShape.circle,
                                  boxShadow: AppTheme.cardShadow,
                                ),
                                child: Icon(
                                  product.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: product.isFavorite
                                      ? AppTheme.errorRed
                                      : AppTheme.textTertiary,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Score badge
                      Positioned(
                        bottom: AppTheme.spacingS,
                        left: AppTheme.spacingS,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                            vertical: AppTheme.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusSmall),
                          ),
                          child: Text(
                            product.score.toString(),
                            style: AppTheme.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            // Product Title
            Text(
              product.name,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            // Price
            Text(
              '${product.price.toStringAsFixed(2)} €',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            // Profit info
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 14,
                  color: AppTheme.successGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${product.trendPercentage.toStringAsFixed(1)}%',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: product.id),
      ),
    );
  }
}
