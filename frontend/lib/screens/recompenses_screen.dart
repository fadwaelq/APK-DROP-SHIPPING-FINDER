import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
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

  // XP data (Missions) - Keep static as backend doesn't have it yet
  final int _currentXP = 310;
  final int _maxXP = 500;
  final int _level = 7;
  
  // Real data
  int _totalPoints = 0;
  List<Map<String, dynamic>> _badges = [];

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
      ]);

      final rewardsResult = results[0];
      final badgesResult = results[1];

      setState(() {
        if (rewardsResult['success'] == true) {
          _totalPoints = rewardsResult['data']?['points'] ?? 0;
        }

        if (badgesResult['success'] == true) {
          final List<dynamic> badgesData = badgesResult['data'] ?? [];
          _badges = badgesData.map((b) => {
            'title': b['title'] ?? 'Sans Titre',
            'desc': b['description'] ?? 'Pas de description',
            'icon': _getIconData(b['icon_name']),
            'color': _getColor(b['color_hex']),
            'unlocked': b['is_unlocked'] ?? false,
            'progress': b['progress_percentage'] ?? 0,
          }).toList();
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

  IconData _getIconData(String? name) {
    switch (name) {
      case 'search': return Icons.search;
      case 'visibility': return Icons.visibility;
      case 'people': return Icons.people;
      case 'star': return Icons.star;
      case 'filter': return Icons.filter_alt;
      default: return Icons.emoji_events;
    }
  }

  Color _getColor(String? hex) {
    if (hex == null) return Colors.blue;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  String _getTranslated(String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'mission_analyze': return l10n.mission_analyze(2);
      case 'mission_share': return l10n.mission_share;
      case 'mission_report': return l10n.mission_report;
      case 'mission_fav': return l10n.mission_fav;
      case 'mission_event': return l10n.mission_event;
      case 'reward_pro': return l10n.reward_pro;
      case 'reward_pro_desc': return l10n.reward_pro_desc;
      case 'reward_trend': return l10n.reward_trend;
      case 'reward_trend_desc': return l10n.reward_trend_desc;
      case 'reward_social': return l10n.reward_social;
      case 'reward_social_desc': return l10n.reward_social_desc;
      case 'reward_bonus': return l10n.reward_bonus;
      case 'reward_bonus_desc': return l10n.reward_bonus_desc;
      case 'success_report': return l10n.success_report;
      case 'success_report_desc': return l10n.success_report_desc;
      case 'success_badge': return l10n.success_badge;
      case 'success_badge_desc': return l10n.success_badge_desc;
      case 'success_vip': return l10n.success_vip;
      case 'success_vip_desc': return l10n.success_vip_desc;
      case 'success_boost': return l10n.success_boost;
      case 'success_boost_desc': return l10n.success_boost_desc;
      case 'tag_new': return l10n.tag_new;
      default: return key;
    }
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
      'title': 'mission_analyze',
      'points': 20,
      'progress': 0.5,
      'done': false,
    },
    {
      'icon': Icons.trending_up,
      'title': 'mission_share',
      'points': 61,
      'progress': 1.0,
      'done': true,
    },
    {
      'icon': Icons.bar_chart,
      'title': 'mission_report',
      'points': 30,
      'progress': 0.0,
      'done': false,
    },
  ];

  // Weekly missions
  static final List<Map<String, dynamic>> _weeklyMissions = [
    {
      'icon': Icons.favorite_border,
      'title': 'mission_fav',
      'points': 100,
      'progress': 0.4,
      'done': false,
    },
    {
      'icon': Icons.people_alt_outlined,
      'title': 'mission_event',
      'points': 88,
      'progress': 0.7,
      'done': false,
    },
  ];

  // Rewards catalogue
  static final List<Map<String, dynamic>> _rewards = [
    {
      'icon': Icons.analytics_outlined,
      'title': 'reward_pro',
      'desc': 'reward_pro_desc',
      'cost': 500,
      'unlocked': true,
      'color': Colors.orange,
    },
    {
      'icon': Icons.trending_up,
      'title': 'reward_trend',
      'desc': 'reward_trend_desc',
      'cost': 1000,
      'unlocked': false,
      'color': Colors.blue,
    },
    {
      'icon': Icons.lock_open_outlined,
      'title': 'reward_social',
      'desc': 'reward_social_desc',
      'cost': 800,
      'unlocked': false,
      'color': Colors.purple,
    },
    {
      'icon': Icons.star_border_outlined,
      'title': 'reward_bonus',
      'desc': 'reward_bonus_desc',
      'cost': 1200,
      'unlocked': false,
      'color': Colors.amber,
    },
  ];

  // Badges (Succès tab)
  static final List<Map<String, dynamic>> _successes = [
    {
      'icon': Icons.bar_chart,
      'title': 'success_report',
      'desc': 'success_report_desc',
      'tag': 'tag_new',
      'tagColor': Colors.orange,
      'points': 500,
      'canClaim': true,
    },
    {
      'icon': Icons.emoji_events,
      'title': 'success_badge',
      'desc': 'success_badge_desc',
      'tag': null,
      'tagColor': null,
      'points': 800,
      'canClaim': true,
    },
    {
      'icon': Icons.event,
      'title': 'success_vip',
      'desc': 'success_vip_desc',
      'tag': 'tag_new',
      'tagColor': Colors.orange,
      'points': 600,
      'canClaim': true,
    },
    {
      'icon': Icons.bolt,
      'title': 'success_boost',
      'desc': 'success_boost_desc',
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
                            Text('$_totalPoints', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
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
                      child: _buildSmallButton(Icons.home_work_outlined, 'Boutique', Colors.white, Colors.black87),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallButton(Icons.history, 'Historique', Colors.white.withOpacity(0.2), Colors.white),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('350 / 500 XP', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('+70%', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
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
