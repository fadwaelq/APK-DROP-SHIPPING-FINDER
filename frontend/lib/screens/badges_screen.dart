import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  static const List<Map<String, dynamic>> _badges = [
    {
      'title': 'La Prospecteur',
      'desc': 'Produits top trouvés\nfacilement en réalité',
      'icon': Icons.search,
      'color': Colors.orange,
      'unlocked': true,
      'progress': 100,
    },
    {
      'title': 'Le Veilleur',
      'desc': '7 jours de veille\nconsécutifs',
      'icon': Icons.visibility,
      'color': Colors.blue,
      'unlocked': true,
      'progress': 100,
    },
    {
      'title': 'Ambitieux',
      'desc': 'Parrainage de 3\nadhérents au moins',
      'icon': Icons.people,
      'color': Colors.purple,
      'unlocked': false,
      'progress': 60,
    },
    {
      'title': 'Le Méga',
      'desc': 'Atteindre le niveau\nPlatinum Étoile',
      'icon': Icons.star,
      'color': Colors.amber,
      'unlocked': false,
      'progress': 40,
    },
    {
      'title': "L'Expert Filtres",
      'desc': 'Utiliser tous les\noutils de filtrage',
      'icon': Icons.filter_alt,
      'color': Colors.teal,
      'unlocked': false,
      'progress': 25,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _badges.where((b) => b['unlocked'] == true).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, unlockedCount),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUnlockedSection(),
                  const SizedBox(height: 24),
                  _buildLockedSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int unlockedCount) {
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
                const Expanded(
                  child: Text(
                    'Badges & Progression',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlockedCount badges de ${_badges.length} débloqués',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      'Continuez ainsi pour en obtenir davantage de Diamant',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildUnlockedSection() {
    final unlocked = _badges.where((b) => b['unlocked'] == true).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Badges obtenus',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: unlocked.map((badge) => _buildBadgeCard(badge)).toList(),
        ),
      ],
    );
  }

  Widget _buildLockedSection() {
    final locked = _badges.where((b) => b['unlocked'] == false).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'En cours / Verrouillés',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...locked.map((badge) => _buildLockedBadgeRow(badge)),
      ],
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (badge['color'] as Color).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (badge['color'] as Color).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge['icon'] as IconData,
              color: badge['color'] as Color,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            badge['title'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            badge['desc'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '✓ Obtenu',
              style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBadgeRow(Map<String, dynamic> badge) {
    final progress = (badge['progress'] as int) / 100.0;
    final color = badge['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  color: Colors.grey[400],
                  size: 22,
                ),
              ),
              const Positioned(
                bottom: 0,
                right: 0,
                child: Icon(Icons.lock, size: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  badge['desc'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    color: color,
                    backgroundColor: color.withOpacity(0.15),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${badge['progress']}% accompli',
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
