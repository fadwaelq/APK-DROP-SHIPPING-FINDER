import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/favorites_manager.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> _getFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.filter_trending,
      l10n.filter_margin,
      l10n.filter_new,
      l10n.filter_viral,
    ];
  }

  String _selectedFilter = ''; // Will initialize in didChangeDependencies
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _products = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedFilter.isEmpty) {
      _selectedFilter = AppLocalizations.of(context)!.filter_viral;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initial fetch
    _performSearch('');
    // Load favorites from backend
    FavoritesManager().loadFavorites();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
        _performSearch(_searchQuery);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService().searchProducts(query);
      if (mounted) {
        setState(() {
          if (result['success'] == true) {
            // Handle both list and paginated response
            if (result['data'] != null) {
              _products = result['data'];
            } else if (result['results'] != null) {
              _products = result['results'];
            } else {
              _products = [];
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  List<dynamic> get _filteredProducts => _products;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.currency_bitcoin, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Text(
                  '350 ${AppLocalizations.of(context)!.coins_label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.search_find_winning,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.search_analyze_hint,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: Colors.grey),
                    hintText: AppLocalizations.of(context)!.search_input_hint,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 45,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _getFilters(context).length,
                itemBuilder: (context, index) {
                  final filters = _getFilters(context);
                  bool isSelected = filters[index] == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filters[index]),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.orange.withOpacity(0.5) : Colors.grey[300]!,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          filters[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.orange : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  : _filteredProducts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              AppLocalizations.of(context)!.search_no_results,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(_filteredProducts[index]);
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[50],
                    child: product['image_url'] != null
                        ? Image.network(
                            product['image_url'],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.image_not_supported),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: FavoritesManager().favoritesNotifier,
                    builder: (context, favoritesList, child) {
                      final isFav = FavoritesManager().isFavorite(product);
                      return GestureDetector(
                        onTap: () async {
                           final result = await FavoritesManager().toggleFavorite(product);
                           if (result['success'] == false && mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('Erreur: ${result['message']}')),
                             );
                           }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? AppColors.primary : Colors.grey,
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product['price'] ?? 0} MAD',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profit: ${product['potential_profit'] ?? 0} MAD',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppLocalizations.of(context)!.search_global_score}: ${product['trend_score'] ?? 0}/10',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
