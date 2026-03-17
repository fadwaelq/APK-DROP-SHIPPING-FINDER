import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class TableauDeBordScreen extends StatefulWidget {
  const TableauDeBordScreen({super.key});

  @override
  State<TableauDeBordScreen> createState() => _TableauDeBordScreenState();
}

class _TableauDeBordScreenState extends State<TableauDeBordScreen> {
  String _selectedPeriod = '';
  Map<String, dynamic>? _dashboardStats;
  List<dynamic> _recentActivity = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final result = await ApiService().getDashboardStats();
    final activity = await ApiService().getDashboardRecentActivity();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _dashboardStats = result;
        }
        if (activity['success'] == true) {
          final data = activity['data'];
          _recentActivity = data is List
              ? data
              : (data is Map ? (data['results'] ?? data['data'] ?? const []) : const []);
        }
        _isLoading = false;
      });
    }
  }

  void _showRoiCalculator() {
    final cogsCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    final adsCtrl = TextEditingController();
    bool loading = false;
    Map<String, dynamic>? result;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('ROI Calculator',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sellCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix de vente',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cogsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Coût produit (COGS)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: adsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dépenses pub (Ads)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              if (result != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: loading
                      ? null
                      : () async {
                          final sell = double.tryParse(sellCtrl.text.trim());
                          final cogs = double.tryParse(cogsCtrl.text.trim());
                          final ads = double.tryParse(adsCtrl.text.trim());
                          if (sell == null || cogs == null || ads == null) {
                            setSheetState(() => error = 'Veuillez saisir des nombres valides.');
                            return;
                          }
                          setSheetState(() {
                            loading = true;
                            error = null;
                            result = null;
                          });
                          final res = await ApiService().calculateROI({
                            'sell_price': sell,
                            'cogs': cogs,
                            'ads_spend': ads,
                          });
                          if (!ctx.mounted) return;
                          setSheetState(() {
                            loading = false;
                            if (res['success'] == true) {
                              result = (res['data'] is Map)
                                  ? Map<String, dynamic>.from(res['data'])
                                  : <String, dynamic>{'data': res['data']};
                            } else {
                              error = res['message']?.toString() ?? 'Erreur ROI';
                            }
                          });
                        },
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Calculer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdsMonitoring() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => FutureBuilder<Map<String, dynamic>>(
          future: ApiService().getAdsMonitoring(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final res = snapshot.data!;
            if (res['success'] != true) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(res['message']?.toString() ?? 'Erreur Ads Monitoring',
                    style: const TextStyle(color: Colors.red)),
              );
            }
            final data = res['data'];
            final list = data is List
                ? data
                : (data is Map ? (data['results'] ?? data['data'] ?? const []) : const []);
            final items = List<Map<String, dynamic>>.from(list as List);
            if (items.isEmpty) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: const [
                  Text('Aucune donnée Ads Monitoring.',
                      style: TextStyle(color: Colors.grey)),
                ],
              );
            }
            return ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = items[i];
                final title = (a['title'] ?? a['name'] ?? a['ad_name'] ?? 'Annonce').toString();
                final meta = (a['platform'] ?? a['network'] ?? a['status'] ?? '').toString();
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  leading: const Icon(Icons.ads_click, color: AppColors.primary),
                  title: Text(title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: meta.isEmpty ? null : Text(meta, style: const TextStyle(fontSize: 11)),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showRecentActivity() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) {
          if (_recentActivity.isEmpty) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: const [
                Text('Aucune activité récente.',
                    style: TextStyle(color: Colors.grey)),
              ],
            );
          }
          return ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _recentActivity.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final raw = _recentActivity[i];
              final m = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{'data': raw};
              final title = (m['title'] ?? m['action'] ?? m['label'] ?? 'Activité').toString();
              final date = (m['created_at'] ?? m['date'] ?? m['time'] ?? '').toString();
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const Icon(Icons.history, color: AppColors.primary),
                title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: date.isEmpty ? null : Text(date, style: const TextStyle(fontSize: 11)),
              );
            },
          );
        },
      ),
    );
  }

  List<String> _getPeriods(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.period_this_week, l10n.period_this_month, l10n.period_total];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedPeriod.isEmpty) {
      _selectedPeriod = AppLocalizations.of(context)!.period_this_week;
    }
  }

  String _getTranslated(String text) {
    // Basic mapping for weekdays in chart
    if (text == 'Lun') return 'Lun'; // Simplified for now
    if (text == 'Mar') return 'Mar';
    if (text == 'Mer') return 'Mer';
    if (text == 'Jeu') return 'Jeu';
    if (text == 'Ven') return 'Ven';
    if (text == 'Sam') return 'Sam';
    if (text == 'Dim') return 'Dim';
    return text;
  }

  // Bar chart data (relative heights 0.0–1.0)
  final List<Map<String, dynamic>> _chartData = [
    {'day': 'Lun', 'value': 0.4},
    {'day': 'Mar', 'value': 0.6},
    {'day': 'Mer', 'value': 0.5},
    {'day': 'Jeu', 'value': 0.8},
    {'day': 'Ven', 'value': 0.7},
    {'day': 'Sam', 'value': 0.55},
    {'day': 'Dim', 'value': 0.3},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showAdsMonitoring,
                          icon: const Icon(Icons.ads_click, size: 18),
                          label: const Text('Ads'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showRoiCalculator,
                          icon: const Icon(Icons.calculate_outlined, size: 18),
                          label: const Text('ROI'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showRecentActivity,
                          icon: const Icon(Icons.history, size: 18),
                          label: const Text('Activité'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildChartCard(),
                  const SizedBox(height: 20),
                  _buildDetailedStats(),
                  const SizedBox(height: 20),
                  _buildSerieCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.dashboard_title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Top stat cards row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTopStatCard(
                  Icons.bar_chart, 
                  AppLocalizations.of(context)!.stat_analyzed, 
                  _isLoading ? '...' : (_dashboardStats?['total_activities']?.toString() ?? '0')
                ),
                _buildTopStatCard(
                  Icons.access_time, 
                  AppLocalizations.of(context)!.stat_support, 
                  '3h 20' // Keeping static for now as per backend response
                ),
                _buildTopStatCard(
                  Icons.fact_check_outlined, 
                  AppLocalizations.of(context)!.stat_tasks, 
                  _isLoading ? '...' : (_dashboardStats?['points_earned']?.toString() ?? '0')
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildTopStatCard(IconData icon, String label, String value) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = _getPeriods(context);
    return Row(
      children: periods.map((period) {
        final isSelected = period == _selectedPeriod;
        return GestureDetector(
          onTap: () => setState(() => _selectedPeriod = period),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)]
                  : [],
            ),
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.score_evolution,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _chartData.map((data) {
                return _buildBar(data['day'], data['value']);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 90 * value,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(_getTranslated(day), style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDetailedStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.detailed_stats_title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          icon: Icons.description_outlined,
          iconColor: Colors.blue,
          title: AppLocalizations.of(context)!.stat_detailed_analyzed,
          subtitle: AppLocalizations.of(context)!.since_beginning,
          value: _isLoading ? '...' : (_dashboardStats?['recent_searches']?.toString() ?? '0'),
          valueColor: AppColors.primary,
        ),
        const SizedBox(height: 10),
        _buildStatRow(
          icon: Icons.savings_outlined,
          iconColor: Colors.green,
          title: AppLocalizations.of(context)!.stat_detailed_economic,
          subtitle: AppLocalizations.of(context)!.total_time_label,
          value: '6h+489',
          valueColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSerieCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Colors.orange[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.streak_days_title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.streak_days_msg(7),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            '🔥 7',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
    );
  }
}
