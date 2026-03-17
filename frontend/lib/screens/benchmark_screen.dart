import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/api_service.dart';

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen> {
  String _selectedFilter = 'Tous';
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _summary;
  List<dynamic> _benchmarkProducts = const [];
  List<dynamic> _categoryTrends = const [];
  List<dynamic> _history = const [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService().getBenchmarkSummary(),
        ApiService().getBenchmarkProducts(),
        ApiService().getCategoryTrendsV2(),
        ApiService().getProductsHistory(),
      ]);

      final summaryRes = results[0];
      final productsRes = results[1];
      final categoryRes = results[2];
      final historyRes = results[3];

      if (!mounted) return;

      if (summaryRes['success'] != true) {
        setState(() {
          _error = summaryRes['message']?.toString() ?? 'Erreur benchmark summary';
          _loading = false;
        });
        return;
      }

      final summaryData = summaryRes['data'];
      final productsData = productsRes['success'] == true ? productsRes['data'] : null;
      final categoryData = categoryRes['success'] == true ? categoryRes['data'] : null;
      final historyData = historyRes['success'] == true ? historyRes['data'] : null;

      setState(() {
        _summary = (summaryData is Map) ? Map<String, dynamic>.from(summaryData) : <String, dynamic>{'data': summaryData};
        _benchmarkProducts = productsData is List ? productsData : (productsData is Map ? (productsData['results'] ?? productsData['data'] ?? const []) : const []);
        _categoryTrends = categoryData is List ? categoryData : (categoryData is Map ? (categoryData['results'] ?? categoryData['data'] ?? const []) : const []);
        _history = historyData is List ? historyData : (historyData is Map ? (historyData['results'] ?? historyData['data'] ?? const []) : const []);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAll,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null)
                      ? ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadAll,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        )
                      : DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              Container(
                                color: Colors.grey[100],
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const TabBar(
                                  labelColor: AppColors.primary,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: AppColors.primary,
                                  tabs: [
                                    Tab(text: 'Benchmark'),
                                    Tab(text: 'Catégories'),
                                    Tab(text: 'Historique'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildBenchmarkTab(),
                                    _buildCategoryTrendsTab(),
                                    _buildHistoryTab(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3, // Profil
        onTap: (index) {
          if (index != 3) {
            Navigator.pushReplacementNamed(context, '/home', arguments: index);
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Benchmark Produits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.filter_list, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Filter',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildFilterChip('Tous'),
              const SizedBox(width: 10),
              _buildFilterChip('Tendance'),
              const SizedBox(width: 10),
              _buildFilterChip('Forte marge'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final s = _summary ?? {};
    final analyzed = (s['products_analyzed'] ?? s['analyzed'] ?? s['total_products'] ?? '').toString();
    final avgMargin = (s['avg_margin'] ?? s['avg_margin_percent'] ?? s['average_margin'] ?? '').toString();
    final sales = (s['monthly_sales'] ?? s['sales_per_month'] ?? s['sales'] ?? '').toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(analyzed.isEmpty ? '—' : analyzed, 'Produits\nanalysés', Colors.orange),
        _buildStatCard(avgMargin.isEmpty ? '—' : avgMargin, 'Marge moy', Colors.green),
        _buildStatCard(sales.isEmpty ? '—' : sales, 'Ventes/mois', Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsRow(),
          const SizedBox(height: 24),
          const Text(
            'Meilleur Potentiel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),
          if (_benchmarkProducts.isEmpty)
            const Text('Aucun produit benchmark pour le moment.')
          else
            Column(
              children: _benchmarkProducts.take(10).map((p) {
                final m = p is Map ? Map<String, dynamic>.from(p) : <String, dynamic>{'title': p.toString()};
                return _buildProductCard(m);
              }).toList(),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryTrendsTab() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _categoryTrends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _categoryTrends[index];
        final m = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{'category': item.toString()};
        final title = (m['category'] ?? m['name'] ?? m['title'] ?? 'Catégorie').toString();
        final score = (m['score'] ?? m['trend_score'] ?? m['value'] ?? '').toString();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.category_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (score.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(score, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: const [
          Text('Aucun historique disponible pour le moment.'),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _history[index];
        final m = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{'label': item.toString()};
        final title = (m['title'] ?? m['product_title'] ?? m['query'] ?? m['label'] ?? 'Historique').toString();
        final subtitle = (m['created_at'] ?? m['timestamp'] ?? m['date'] ?? '').toString();
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: const Icon(Icons.history, color: AppColors.primary),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: subtitle.isEmpty ? null : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (product['title'] ?? product['name'] ?? 'Produit').toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      (product['category'] ?? product['niche'] ?? '—').toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${(product['score'] ?? product['trend_score'] ?? product['performance_score'] ?? 0)}\nScore',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 10),
                        SizedBox(width: 2),
                        Text(
                          'TOP',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  'Prix fournisseur',
                  (product['supplier_price'] ?? product['cost'] ?? product['price'] ?? '—').toString(),
                  '/unité',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricBox(
                  'Prix de vente',
                  (product['sell_price'] ?? product['recommended_price'] ?? '—').toString(),
                  'recommandé',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  'Marge nette',
                  (product['margin'] ?? product['net_margin'] ?? product['margin_percent'] ?? '—').toString(),
                  '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricBox(
                  'Ventes/mois',
                  (product['monthly_sales'] ?? product['sales_per_month'] ?? product['sales'] ?? '—').toString(),
                  '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressBar('Tendance', 0.8, '${product['trend_score'] ?? ''}', Colors.orange),
          _buildProgressBar('Concurrence', 0.4, '${product['competition'] ?? ''}', Colors.green),
          _buildProgressBar('Demande', 0.7, '${product['demand'] ?? ''}', Colors.blue),
          _buildProgressBar('Fiabilité fournisseur', 0.75, '${product['supplier_reliability'] ?? ''}', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String value, String subValue) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(subValue, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(percentage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
