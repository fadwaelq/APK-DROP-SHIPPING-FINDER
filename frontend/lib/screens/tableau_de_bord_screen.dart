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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final result = await ApiService().getDashboardStats();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _dashboardStats = result;
        }
        _isLoading = false;
      });
    }
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
    final l10n = AppLocalizations.of(context)!;
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
