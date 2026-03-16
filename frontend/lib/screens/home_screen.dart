import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'product_details_screen.dart';
import '../services/favorites_manager.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:dropshipping_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingStats = true;
  bool _isLoadingProducts = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _trendingProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _fetchStats();
    _fetchTrendingProducts();
  }

  Future<void> _fetchStats() async {
    try {
      final result = await ApiService().getDashboardStats();
      if (mounted && result['success'] == true) {
        setState(() {
          _stats = result['data'];
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _fetchTrendingProducts() async {
    try {
      // Fetch products filtered by is_winner=true
      final response = await ApiService().client.get(
        Uri.parse('${ApiService().baseUrl}/products/?is_winner=true'),
        headers: ApiService().headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _trendingProducts = List<Map<String, dynamic>>.from(data);
            _isLoadingProducts = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingProducts = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = widget.userName;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.greeting,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Row(
                           children: [
                             Text(
                              firstName.toUpperCase(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            const Text('👋', style: TextStyle(fontSize: 18)),
                           ]
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildTopIconBar(context),
                const SizedBox(height: 24),
                
                // Orange Dashboard Card
                _buildDashboardCard(l10n),
                const SizedBox(height: 24),

                // KPI Cards Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildKpiCard(
                      icon: Icons.attach_money,
                      iconColor: Colors.green,
                      iconBgColor: Colors.green.withOpacity(0.1),
                      title: l10n.avg_profit,
                      value: '15.50 MAD',
                      valueColor: Colors.green,
                    ),
                    _buildKpiCard(
                      icon: Icons.inventory_2_outlined,
                      iconColor: Colors.blue,
                      iconBgColor: Colors.blue.withOpacity(0.1),
                      title: l10n.products,
                      value: '${_trendingProducts.length > 0 ? _trendingProducts.length * 10 : 847}',
                      valueColor: Colors.blue,
                    ),
                    _buildKpiCard(
                      icon: Icons.star_border,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primary.withOpacity(0.1),
                      title: l10n.top_niches,
                      value: '24',
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Trending Products Section
                _buildTrendingSection(l10n),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFF9A3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profit_score,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _isLoadingStats 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        '87/100',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Produits suivis', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: FavoritesManager().favoritesNotifier,
                    builder: (context, favorites, _) {
                      return Text(
                        '${favorites.length}', 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tendances actives', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${_stats['recent_searches'] ?? 5}', 
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  l10n.trending_products,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                const Text('🔥', style: TextStyle(fontSize: 16)),
              ],
            ),
            GestureDetector(
               onTap: () => Navigator.pushNamed(context, '/search'),
               child: Text(
                l10n.see_all,
                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : _trendingProducts.isEmpty
            ? Center(child: Text(l10n.search_no_results))
            : Column(
                children: _trendingProducts.take(3).map((product) => _buildProductCard(context, product: product)).toList(),
              ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, {required Map<String, dynamic> product}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
               builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product['image_url'] != null
                ? Image.network(product['image_url'], width: 80, height: 80, fit: BoxFit.cover)
                : Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['price'] ?? 0} MAD',
                    style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 14),
                      const SizedBox(width: 4),
                      const Text(
                        '+45%', // Fallback placeholder as backend doesn't have exact growth %
                        style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.period_this_week,
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${product['trend_score'] ?? 0}',
                style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIconBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEEE3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTopIcon(Icons.search, () => Navigator.pushNamed(context, '/search')),
          _buildTopIcon(Icons.group_outlined, () => Navigator.pushNamed(context, '/communaute')),
          _buildTopIcon(Icons.calendar_today_outlined, () => Navigator.pushNamed(context, '/evenements')),
          _buildTopIcon(Icons.emoji_events_outlined, () => Navigator.pushNamed(context, '/recompenses')),
          _buildTopIcon(Icons.notifications_none, () {}),
        ],
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.black87, size: 24),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
