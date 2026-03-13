import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/favorites_manager.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? product;
  
  const ProductDetailsScreen({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    // Determine info to show based on product or fallback
    final title = product?['title'] ?? 'Casque Sans-\nfil Premium';
    final price = product?['price'] ?? '29.99€';
    final profit = product?['profit'] ?? '15.50€';
    final scoreStr = product?['score']?.toString().replaceAll('Score: ', '') ?? '95';
    final imageUrl = product?['imageUrl'] ?? 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80';

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
          if (product != null)
             ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: FavoritesManager().favoritesNotifier,
                builder: (context, favoritesList, child) {
                   bool isFav = FavoritesManager().isFavorite(product!);
                   return IconButton(
                      icon: Icon(
                         isFav ? Icons.favorite : Icons.favorite_border,
                         color: isFav ? AppColors.primary : AppColors.textPrimary,
                      ),
                      onPressed: () {
                         FavoritesManager().toggleFavorite(product!);
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
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildColorDot(const Color(0xFFFFCCAA), isSelected: true),
                        _buildColorDot(const Color(0xFF00C853)),
                        _buildColorDot(const Color(0xFF2196F3)),
                        _buildColorDot(const Color(0xFFE91E63)),
                      ],
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
                           Column(
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
                                 child: const Text(
                                    'Audio & Tech',
                                    style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.w600),
                                 ),
                               ),
                             ],
                           ),
                           Column(
                             children: [
                                const Text('Score', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
                     const Text(
                        'Casque audio Bluetooth haute qualité avec réduction de bruit active, autonomie de 30h et design ergonomique pour un confort optimal.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                     ),
                     const SizedBox(height: 16),
                     Row(
                        children: [
                           Expanded(
                              child: _buildPriceBox(
                                 icon: Icons.sell_outlined,
                                 iconColor: AppColors.primary,
                                 bgColor: Colors.white,
                                 label: 'Prix de vente',
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
                                 label: 'Profit estimé',
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
                            const Text(
                               'Analyse de Performance',
                               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                         ],
                      ),
                      const SizedBox(height: 24),
                      _buildProgressBar('Demande', '92%'),
                      const SizedBox(height: 16),
                      _buildProgressBar('Rentabilité', '88%'),
                      const SizedBox(height: 16),
                      _buildProgressBar('Concurrence', '65%', color: AppColors.primary.withOpacity(0.6)),
                      const SizedBox(height: 16),
                      _buildProgressBar('Tendance', '95%'),
                   ],
                ),
             ),

             // Insights Marché
             _buildSectionCard(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      const Text(
                         'Insights Marché',
                         style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      _buildInsightRow(
                         icon: Icons.trending_up,
                         iconColor: Colors.green,
                         bgColor: const Color(0xFFE8F5E9), // Light green
                         title: 'Tendance à la hausse',
                         subtitle: '+45% de recherches cette semaine',
                      ),
                      const SizedBox(height: 12),
                      _buildInsightRow(
                         icon: Icons.people_outline,
                         iconColor: Colors.blue,
                         bgColor: const Color(0xFFE3F2FD), // Light blue
                         title: 'Forte demande',
                         subtitle: '15K+ ventes mensuelles estimées',
                      ),
                      const SizedBox(height: 12),
                      _buildInsightRow(
                         icon: Icons.attach_money,
                         iconColor: AppColors.primary,
                         bgColor: const Color(0xFFFFF8F3), // Light orange
                         title: 'Marge importante',
                         subtitle: '51% de marge bénéficiaire',
                      ),
                   ],
                ),
             ),

             // Fournisseur
             _buildSectionCard(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      const Text(
                         'Fournisseur',
                         style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                            Column(
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
                                        const Text('4.8/5 - 2.5K avis', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                     ],
                                  ),
                               ]
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
                                  label: const Text('Contacter', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
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
                                  label: const Text('Voir', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                               const Text('Prix fournisseur', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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

  Widget _buildColorDot(Color color, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
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
              Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                 ],
              ),
           ],
        ),
     );
  }
}
