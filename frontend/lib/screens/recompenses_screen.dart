import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';

class RecompensesScreen extends StatefulWidget {
  const RecompensesScreen({super.key});

  @override
  State<RecompensesScreen> createState() => _RecompensesScreenState();
}

class _RecompensesScreenState extends State<RecompensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  // Real data
  int _totalPoints = 0;
  int _coinsBalance = 0;
  int _xp = 0;
  List<Map<String, dynamic>> _missions = [];
  List<Map<String, dynamic>> _shopItems = [];

  // Bloc 5 — Transaction log
  List<Map<String, dynamic>> _transactionLog = [];
  bool _loadingLog = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getRewards(),
        _apiService.getUserBadges(),
        _apiService.getCoinsBalance(),
        _apiService.getUserXP(),
        _apiService.getDailyMissions(),
        _apiService.getShopItems(),
      ]);

      final rewardsResult = results[0];
      // badgesResult is fetched for consistency; UI shows badges elsewhere
      final coinsResult = results[2];
      final xpResult = results[3];
      final missionsResult = results[4];
      final shopResult = results[5];

      setState(() {
        if (rewardsResult['success'] == true) {
          _totalPoints = rewardsResult['data']?['points'] ?? 0;
        }
        if (coinsResult['success'] == true) {
          final d = coinsResult['data'];
          _coinsBalance = (d is Map ? (d['balance'] ?? d['coins'] ?? d['amount']) : d) as int? ?? _coinsBalance;
        }
        if (xpResult['success'] == true) {
          final d = xpResult['data'];
          _xp = (d is Map ? (d['xp'] ?? d['total_xp'] ?? d['value']) : d) as int? ?? _xp;
        }
        if (missionsResult['success'] == true) {
          final raw = missionsResult['data'];
          final list = raw is List ? raw : (raw is Map ? (raw['results'] ?? raw['data'] ?? const []) : const []);
          _missions = List<Map<String, dynamic>>.from(list as List);
        }
        if (shopResult['success'] == true) {
          final raw = shopResult['data'];
          final list = raw is List ? raw : (raw is Map ? (raw['results'] ?? raw['data'] ?? const []) : const []);
          _shopItems = List<Map<String, dynamic>>.from(list as List);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Bloc 5: load transaction log
  Future<void> _loadTransactionLog() async {
    setState(() => _loadingLog = true);
    final res = await _apiService.getCoinsTransactionLog();
    if (!mounted) return;
    if (res['success'] == true) {
      final raw = res['data'];
      setState(() {
        _transactionLog = raw is List
            ? List<Map<String, dynamic>>.from(raw)
            : [];
      });
    }
    setState(() => _loadingLog = false);
  }

  // ── Bloc 5: show transaction log bottom sheet
  void _showTransactionLog() async {
    if (_transactionLog.isEmpty) await _loadTransactionLog();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Historique de Transactions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (_loadingLog)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_transactionLog.isEmpty)
              const Expanded(
                  child: Center(
                      child: Text('Aucune transaction', style: TextStyle(color: Colors.grey))))
            else
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _transactionLog.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final tx = _transactionLog[i];
                    final amount  = tx['amount']?.toString()  ?? '0';
                    final type    = tx['type']    as String?   ?? tx['action'] as String? ?? 'transaction';
                    final date    = tx['date']    as String?   ?? tx['created_at'] as String? ?? '';
                    final note    = tx['note']    as String?   ?? tx['description'] as String?;
                    final isCredit = (tx['amount'] as num? ?? 0) >= 0;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            isCredit ? Colors.green.shade50 : Colors.red.shade50,
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 16,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        type,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      subtitle: note != null
                          ? Text(note,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey))
                          : (date.isNotEmpty
                              ? Text(date,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey))
                              : null),
                      trailing: Text(
                        '${isCredit ? '+' : ''}$amount 🪙',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Bloc 5: coins transfer dialog
  void _showTransferDialog() {
    final recipientCtrl = TextEditingController();
    final amountCtrl    = TextEditingController();
    final noteCtrl      = TextEditingController();
    bool sending = false;

    showDialog(
      context: context,
      barrierDismissible: !sending,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.send_to_mobile, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Transférer des Coins',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: recipientCtrl,
                decoration: InputDecoration(
                  hintText: 'Nom d\'utilisateur destinataire',
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Montant (coins)',
                  prefixIcon: const Icon(Icons.generating_tokens, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  hintText: 'Note (optionnel)',
                  prefixIcon: const Icon(Icons.note_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: sending ? null : () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: sending
                  ? null
                  : () async {
                      final recipient = recipientCtrl.text.trim();
                      final amount    = int.tryParse(amountCtrl.text.trim());
                      final note      = noteCtrl.text.trim();
                      if (recipient.isEmpty || amount == null || amount <= 0) {
                        return;
                      }
                      setDialogState(() => sending = true);
                      final res = await _apiService.transferCoins(
                        recipientUsername: recipient,
                        amount: amount,
                        note: note.isEmpty ? null : note,
                      );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(res['success'] == true
                            ? 'Transfert de $amount coins envoyé à $recipient !'
                            : res['message'] ?? 'Erreur lors du transfert'),
                        backgroundColor:
                            res['success'] == true ? AppColors.primary : Colors.red,
                      ));
                      if (res['success'] == true) _fetchData();
                    },
              child: sending
                  ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Transférer',
                      style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Daily missions
// Les données statiques et la méthode _getTranslated ont été supprimées car elles provoquaient des avertissements d'analyse.
// Le contenu des onglets utilise désormais des textes en dur pour l'instant.


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 11), textAlign: TextAlign.center),
                    ),
                  _buildLevelCard(),
                  _buildTabBar(),
                  const SizedBox(height: 10),
                  // Tab content manually handled to avoid TabBarView height issues in SingleChildScrollView
                  if (_tabController.index == 0) _buildMissionsTab(),
                  if (_tabController.index == 1) _buildSuccessTab(),
                  if (_tabController.index == 2) _buildBoutiqueTab(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          // Navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: -1,
              onTap: (index) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                child: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
              ),
              const Text(
                'Récompenses',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.wallet_giftcard, color: Colors.orange, size: 24),
            ],
          ),
          const SizedBox(height: 25),
          // Orange Reward Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9A3E), Color(0xFFFF4D00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Solde de Coins', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.generating_tokens, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text('${_coinsBalance != 0 ? _coinsBalance : _totalPoints}',
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.emoji_events, color: Colors.white, size: 40),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    _buildTopStat(Icons.local_fire_department, 'Série active', '12 jours 🔥'),
                    const Spacer(),
                    _buildTopStat(Icons.add_circle_outline, 'Bonus', '+120 coins/jour'),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _showTransferDialog,
                        child: _buildSmallButton(Icons.send_to_mobile, 'Transférer', Colors.white, Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _showTransactionLog,
                        child: _buildSmallButton(Icons.history, 'Historique', Colors.white.withOpacity(0.2), Colors.white),
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

  Widget _buildTopStat(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildSmallButton(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Niveau 7', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Elite Trader', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$_xp / 500 XP', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('+${(_xp / 5).round()}%', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)),
              ),
              Container(
                height: 10,
                width: MediaQuery.of(context).size.width * 0.5, // 70% roughly
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.orange, Colors.amber]),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('150 XP pour niveau 8', style: TextStyle(color: Colors.grey, fontSize: 11)),
              Text('+50 coins bonus', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Missions', 'Succès', 'Boutique'];
    final icons = [Icons.track_changes, Icons.emoji_events_outlined, Icons.storefront_outlined];
    
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          bool isSelected = _tabController.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabController.index = i),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isSelected 
                    ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                    : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[i], size: 16, color: isSelected ? Colors.orange : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      tabs[i],
                      style: TextStyle(
                        color: isSelected ? Colors.black87 : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── MISSIONS Tab ──────────────────────────────────────────────────────────
  Widget _buildMissionsTab() {
    // If API missions exist, render them; else keep static fallback
    if (_missions.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Missions Quotidiennes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            ..._missions.map((m) {
              final id = (m['id'] ?? m['mission_id'] ?? '').toString();
              final title = (m['title'] ?? m['name'] ?? 'Mission').toString();
              final progress = (m['progress'] as num?)?.toDouble() ?? 0.0;
              final reward = (m['reward'] ?? m['reward_label'] ?? m['coins_reward'] ?? '').toString();
              final done = (m['is_completed'] == true) || (m['done'] == true);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          if (!done)
                            ElevatedButton(
                              onPressed: id.isEmpty
                                  ? null
                                  : () async {
                                      final res = await _apiService.completeMission(id);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(res['success'] == true
                                            ? 'Mission validée'
                                            : (res['message'] ?? 'Erreur mission')),
                                        backgroundColor: res['success'] == true ? AppColors.primary : Colors.red,
                                      ));
                                      if (res['success'] == true) _fetchData();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                elevation: 0,
                              ),
                              child: const Text('Valider', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            )
                          else
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (reward.isNotEmpty)
                        Text(reward, style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Missions Quotidiennes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('Se réinitialise dans 14h', style: TextStyle(color: Colors.green.shade600, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          _buildMissionCard('Analyser 3 produits aujourd\'hui', '2/3', '+30 coins | +25 XP', 0.66),
          const SizedBox(height: 12),
          _buildMissionCard('Partager une tendance', '0/1', '+50 coins | +40 XP', 0.0),
        ],
      ),
    );
  }

  Widget _buildMissionCard(String title, String status, String reward, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.arrow_upward, size: 12, color: Colors.orange),
              const SizedBox(width: 4),
              Text(reward, style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(3))),
              Container(
                height: 6,
                width: 200 * progress, // Simplified
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(3)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              _buildLargeFeatureCard(Icons.center_focus_strong, 'Premier Produit', 'Ajoutez votre premier produit', '50 coins', Colors.orange),
              const SizedBox(width: 15),
              _buildLargeFeatureCard(Icons.local_fire_department, 'Veilleur Actif', '7 jours consécutifs', '100 coins', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeFeatureCard(IconData icon, String title, String subtitle, String reward, Color color) {
    return Expanded(
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 15),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            const Spacer(),
            Text(reward, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── BOUTIQUE Tab ──────────────────────────────────────────────────────────
  Widget _buildBoutiqueTab() {
    if (_shopItems.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1D5CFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Votre solde', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.generating_tokens, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text('${_coinsBalance != 0 ? _coinsBalance : _totalPoints}',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.card_giftcard, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._shopItems.map((it) {
              final title = (it['title'] ?? it['name'] ?? 'Item').toString();
              final desc = (it['description'] ?? it['subtitle'] ?? '').toString();
              final cost = (it['cost'] ?? it['price'] ?? it['coins'] ?? 0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront_outlined, color: Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (desc.isNotEmpty)
                              Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.generating_tokens, size: 12, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text('$cost', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final res = await _apiService.spendCoins('shop_purchase', (cost as num).toInt());
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(res['success'] == true ? 'Achat réussi' : (res['message'] ?? 'Erreur achat')),
                                backgroundColor: res['success'] == true ? AppColors.primary : Colors.red,
                              ));
                              if (res['success'] == true) _fetchData();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Acheter', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1D5CFF), // Blue card
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Votre solde', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.generating_tokens, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text('1 350', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.card_giftcard, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _buildShopItem(Icons.bar_chart, 'Rapport Premium', 'Analyse détaillée de vos produits', '500', Colors.blue, 'POPULAIRE'),
          const SizedBox(height: 12),
          _buildShopItem(Icons.workspace_premium, 'Badge Exclusif', 'Affichez votre statut d\'expert', '1200', Colors.amber),
        ],
      ),
    );
  }

  Widget _buildShopItem(IconData icon, String title, String subtitle, String price, Color color, [String? badge]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
             child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (badge != null) ...[
                       const SizedBox(width: 8),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                         child: Text(badge, style: const TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                       ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.generating_tokens, size: 12, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                child: const Text('Acheter', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
