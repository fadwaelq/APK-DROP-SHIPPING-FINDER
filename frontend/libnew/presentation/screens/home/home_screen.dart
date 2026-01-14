import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/product/product_card_list.dart';
import '../../widgets/common/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await Future.wait([
      productProvider.loadTrendingProducts(),
      userProvider.loadUserProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.secondaryOrange,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: AppTheme.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildScoreCard(),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildStatsCards(),
                  const SizedBox(height: AppTheme.spacingXL),
                  _buildTrendingSection(),
                  const SizedBox(height: AppTheme.spacingXXL),
                ],
              ),
            ),
          ),
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

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final firstName = user?.name.split(' ').first ?? 'OMAR';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      firstName.toUpperCase(),
                      style: AppTheme.displaySmall.copyWith(
                        fontSize: 24,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    const Text(
                      '👋',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.textPrimary,
                    size: 24,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryOrange,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppTheme.cardBackground, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreCard() {
    return Consumer2<UserProvider, ProductProvider>(
      builder: (context, userProvider, productProvider, child) {
        final user = userProvider.user;
        final products = productProvider.products;

        // Calculate real statistics
        final score = user?.profitabilityScore ?? 87;
        final followedProducts = productProvider.favorites.length;
        final activeTrends =
            products.where((p) => p.trendPercentage > 0).length;

        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            gradient: AppTheme.orangeGradient,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            boxShadow: AppTheme.buttonShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score de Rentabilité',
                    style: AppTheme.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                '$score/100',
                style: AppTheme.displayLarge.copyWith(
                  fontSize: 36,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produits suivis',
                          style: AppTheme.labelMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          '$followedProducts',
                          style: AppTheme.displayMedium.copyWith(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tendances actives',
                          style: AppTheme.labelMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          '$activeTrends',
                          style: AppTheme.displayMedium.copyWith(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.trendingProducts;

        // Calculer les vraies statistiques
        double avgProfit = 0;
        if (products.isNotEmpty) {
          avgProfit = products.map((p) => p.profit).reduce((a, b) => a + b) /
              products.length;
        }

        final totalProducts = products.length;
        final topNiches = products.map((p) => p.category).toSet().length;

        return Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.attach_money,
                label: 'Profit moy.',
                value: '${avgProfit.toStringAsFixed(2)}€',
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            Expanded(
              child: StatCard(
                icon: Icons.inventory_2_outlined,
                label: 'Produits',
                value: '\$totalProducts',
                color: AppTheme.infoBlue,
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            Expanded(
              child: StatCard(
                icon: Icons.star_outline,
                label: 'Top niches',
                value: '$topNiches',
                color: AppTheme.warningYellow,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Produits Tendance',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Voir tout',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.secondaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Consumer<ProductProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXL),
                  child: CircularProgressIndicator(
                    color: AppTheme.secondaryOrange,
                  ),
                ),
              );
            }

            final products = provider.filteredProducts;

            if (products.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Chargement des produits...',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Les produits tendance apparaîtront ici',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.loadProducts();
                        },
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryOrange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingL,
                            vertical: AppTheme.spacingS,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusMedium),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppTheme.spacingM),
              itemBuilder: (context, index) {
                return ProductCardList(product: products[index]);
              },
            );
          },
        ),
      ],
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/search');
        break;
      case 2:
        Navigator.pushNamed(context, '/favorites');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}
