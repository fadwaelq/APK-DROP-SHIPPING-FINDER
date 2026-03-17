import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../services/favorites_manager.dart';
import '../services/api_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductDetailsScreen({super.key, this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ApiService _apiService = ApiService();

  late String _currentImageUrl;
  int _selectedColorIndex = 0;

  // ── API data
  Map<String, dynamic> _performance = {};
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingExtras = true;

  final List<Map<String, dynamic>> _colorOptions = [
    {
      'color': const Color(0xFFFFCCAA),
      'image':
          'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    },
    {
      'color': const Color(0xFF00C853),
      'image':
          'https://images.unsplash.com/photo-1546435770-a3e426ff472b?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    },
    {
      'color': const Color(0xFF2196F3),
      'image':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    },
    {
      'color': const Color(0xFFE91E63),
      'image':
          'https://images.unsplash.com/photo-1484704849700-f032a568e944?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentImageUrl =
        widget.product?['imageUrl'] ?? _colorOptions[0]['image'];
    _fetchProductAnalytics();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DATA
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _fetchProductAnalytics() async {
    final id = widget.product?['id']?.toString();
    if (id == null) {
      setState(() => _loadingExtras = false);
      return;
    }

    final results = await Future.wait([
      _apiService.getProductPerformance(id), // index 0
      _apiService.getProductSuppliers(id),   // index 1
      _apiService.getProductReviews(id),     // index 2
    ]);

    if (!mounted) return;

    // Performance
    if (results[0]['success'] == true) {
      final d = results[0]['data'] ?? results[0];
      if (d is Map) setState(() => _performance = Map<String, dynamic>.from(d));
    }

    // Suppliers
    if (results[1]['success'] == true) {
      final d = results[1]['data'];
      if (d is List) {
        setState(() =>
            _suppliers = List<Map<String, dynamic>>.from(d));
      }
    }

    // Reviews
    if (results[2]['success'] == true) {
      final d = results[2]['data'];
      if (d is List) {
        setState(() =>
            _reviews = List<Map<String, dynamic>>.from(d));
      }
    }

    setState(() => _loadingExtras = false);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────────────────────────────────────

  void _showContactDialog(Map<String, dynamic> supplier) {
    final msgController = TextEditingController();
    final id = widget.product?['id']?.toString() ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Contacter ${supplier['name'] ?? 'le fournisseur'}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: TextField(
          controller: msgController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Votre message...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final msg = msgController.text.trim();
              Navigator.pop(ctx);
              if (msg.isEmpty || id.isEmpty) return;
              final res = await _apiService.contactSupplier(id, {
                'message': msg,
                'supplier_id': supplier['id'],
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(res['success'] == true
                    ? 'Message envoyé au fournisseur !'
                    : res['message'] ?? 'Erreur d\'envoi'),
                backgroundColor:
                    res['success'] == true ? AppColors.primary : Colors.red,
              ));
            },
            child: const Text('Envoyer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.product?['title'] ?? l10n.product_title_fallback;
    final price = widget.product?['price'] ?? '29.99€';
    final profit = widget.product?['profit'] ?? '15.50€';
    final scoreStr = widget.product?['score']
            ?.toString()
            .replaceAll('Score: ', '') ??
        '95';

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
              builder: (context, _, __) {
                final isFav = FavoritesManager().isFavorite(widget.product!);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.primary : AppColors.textPrimary,
                  ),
                  onPressed: () =>
                      FavoritesManager().toggleFavorite(widget.product!),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.favorite_border,
                  color: AppColors.textPrimary),
              onPressed: () {},
            ),
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: AppColors.textPrimary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image & Colors
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
                    children: List.generate(
                      _colorOptions.length,
                      (i) => _buildColorDot(_colorOptions[i]['color'], index: i),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Basic Info
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
                                  color: AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                l10n.audio_tech_category,
                                style: const TextStyle(
                                    color: Colors.purple,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Text(l10n.score,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.3))),
                            child: Text(scoreStr,
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.product_desc_fallback,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceBox(
                          icon: Icons.sell_outlined,
                          iconColor: AppColors.primary,
                          bgColor: Colors.white,
                          label: l10n.selling_price,
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
                          bgColor: const Color(0xFFF1F8F5),
                          label: l10n.estimated_profit,
                          value: profit,
                          valueColor: Colors.green,
                          borderColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Performance (from getProductPerformance)
            _buildSectionCard(
              child: _loadingExtras
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator()))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bar_chart,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.performance_analysis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildProgressBar(
                          l10n.demand_label,
                          _scoreToPercent(_performance['demand_score']),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressBar(
                          l10n.profitability_label,
                          _scoreToPercent(_performance['profitability_score']),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressBar(
                          l10n.competition_label,
                          _scoreToPercent(_performance['competition_score']),
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressBar(
                          l10n.trend_label,
                          _scoreToPercent(_performance['trend_score'] ??
                              _performance['trending_score']),
                        ),
                        // Overall score badge
                        if (_performance['overall_score'] != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars,
                                    color: AppColors.primary, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Score global : ${_performance['overall_score']}/100',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
            ),

            // ── Market Insights
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.market_insights,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _buildInsightRow(
                    icon: Icons.trending_up,
                    iconColor: Colors.green,
                    bgColor: const Color(0xFFE8F5E9),
                    title: l10n.trending_up_label,
                    subtitle: '+45% de recherches cette semaine',
                  ),
                  const SizedBox(height: 12),
                  _buildInsightRow(
                    icon: Icons.people_outline,
                    iconColor: Colors.blue,
                    bgColor: const Color(0xFFE3F2FD),
                    title: l10n.strong_demand_label,
                    subtitle: l10n.monthly_sales_est('15'),
                  ),
                  const SizedBox(height: 12),
                  _buildInsightRow(
                    icon: Icons.attach_money,
                    iconColor: AppColors.primary,
                    bgColor: const Color(0xFFFFF8F3),
                    title: l10n.large_margin_label,
                    subtitle: l10n.profit_margin_est('51'),
                  ),
                ],
              ),
            ),

            // ── Suppliers (from getProductSuppliers)
            _buildSectionCard(
              child: _loadingExtras
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator()))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.supplier_label,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        if (_suppliers.isEmpty)
                          _buildDefaultSupplierRow(context, l10n)
                        else
                          ..._suppliers
                              .take(3)
                              .map((s) => _buildSupplierRow(s))
                              .toList(),
                      ],
                    ),
            ),

            // ── Reviews (from getProductReviews)
            if (!_loadingExtras && _reviews.isNotEmpty)
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.rate_review_outlined,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text('Avis clients',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._reviews.take(5).map((r) => _buildReviewRow(r)),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER: score → percent string
  // ─────────────────────────────────────────────────────────────────────────────

  String _scoreToPercent(dynamic value) {
    if (value == null) return '—';
    final d = double.tryParse(value.toString()) ?? 0;
    return '${d.toStringAsFixed(0)}%';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SUB-WIDGETS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildDefaultSupplierRow(
      BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child:
                  const Icon(Icons.storefront, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AliExpress Premium',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(
                          4,
                          (_) => const Icon(Icons.star,
                              color: Colors.orange, size: 12)),
                      Icon(Icons.star_half,
                          color: Colors.orange.withOpacity(0.5), size: 12),
                      const SizedBox(width: 4),
                      Text(l10n.reviews_count('4.8', '2.5K'),
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showContactDialog({}),
                icon: const Icon(Icons.chat_bubble_outline,
                    size: 16, color: AppColors.primary),
                label: Text(l10n.contact_btn,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new,
                    size: 16, color: Colors.white),
                label: Text(l10n.view_btn,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Text(l10n.supplier_price,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              const Text('14.49 €',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              const Text('(MOQ: 10 pcs)',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  // Real supplier row from API
  Widget _buildSupplierRow(Map<String, dynamic> supplier) {
    final name     = supplier['name']     as String? ?? 'Fournisseur';
    final rating   = supplier['rating']?.toString()   ?? '—';
    final reviews  = supplier['reviews_count']?.toString() ?? '—';
    final price    = supplier['price']?.toString()    ?? supplier['unit_price']?.toString() ?? '—';
    final moq      = supplier['moq']?.toString()      ?? '';
    final platform = supplier['platform'] as String?  ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF0F0F0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.storefront,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    if (platform.isNotEmpty)
                      Text(platform,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary)),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.orange, size: 12),
                        const SizedBox(width: 2),
                        Text('$rating ($reviews avis)',
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  if (moq.isNotEmpty)
                    Text('MOQ: $moq',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showContactDialog(supplier),
                  icon: const Icon(Icons.chat_bubble_outline,
                      size: 14, color: AppColors.primary),
                  label: const Text('Contacter',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new,
                      size: 14, color: Colors.white),
                  label: const Text('Voir offre',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Real review row from API
  Widget _buildReviewRow(Map<String, dynamic> review) {
    final author  = review['author']   as String? ?? review['username'] as String? ?? 'Client';
    final content = review['content']  as String? ?? review['text'] as String? ?? '';
    final rating  = (review['rating'] as num?)?.toDouble() ?? 0.0;
    final date    = review['date']     as String? ?? review['created_at'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(author,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating.round() ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(content,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ],
          if (date.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(date,
                style: const TextStyle(
                    fontSize: 10, color: Colors.grey)),
          ],
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color, {required int index}) {
    final isSelected = _selectedColorIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedColorIndex = index;
        _currentImageUrl = _colorOptions[index]['image'];
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: isSelected
            ? const Center(
                child: Icon(Icons.check, size: 16, color: Colors.white))
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
              offset: const Offset(0, 4)),
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
          border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, String percentage,
      {Color color = AppColors.primary}) {
    double widthFactor =
        double.tryParse(percentage.replaceAll('%', '')) ?? 0;
    widthFactor = widthFactor / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            Text(percentage,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3)),
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
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
