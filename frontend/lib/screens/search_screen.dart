import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/product_card_grid.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load trending products first (no auth required)
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.loadTrendingProducts();
      // Also try to load all products (may require auth)
      provider.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recherche',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(child: _buildProductList()),
          ],
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

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<ProductProvider>(context, listen: false)
                              .setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                Provider.of<ProductProvider>(context, listen: false)
                    .setSearchQuery(value);
              },
            ),
          ),
          SizedBox(width: AppTheme.spacingS),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () {
                _showFilterBottomSheet();
              },
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            itemCount: ProductCategory.allCategories.length,
            itemBuilder: (context, index) {
              final category = ProductCategory.allCategories[index];
              final isSelected = productProvider.selectedCategory == category;

              return Padding(
                padding: EdgeInsets.only(right: AppTheme.spacingM),
                child: FilterChip(
                  label: Text(
                    category,
                    style: AppTheme.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    productProvider.setCategory(category);
                  },
                  backgroundColor: AppTheme.lightGray,
                  selectedColor: AppTheme.secondaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusCircle),
                  ),
                  checkmarkColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingXS,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.secondaryOrange,
            ),
          );
        }

        final products = productProvider.filteredProducts;

        if (products.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${products.length} produits trouvés',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement sort
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Trier par score',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.secondaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(AppTheme.spacingM),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65, // Changed from 0.7 to 0.65 for taller cards
                  crossAxisSpacing: AppTheme.spacingM,
                  mainAxisSpacing: AppTheme.spacingM,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCardGrid(
                    product: products[index],
                  );
                },
              ),
            ),
          ],
        );
      },
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
              Icons.search_off,
              size: 80,
              color: AppTheme.mediumGray,
            ),
            SizedBox(height: AppTheme.spacingL),
            Text(
              'Aucun produit trouvé',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacingS),
            Text(
              'Essayez de modifier vos filtres ou votre recherche',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtres avancés',
                style: AppTheme.headlineSmall.copyWith(
                  fontSize: 20,
                ),
              ),
              SizedBox(height: AppTheme.spacingL),
              Text(
                'Score minimum',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              Slider(
                value: 70,
                min: 0,
                max: 100,
                divisions: 10,
                label: '70',
                activeColor: AppTheme.secondaryOrange,
                inactiveColor: AppTheme.lightGray,
                onChanged: (value) {},
              ),
              SizedBox(height: AppTheme.spacingM),
              Text(
                'Prix maximum',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              Slider(
                value: 50,
                min: 0,
                max: 100,
                divisions: 10,
                label: '50€',
                activeColor: AppTheme.secondaryOrange,
                inactiveColor: AppTheme.lightGray,
                onChanged: (value) {},
              ),
              SizedBox(height: AppTheme.spacingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Appliquer',
                    style: AppTheme.labelLarge,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Already on search
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}