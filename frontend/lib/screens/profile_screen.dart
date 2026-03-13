import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'edit_profile_screen.dart';
import 'subscription_screen.dart';
import 'my_subscription_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';
import 'tableau_de_bord_screen.dart';
import 'badges_screen.dart';
import 'parrainage_screen.dart';
import 'mon_avatar_screen.dart';
import 'communaute_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String? email;

  const ProfileScreen({
    super.key,
    required this.userName,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                   _buildStats(userName),
                  const SizedBox(height: 24),
                  _buildSection('Préférences', [
                    _buildMenuItem(
                      icon: Icons.notifications_none_outlined,
                      title: 'Notifications',
                      subtitle: 'Alertes et tendances',
                      trailing: Switch(
                        value: true,
                        onChanged: (v) {},
                        activeColor: AppColors.primary,
                      ),
                      iconColor: Colors.blue,
                    ),
                    _buildMenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Confidentialité',
                      subtitle: 'Données et sécurité',
                      iconColor: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Support', [
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Centre d\'aide',
                      subtitle: 'FAQ et tutoriels',
                      iconColor: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SupportScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Passer à Pro',
                      subtitle: 'Débloquer toutes les fonctionnalités',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '-50%',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      iconColor: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Mes Activités', [
                    _buildMenuItem(
                      icon: Icons.bar_chart,
                      title: 'Tableau de Bord Activité',
                      subtitle: 'Mes statistiques',
                      iconColor: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TableauDeBordScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.emoji_events,
                      title: 'Badges & Progression',
                      subtitle: 'Tous mes succès',
                      iconColor: Colors.amber,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BadgesScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.people_alt_outlined,
                      title: 'Partenaires & Compétitions',
                      subtitle: 'Parrainage & récompenses',
                      iconColor: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ParrainageScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.face_retouching_natural,
                      title: 'Mon Avatar & Thèmes',
                      subtitle: 'Personnaliser mon profil',
                      iconColor: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MonAvatarScreen(
                              userName: userName,
                              email: email,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.group_outlined,
                      title: 'Communauté',
                      subtitle: 'Échanges et partages',
                      iconColor: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CommunauteScreen()),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back, color: Colors.white),
                const Text(
                  'Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          initialName: userName,
                          initialEmail: email,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (email != null && email!.isNotEmpty)
            Text(
              email!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MySubscriptionScreen(isPremium: true)),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Pro',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Actif jusqu\'au 20 nov. 2025',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStats(String name) {
    bool isGuest = name == 'Invité';
    String favorisCount = isGuest ? '0' : '12';
    String vistasCount = isGuest ? '0' : '847';
    String scoreCount = isGuest ? '0' : '87';

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(favorisCount, 'Favoris'),
          _buildDivider(),
          _buildStatItem(vistasCount, 'Vues'),
          _buildDivider(),
          _buildStatItem(scoreCount, 'Score'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red, size: 20),
            SizedBox(width: 12),
            Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
