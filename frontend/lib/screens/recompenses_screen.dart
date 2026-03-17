import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RecompensesScreen extends StatefulWidget {
  const RecompensesScreen({super.key});

  @override
  State<RecompensesScreen> createState() => _RecompensesScreenState();
}

class _RecompensesScreenState extends State<RecompensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // XP data
  final int _currentXP = 310;
  final int _maxXP = 500;
  final int _level = 7;
  final int _totalPoints = 1350;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Daily missions
  static final List<Map<String, dynamic>> _dailyMissions = [
    {
      'icon': Icons.search,
      'title': 'Analyser 2 produits aujourd\'hui',
      'points': 20,
      'progress': 0.5,
      'done': false,
    },
    {
      'icon': Icons.trending_up,
      'title': 'Partager une tendance',
      'points': 61,
      'progress': 1.0,
      'done': true,
    },
    {
      'icon': Icons.bar_chart,
      'title': 'Consulter le rapport hebdomadaire',
      'points': 30,
      'progress': 0.0,
      'done': false,
    },
  ];

  // Weekly missions
  static final List<Map<String, dynamic>> _weeklyMissions = [
    {
      'icon': Icons.favorite_border,
      'title': 'Ajouter 5 produits aux favoris',
      'points': 100,
      'progress': 0.4,
      'done': false,
    },
    {
      'icon': Icons.people_alt_outlined,
      'title': 'Participer à un événement',
      'points': 88,
      'progress': 0.7,
      'done': false,
    },
  ];

  // Rewards catalogue
  static final List<Map<String, dynamic>> _rewards = [
    {
      'icon': Icons.analytics_outlined,
      'title': 'Analyse Pro',
      'desc': 'Analyse approfondie de produits',
      'cost': 500,
      'unlocked': true,
      'color': Colors.orange,
    },
    {
      'icon': Icons.trending_up,
      'title': 'Tendances Avancé',
      'desc': 'Accès tendances avancées',
      'cost': 1000,
      'unlocked': false,
      'color': Colors.blue,
    },
    {
      'icon': Icons.lock_open_outlined,
      'title': 'Social Dev',
      'desc': 'Développeur réseaux sociaux',
      'cost': 800,
      'unlocked': false,
      'color': Colors.purple,
    },
    {
      'icon': Icons.star_border_outlined,
      'title': 'Bonus Diamant',
      'desc': 'Récompense exclusive',
      'cost': 1200,
      'unlocked': false,
      'color': Colors.amber,
    },
  ];

  // Badges (Succès tab)
  static final List<Map<String, dynamic>> _successes = [
    {
      'icon': Icons.bar_chart,
      'title': 'Rapport Premium',
      'desc': 'Analyse de tous les produits',
      'tag': 'Nouveau',
      'tagColor': Colors.orange,
      'points': 500,
      'canClaim': true,
    },
    {
      'icon': Icons.emoji_events,
      'title': 'Badge Exclusif',
      'desc': 'Badge pour les élite',
      'tag': null,
      'tagColor': null,
      'points': 800,
      'canClaim': true,
    },
    {
      'icon': Icons.event,
      'title': 'Accès VIP Événement',
      'desc': 'Accès prioritaire aux événements',
      'tag': 'Nouveau',
      'tagColor': Colors.orange,
      'points': 600,
      'canClaim': true,
    },
    {
      'icon': Icons.bolt,
      'title': 'Boost XP x2',
      'desc': 'Double XP pendant 24h',
      'tag': null,
      'tagColor': null,
      'points': 400,
      'canClaim': true,
    },
    {
      'icon': Icons.dark_mode_outlined,
      'title': 'Thème Dark Mode',
      'desc': 'Thème personnalisé exclusif',
      'tag': null,
      'tagColor': null,
      'points': 350,
      'canClaim': false,
    },
    {
      'icon': Icons.analytics_outlined,
      'title': 'Analytics Pro',
      'desc': 'Tableau de bord avancé',
      'tag': null,
      'tagColor': null,
      'points': 1000,
      'canClaim': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMissionsTab(),
                _buildSuccessTab(),
                _buildBoutiqueTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Text(
                'Récompenses',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wallet_giftcard, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Points score
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('Score de Coins', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '$_totalPoints',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeaderStat('Salle série', '12 jours ↑'),
                    Container(width: 1, height: 30, color: Colors.white30),
                    _buildHeaderStat('Bonus ce mois', '45 points ↑'),
                  ],
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Échanger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Historique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // XP level bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text('Niveau $_level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                const Text('Élite Trader', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const Spacer(),
                Text('$_currentXP/$_maxXP XP', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _currentXP / _maxXP,
              color: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.3),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('74% all niveau 8', style: TextStyle(color: Colors.white70, fontSize: 10)),
              TextButton(
                onPressed: () {},
                child: const Text('Voir toutes récompenses ›', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: 'Missions'),
          Tab(text: 'Succès'),
          Tab(text: 'Boutique'),
        ],
      ),
    );
  }

  // ── MISSIONS Tab ──────────────────────────────────────────────────────────
  Widget _buildMissionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionSection('Missions Quotidiennes', _dailyMissions, true),
          const SizedBox(height: 20),
          _buildMissionSection('Missions Hebdomadaires', _weeklyMissions, false),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMissionSection(String title, List<Map<String, dynamic>> missions, bool daily) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (daily)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Se réinitialise dans 8h',
                  style: TextStyle(color: AppColors.primary, fontSize: 10),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...missions.map((m) => _buildMissionRow(m)),
      ],
    );
  }

  Widget _buildMissionRow(Map<String, dynamic> m) {
    final done = m['done'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: done ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(m['icon'] as IconData, size: 20, color: done ? Colors.green : AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: m['progress'] as double,
                    color: done ? Colors.green : AppColors.primary,
                    backgroundColor: Colors.grey[200],
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text('+${m['points']}', style: TextStyle(fontWeight: FontWeight.bold, color: done ? Colors.green : AppColors.primary, fontSize: 13)),
              const Text('pts', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ── SUCCÈS Tab ────────────────────────────────────────────────────────────
  Widget _buildSuccessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Votre total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFF9A3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text('$_totalPoints', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Récompenses disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ..._successes.map((s) => _buildSuccessRow(s)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSuccessRow(Map<String, dynamic> s) {
    final canClaim = s['canClaim'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(s['icon'] as IconData, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (s['tag'] != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (s['tagColor'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          s['tag'] as String,
                          style: TextStyle(color: s['tagColor'] as Color, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(s['desc'] as String, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.emoji_events, size: 13, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text('${s['points']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canClaim ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canClaim ? AppColors.primary : Colors.grey[300],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              canClaim ? 'Obtenir' : 'Indisponible',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOUTIQUE Tab ──────────────────────────────────────────────────────────
  Widget _buildBoutiqueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Solde: $_totalPoints coins',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Récompenses disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
            children: _rewards.map((r) => _buildRewardCard(r)).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> r) {
    final unlocked = r['unlocked'] as bool;
    final color = r['color'] as Color;
    final canAfford = _totalPoints >= (r['cost'] as int);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: unlocked ? color.withOpacity(0.15) : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    r['icon'] as IconData,
                    size: 28,
                    color: unlocked ? color : Colors.grey[400],
                  ),
                ),
              ),
              if (!unlocked)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(Icons.lock, size: 14, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(r['title'] as String, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(r['desc'] as String, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 13, color: AppColors.primary),
              const SizedBox(width: 3),
              Text('${r['cost']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (!unlocked && canAfford) ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: unlocked ? Colors.green : (canAfford ? color : Colors.grey[300]),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: Size.zero,
              ),
              child: Text(
                unlocked ? '✓ Obtenu' : (canAfford ? 'Acheter' : 'Insuffisant'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
