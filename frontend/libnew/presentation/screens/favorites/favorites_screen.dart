import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/product/product_card_list.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      // Load favorites
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppTheme.cardPadding,
              color: AppTheme.cardBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'Mes favoris',
                    style: AppTheme.displaySmall,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Les produits que vous avez ajoutés aux favoris',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.isLoading) {
                    return const LoadingWidget();
                  }

                  if (productProvider.error != null) {
                    return AppErrorWidget(
                      message: productProvider.error!,
                      onRetry: () {
                        // Reload favorites
                      },
                    );
                  }

                  if (productProvider.favorites.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun favori pour le moment',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Les produits que vous aimez apparaîtront ici',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      // Refresh favorites
                    },
                    color: AppTheme.secondaryOrange,
                    child: ListView.separated(
                      padding: AppTheme.screenPadding,
                      itemCount: productProvider.favorites.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppTheme.spacingM),
                      itemBuilder: (context, index) {
                        final product = productProvider.favorites[index];
                        return ProductCardList(
                          product: product,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
