import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../services/favorites_manager.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  
  const ProductDetailsScreen({super.key, this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String _currentImageUrl;
  int _selectedColorIndex = 0;

  final List<Map<String, dynamic>> _colorOptions = [
    {
      'color': const Color(0xFFFFCCAA),
      'image': 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    },
    {
      'color': const Color(0xFF00C853),
      'image': 'https://images.unsplash.com/photo-1546435770-a3e426ff472b?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    },
    {
      'color': const Color(0xFF2196F3),
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    },
    {
      'color': const Color(0xFFE91E63),
      'image': 'https://images.unsplash.com/photo-1484704849700-f032a568e944?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.product?['imageUrl'] ?? _colorOptions[0]['image'];
  }

  @override
  Widget build(BuildContext context) {
    // Determine info to show based on product or fallback
    final title = widget.product?['title'] ?? AppLocalizations.of(context)!.product_title_fallback;
    final price = widget.product?['price'] ?? '29.99€';
    final profit = widget.product?['profit'] ?? '15.50€';
    final scoreStr = widget.product?['score']?.toString().replaceAll('Score: ', '') ?? '95';
    final scoreLabel = AppLocalizations.of(context)!.score;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.product != null)
             ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: FavoritesManager().favoritesNotifier,
                builder: (context, favoritesList, child) {
                   bool isFav = FavoritesManager().isFavorite(widget.product!);
                   return IconButton(
                      icon: Icon(
                         isFav ? Icons.favorite : Icons.favorite_border,
                         color: isFav ? AppColors.primary : AppColors.textPrimary,
                      ),
                      onPressed: () {
                         FavoritesManager().toggleFavorite(widget.product!);
                      },
                   );
                },
             )
          else
             IconButton(
               icon: const Icon(Icons.favorite_border, color: AppColors.textPrimary),
               onPressed: () {},
             ),
          IconButton(
             icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
             onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image & Colors
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24.0),
               child: Column(
                 children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(_currentImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_colorOptions.length, (index) {
                        return _buildColorDot(
                          _colorOptions[index]['color'], 
                          index: index,
                        );
                      }),
                    ),
                 ]
               )
            ),
            const SizedBox(height: 24),

            // Basic Info Card
             _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                    title.replaceAll('\n', ''),
                                    style: const TextStyle(
                                       fontSize: 16,
                                       fontWeight: FontWeight.bold,
                                       color: AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                 ),
                                 const SizedBox(height: 8),
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                   decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                   ),
                                   child: Text(
                                      AppLocalizations.of(context)!.audio_tech_category,
                                      style: const TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.w600),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(width: 16),
                           Column(
                             children: [
                                Text(scoreLabel, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                     color: const Color(0xFFE8F5E9),
                                     shape: BoxShape.circle,
                                     border: Border.all(color: Colors.green.withOpacity(0.3)),
                                  ),
                                  child: Text(scoreStr, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                             ],
                           ),
                        ],
                     ),
                     const SizedBox(height: 16),
                     Text(
                        AppLocalizations.of(context)!.product_desc_fallback,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                     ),
                     const SizedBox(height: 16),
                     Row(
                        children: [
                           Expanded(
                              child: _buildPriceBox(
                                 icon: Icons.sell_outlined,
                                 iconColor: AppColors.primary,
                                 bgColor: Colors.white,
                                 label: AppLocalizations.of(context)!.selling_price,
                                 value: price,
                                 valueColor: AppColors.textPrimary,
                                 borderColor: const Color(0xFFF0F0F0),
                               ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                              child: _buildPriceBox(
                                 icon: Icons.attach_money,
                                 iconColor: Colors.green,
                                 bgColor: const Color(0xFFF1F8F5), // Light green tint
                                 label: AppLocalizations.of(context)!.estimated_profit,
                                 value: profit,
                                 valueColor: Colors.green,
                                 borderColor: Colors.transparent,
                              ),
                           ),
                        ],
                     ),
                  ]
                ),
             ),
             
             // Performance Analysis
             _buildSectionCard(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Row(
                         children: [
                            const Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                               AppLocalizations.of(context)!.performance_analysis,
                               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                         ],
                      ),
                      const SizedBox(height: 24),
                      _buildProgressBar(AppLocalizations.of(context)!.demand_label, '92%'),
                      const SizedBox(height: 16),
                      _buildProgressBar(AppLocalizations.of(context)!.profitability_label, '88%'),
                      const SizedBox(height: 16),
                      _buildProgressBar(AppLocalizations.of(context)!.competition_label, '65%', color: AppColors.primary.withOpacity(0.6)),
                      const SizedBox(height: 16),
                      _buildProgressBar(AppLocalizations.of(context)!.trend_label, '95%'),
                   ],
                ),
             ),

             // Insights Marché
             _buildSectionCard(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(
                         AppLocalizations.of(context)!.market_insights,
                         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      _buildInsightRow(
                         icon: Icons.trending_up,
                         iconColor: Colors.green,
                         bgColor: const Color(0xFFE8F5E9), // Light green
                         title: AppLocalizations.of(context)!.trending_up_label,
                         subtitle: '+45% de recherches cette semaine',
                      ),
                      const SizedBox(height: 12),
                      _buildInsightRow(
                         icon: Icons.people_outline,
                         iconColor: Colors.blue,
                         bgColor: const Color(0xFFE3F2FD), // Light blue
                         title: AppLocalizations.of(context)!.strong_demand_label,
                         subtitle: AppLocalizations.of(context)!.monthly_sales_est('15'),
                      ),
                      const SizedBox(height: 12),
                      _buildInsightRow(
                         icon: Icons.attach_money,
                         iconColor: AppColors.primary,
                         bgColor: const Color(0xFFFFF8F3), // Light orange
                         title: AppLocalizations.of(context)!.large_margin_label,
                         subtitle: AppLocalizations.of(context)!.profit_margin_est('51'),
                      ),
                   ],
                ),
             ),

             // Fournisseur
             _buildSectionCard(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(
                         AppLocalizations.of(context)!.supplier_label,
                         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                         children: [
                            Container(
                               padding: const EdgeInsets.all(12),
                               decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                               ),
                               child: const Icon(Icons.storefront, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                    const Text(
                                       'AliExpress Premium',
                                       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                       children: [
                                          const Icon(Icons.star, color: Colors.orange, size: 12),
                                          const Icon(Icons.star, color: Colors.orange, size: 12),
                                          const Icon(Icons.star, color: Colors.orange, size: 12),
                                          const Icon(Icons.star, color: Colors.orange, size: 12),
                                          Icon(Icons.star_half, color: Colors.orange.withOpacity(0.5), size: 12),
                                          const SizedBox(width: 4),
                                          Text(AppLocalizations.of(context)!.reviews_count('4.8', '2.5K'), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                       ],
                                    ),
                                 ]
                              ),
                            ),
                         ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                         children: [
                            Expanded(
                               child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primary),
                                  label: Text(AppLocalizations.of(context)!.contact_btn, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                     side: const BorderSide(color: AppColors.primary),
                                     padding: const EdgeInsets.symmetric(vertical: 12),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                               ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                               child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.open_in_new, size: 16, color: Colors.white),
                                  label: Text(AppLocalizations.of(context)!.view_btn, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                     backgroundColor: AppColors.primary,
                                     padding: const EdgeInsets.symmetric(vertical: 12),
                                     elevation: 0,
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                               ),
                            ),
                         ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                         ),
                         child: Row(
                            children: [
                                Text(AppLocalizations.of(context)!.supplier_price, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                               const SizedBox(width: 8),
                               const Text('14.49 €', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                               const SizedBox(width: 8),
                               const Text('(MOQ: 10 pcs)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                         ),
                      ),
                   ],
                ),
             ),
             
             const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, {required int index}) {
    bool isSelected = _selectedColorIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColorIndex = index;
          _currentImageUrl = _colorOptions[index]['image'];
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: Colors.transparent, width: 2),
        ),
        child: isSelected 
          ? const Center(child: Icon(Icons.check, size: 16, color: Colors.white))
          : null,
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
     return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(20),
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
        child: child,
     );
  }

  Widget _buildPriceBox({
     required IconData icon,
     required Color iconColor,
     required Color bgColor,
     required String label,
     required String value,
     required Color valueColor,
     required Color borderColor,
  }) {
     return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
           color: bgColor,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: borderColor),
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Row(
                 children: [
                    Icon(icon, size: 14, color: iconColor),
                    const SizedBox(width: 4),
                    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                 ],
              ),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor)),
           ],
        ),
     );
  }

  Widget _buildProgressBar(String label, String percentage, {Color color = AppColors.primary}) {
     // Extract double from string like '92%'
     double widthFactor = double.tryParse(percentage.replaceAll('%', '')) ?? 0;
     widthFactor = widthFactor / 100.0;

     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                 Text(percentage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
           ),
           const SizedBox(height: 8),
           Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                 color: const Color(0xFFF0F0F0),
                 borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                 alignment: Alignment.centerLeft,
                 widthFactor: widthFactor,
                 child: Container(
                    decoration: BoxDecoration(
                       color: color,
                       borderRadius: BorderRadius.circular(3),
                    ),
                 ),
              ),
           ),
        ],
     );
  }

  Widget _buildInsightRow({
     required IconData icon,
     required Color iconColor,
     required Color bgColor,
     required String title,
     required String subtitle,
  }) {
     return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
           color: bgColor,
           borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
           children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                   ],
                ),
              ),
           ],
        ),
     );
  }
}
