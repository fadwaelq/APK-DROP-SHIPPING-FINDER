import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                _buildColorOptions(),
                _buildPricing(),
                _buildPerformanceMetrics(),
                _buildInsights(),
                _buildSupplierInfo(),
                SizedBox(height: AppTheme.spacingXXL),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            shape: BoxShape.circle,
            boxShadow: AppTheme.cardShadow,
          ),
          child: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              shape: BoxShape.circle,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: product.isFavorite ? AppTheme.errorRed : AppTheme.textPrimary,
                );
              },
            ),
          ),
          onPressed: () {
            Provider.of<ProductProvider>(context, listen: false)
                .toggleFavorite(product.id);
          },
        ),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              shape: BoxShape.circle,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Icon(Icons.share, color: AppTheme.textPrimary),
          ),
          onPressed: () {
            // TODO: Implement share
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppTheme.lightGray,
          child: product.imageUrl.isNotEmpty
              ? Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.image, size: 80, color: AppTheme.mediumGray),
                    );
                  },
                )
              : Center(
                  child: Icon(Icons.image, size: 80, color: AppTheme.mediumGray),
                ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(product.score).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusCircle),
                ),
                child: Row(
                  children: [
                    Text(
                      'Score',
                      style: AppTheme.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(product.score),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingXS),
                    Text(
                      '${product.score}',
                      style: AppTheme.labelMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(product.score),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppTheme.spacingS),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: product.category == 'Sport'
                      ? AppTheme.infoBlue.withOpacity(0.1)
                      : AppTheme.mediumGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusCircle),
                ),
                child: Text(
                  product.category,
                  style: AppTheme.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: product.category == 'Sport'
                        ? AppTheme.infoBlue
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            product.name,
            style: AppTheme.displaySmall.copyWith(
              fontSize: 22,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacingS),
          Text(
            product.description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOptions() {
    if (product.availableColors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Couleurs disponibles',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacingS),
          Row(
            children: product.availableColors.map((color) {
              return Container(
                margin: EdgeInsets.only(right: AppTheme.spacingS),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getColorFromName(color),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.mediumGray, width: 2),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: AppTheme.spacingL),
        ],
      ),
    );
  }

  Widget _buildPricing() {
    return Container(
      margin: EdgeInsets.all(AppTheme.spacingL),
      padding: EdgeInsets.all(AppTheme.spacingL),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, 
                        size: 16, 
                        color: AppTheme.textSecondary),
                    SizedBox(width: AppTheme.spacingXS),
                    Text(
                      'Prix de vente',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacingXS),
                Text(
                  '${product.price.toStringAsFixed(2)}€',
                  style: AppTheme.displayMedium.copyWith(
                    fontSize: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.mediumGray,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, 
                        size: 16, 
                        color: AppTheme.successGreen),
                    SizedBox(width: AppTheme.spacingXS),
                    Text(
                      'Profit estimé',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacingXS),
                Text(
                  '${product.profit.toStringAsFixed(2)}€',
                  style: AppTheme.displayMedium.copyWith(
                    fontSize: 20,
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analyse de Performance',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacingM),
          _buildMetricBar('Demande', product.performanceMetrics.demandLevel),
          _buildMetricBar('Popularité', product.performanceMetrics.popularity),
          _buildMetricBar('Concurrence', product.performanceMetrics.competition),
          _buildMetricBar('Rentabilité', product.performanceMetrics.profitability),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, int value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '$value%',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryOrange,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: AppTheme.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Container(
      margin: EdgeInsets.all(AppTheme.spacingL),
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: AppTheme.successGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.successGreen, size: 20),
              SizedBox(width: AppTheme.spacingS),
              Text(
                'Insights Marché',
                style: AppTheme.headlineSmall.copyWith(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingM),
          _buildInsightItem(
            'Tendance à la hausse',
            '+${product.trendPercentage.toStringAsFixed(0)}% cette semaine',
          ),
          _buildInsightItem(
            'Faible demande',
            'Peu de concurrence sur ce marché',
          ),
          _buildInsightItem(
            'Marge importante',
            'Potentiel de profit élevé',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
          SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierInfo() {
    return Container(
      margin: EdgeInsets.all(AppTheme.spacingL),
      padding: EdgeInsets.all(AppTheme.spacingL),
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
          Text(
            'Fournisseur',
            style: AppTheme.headlineSmall.copyWith(
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Icon(Icons.store, color: AppTheme.infoBlue),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.supplier.name,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < product.supplier.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: AppTheme.warningYellow,
                          );
                        }),
                        SizedBox(width: AppTheme.spacingXS),
                        Text(
                          '${product.supplier.rating} • ${product.supplier.reviewCount} avis',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: AppTheme.cardShadow.map((shadow) {
          return BoxShadow(
            color: shadow.color,
            blurRadius: shadow.blurRadius,
            offset: Offset(shadow.offset.dx, -shadow.offset.dy),
            spreadRadius: shadow.spreadRadius,
          );
        }).toList(),
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: Add to list
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                side: BorderSide(color: AppTheme.secondaryOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
              ),
              child: Text(
                'Enregistrer',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.secondaryOrange,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacingM),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Open source link
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                'Voir sur ${product.source.displayName}',
                style: AppTheme.labelMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
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

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'green':
      case 'vert':
        return Colors.green;
      case 'blue':
      case 'bleu':
        return Colors.blue;
      case 'pink':
      case 'rose':
        return Colors.pink;
      case 'black':
      case 'noir':
        return Colors.black;
      case 'white':
      case 'blanc':
        return Colors.white;
      default:
        return AppTheme.mediumGray;
    }
  }
}