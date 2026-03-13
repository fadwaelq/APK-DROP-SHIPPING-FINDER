import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/product_card_grid.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Favoris',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.secondaryOrange,
              ),
            );
          }

          final favorites = productProvider.favorites;

          if (favorites.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppTheme.spacingM),
                child: Row(
                  children: [
                    Text(
                      '${favorites.length} produits',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'sauvegardés',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(AppTheme.spacingM),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final product = favorites[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppTheme.spacingM),
                      child: _buildFavoriteItem(context, product),
                    );
                  },
                ),
              ),
              _buildAdviceCard(context),
            ],
          );
        },
      ),
    ),
    bottomNavigationBar: CustomBottomNavBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _navigateToPage(index);
      },
    ),
  );
  }

  Widget _buildFavoriteItem(BuildContext context, product) {
    return Container(
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
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.borderRadiusLarge),
              bottomLeft: Radius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Container(
              width: 100,
              height: 100,
              color: AppTheme.lightGray,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image,
                          size: 40,
                          color: AppTheme.mediumGray,
                        );
                      },
                    )
                  : Icon(
                      Icons.image,
                      size: 40,
                      color: AppTheme.mediumGray,
                    ),
            ),
          ),
          
          // Product Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppTheme.errorRed,
                          size: 20,
                        ),
                        onPressed: () {
                          Provider.of<ProductProvider>(context, listen: false)
                              .toggleFavorite(product.id);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingXS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(product.score).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      'Score: ${product.score}',
                      style: AppTheme.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(product.score),
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingS),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prix',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacingXS),
                          Text(
                            '${product.price.toStringAsFixed(2)}€',
                            style: AppTheme.titleMedium.copyWith(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: AppTheme.spacingL),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profit',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacingXS),
                          Text(
                            '${product.profit.toStringAsFixed(2)}€',
                            style: AppTheme.titleMedium.copyWith(
                              fontSize: 14,
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        product.daysAgoText,
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingXS),
                  Row(
                    children: [
                      Icon(
                        product.trendPercentage >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: _getTrendColor(product.trendPercentage),
                      ),
                      SizedBox(width: AppTheme.spacingXS),
                      Text(
                        '${product.trendPercentage >= 0 ? '+' : ''}${product.trendPercentage.toStringAsFixed(0)}%',
                        style: AppTheme.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getTrendColor(product.trendPercentage),
                          fontSize: 12,
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
    );
  }

  Widget _buildAdviceCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppTheme.spacingM),
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.secondaryOrange,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: AppTheme.spacingS),
              Text(
                'Conseil',
                style: AppTheme.headlineSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingS),
          Text(
            'Consultez régulièrement vos favoris pour suivre l\'évolution des tendances et des scores',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppTheme.spacingM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.secondaryOrange,
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                'Découvrir plus de produits',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.secondaryOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppTheme.mediumGray,
            ),
            SizedBox(height: AppTheme.spacingL),
            Text(
              'Aucun favori',
              style: AppTheme.displaySmall.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacingS),
            Text(
              'Ajoutez des produits à vos favoris pour les retrouver facilement',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacingXL),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL,
                  vertical: AppTheme.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                'Découvrir des produits',
                style: AppTheme.labelMedium,
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

  Color _getTrendColor(double percentage) {
    return percentage >= 0 ? AppTheme.successGreen : AppTheme.errorRed;
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        // Already on favorites
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }
}