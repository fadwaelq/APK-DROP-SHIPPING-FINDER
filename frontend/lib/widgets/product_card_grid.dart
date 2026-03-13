import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../screens/product_detail_screen.dart';
import '../utils/theme.dart';

class ProductCardGrid extends StatelessWidget {
  final Product product;

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
                                AppTheme.borderRadiusMedium),
                          ),
                          child: Text(
                            'Score: ${product.score}',
                            style: AppTheme.labelMedium.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

            // Product Info - Remove Expanded and use fixed constraints
            Flexible(
              // Change from Expanded to Flexible
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max, // Important
                  children: [
                    // Product name with more lines if needed
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            product.name,
                            style: AppTheme.bodyMedium.copyWith(
                              fontSize: 12, // Slightly smaller
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Price and profit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prix',
                              style: AppTheme.labelMedium.copyWith(
                                fontSize: 9,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${product.price.toStringAsFixed(2)}€',
                              style: AppTheme.titleMedium.copyWith(
                                fontSize: 11, // Slightly smaller
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Profit',
                              style: AppTheme.labelMedium.copyWith(
                                fontSize: 9,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${product.profit.toStringAsFixed(2)}€',
                              style: AppTheme.titleMedium.copyWith(
                                fontSize: 11, // Slightly smaller
                                fontWeight: FontWeight.w700,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ],
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

  Color _getScoreColor(int score) {
    if (score >= 90) return AppTheme.successGreen;
    if (score >= 75) return const Color(0xFF94D82D);
    if (score >= 60) return AppTheme.warningYellow;
    return AppTheme.errorRed;
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
