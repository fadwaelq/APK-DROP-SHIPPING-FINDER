import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import 'product_details_screen.dart';
import '../services/favorites_manager.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
           AppLocalizations.of(context)!.my_favorites,
           style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
         valueListenable: FavoritesManager().favoritesNotifier,
         builder: (context, favoritesList, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                   // Header counter
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                     child: Row(
                       children: [
                         Text(
                           AppLocalizations.of(context)!.saved_products_count(favoritesList.length),
                           style: const TextStyle(
                             color: AppColors.textSecondary,
                             fontSize: 14,
                           ),
                         ),
                       ],
                     ),
                   ),
                   const Divider(color: Color(0xFFF0F0F0), height: 1),
                   
                   if (favoritesList.isEmpty)
                      // Big Icon and Empty State
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade400, width: 3),
                              ),
                              child: Center(
                                 child: Transform.rotate(
                                    angle: -0.785398, // -45 degrees
                                    child: Container(
                                      width: 2,
                                      height: 120,
                                      color: Colors.grey.shade400,
                                    ),
                                 ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              AppLocalizations.of(context)!.empty_watchlist_title,
                              style: const TextStyle(
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold,
                                 color: Color(0xFF2C3E50), 
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 24.0),
                               child: Text(
                                 AppLocalizations.of(context)!.empty_watchlist_subtitle,
                                 style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                                 textAlign: TextAlign.center,
                               ),
                            ),
                            const SizedBox(height: 48),
                            // Orange Card
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24.0),
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.discover_trending_title,
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(context)!.discover_trending_subtitle,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                                  ),
                                  const SizedBox(height: 24),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(content: Text(AppLocalizations.of(context)!.go_to_search_btn)),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.start_search_btn,
                                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                   else
                      // List of favorites
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                           children: [
                              ...favoritesList.map((product) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
                                    );
                                  },
                                  child: _buildFavoriteItem(product: product),
                                ),
                              )),
                              const SizedBox(height: 32),
                              // Conseil Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.advice_title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppLocalizations.of(context)!.advice_subtitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.discover_more_products_btn,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                           ],
                        ),
                      ),
                ],
              ),
            );
         },
      ),
    );
  }

  Widget _buildFavoriteItem({required Map<String, dynamic> product}) {
    final String imageUrl = product['imageUrl'] ?? '';
    final String title = product['title'] ?? 'Produit Inconnu';
    final String score = product['score']?.toString().replaceAll('Score: ', '') ?? 'N/A';
    final String price = product['price'] ?? '0.00€';
    final String profit = product['profit'] ?? '0.00€';
    final String trend = product['trend'] ?? '';
    final String dateAdded = product['dateAdded'] ?? 'Récemment';
    final Color trendColor = product['trendColor'] ?? Colors.green;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                         FavoritesManager().toggleFavorite(product);
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                     color: const Color(0xFFE8F5E9),
                     borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    score,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.price_label,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.profit_label,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                        Text(
                          profit,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: trendColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          trend,
                          style: TextStyle(
                            color: trendColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      dateAdded,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
