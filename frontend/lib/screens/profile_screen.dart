import 'dart:io';
import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'edit_profile_screen.dart';
import 'mon_avatar_screen.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../services/favorites_manager.dart';
import '../models/user_model.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String? email;

  const ProfileScreen({
    super.key,
    required this.userName,
    this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _dashboardStats;
  bool _isLoadingStats = true;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _loadSavedAvatar();
  }

  Future<void> _loadSavedAvatar() async {
    // We now sync with backend on init to ensure sources are correct
    if (mounted) {
      final session = Provider.of<SessionManager>(context, listen: false);
      if (session.isLoggedIn) {
        final result = await ApiService().getUserProfileV2();
        if (result['success'] == true) {
          final updatedUser = UserModel.fromJson(result['data'] ?? result);
          await session.setUser(updatedUser);
          setState(() {
            _avatarUrl = updatedUser.avatarUrl;
          });
        }
      }
    }
  }

  Future<void> _fetchStats() async {
    final result = await ApiService().getDashboardStats();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _dashboardStats = result;
        }
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<SessionManager>(
        builder: (context, session, _) {
          final user = session.user;
          final displayUserName = user?.fullName ?? widget.userName;
          final displayEmail = user?.email ?? widget.email;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, user, displayUserName, displayEmail),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildStats(displayUserName, user),
                      const SizedBox(height: 24),
                      _buildSection(AppLocalizations.of(context)!.pref_title, [
                        _buildMenuItem(
                          icon: Icons.notifications_none_outlined,
                          title: 'Notifications',
                          subtitle: 'Alertes et tendances',
                          trailing: Switch(
                            value: true,
                            onChanged: (v) {},
                            activeThumbColor: AppColors.primary,
                          ),
                          iconColor: Colors.blue,
                        ),
                        _buildMenuItem(
                          icon: Icons.shield_outlined,
                          title: 'Confidentialité',
                          subtitle: 'Données et sécurité',
                          iconColor: Colors.purple,
                          onTap: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(AppLocalizations.of(context)!.support_title, [
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Centre d\'aide',
                          subtitle: 'FAQ et tutoriels',
                          iconColor: Colors.green,
                          onTap: () {
                            Navigator.pushNamed(context, '/support');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.workspace_premium,
                          title: 'Passer à Pro',
                          subtitle: 'Débloquer toutes les fonctionnalités',
                          iconColor: Colors.orange,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '-50%',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/subscription');
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
                            Navigator.pushNamed(context, '/tableau_de_bord');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.analytics_outlined,
                          title: 'Analyser un Produit (Benchmark)',
                          subtitle: 'Comparer et benchmarker',
                          iconColor: Colors.orange,
                          onTap: () {
                            Navigator.pushNamed(context, '/benchmark');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.emoji_events,
                          title: 'Badges & Progression',
                          subtitle: 'Tous mes succès',
                          iconColor: Colors.amber,
                          onTap: () {
                            Navigator.pushNamed(context, '/badges');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.people_alt_outlined,
                          title: 'Partenaires & Compétitions',
                          subtitle: 'Parrainage & récompenses',
                          iconColor: Colors.teal,
                          onTap: () {
                            Navigator.pushNamed(context, '/parrainage');
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
                                  userName: displayUserName,
                                  email: displayEmail,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.favorite_border,
                          title: 'Faire une Donation',
                          subtitle: 'Soutenir notre mission',
                          iconColor: Colors.orange,
                          onTap: () {
                            Navigator.pushNamed(context, '/donation');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.group_outlined,
                          title: 'Communauté',
                          subtitle: 'Échanges et partages',
                          iconColor: Colors.indigo,
                          onTap: () {
                            Navigator.pushNamed(context, '/communaute');
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? user, String displayUserName, String? displayEmail) {
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
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Text(
                  AppLocalizations.of(context)!.nav_profile,
                  style: const TextStyle(
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
                          initialName: displayUserName,
                          initialEmail: displayEmail,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          if (_avatarUrl != null)
            Container(
              height: 120,
              width: 120,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: ModelViewer(
                key: ValueKey(_avatarUrl!),
                backgroundColor: Colors.transparent,
                src: _avatarUrl!,
                alt: "3D Avatar",
                autoRotate: true,
                cameraControls: false,
                loading: Loading.eager,
              ),
            )
          else
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white24,
              backgroundImage: user?.profilePicture != null ? NetworkImage(user!.profilePicture!) : null,
              child: user?.profilePicture == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          const SizedBox(height: 16),
          Text(
            displayUserName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (displayEmail != null && displayEmail!.isNotEmpty)
            Text(
              displayEmail!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/my_subscription');
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

  Widget _buildStats(String name, UserModel? user) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: FavoritesManager().favoritesNotifier,
      builder: (context, favoritesList, child) {
        String favorisCount = favoritesList.length.toString();
        
        // Stats from SessionManager/UserModel (Coins & XP)
        String vistasCount = user?.coins.toString() ?? '0';
        String scoreCount = user?.xp.toString() ?? '0';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
      },
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
      onTap: () async {
        // Appel à l'API pour invalider le token côté serveur
        await ApiService().logoutV2();
        // Effacer la session locale (supprime le token JWT)
        await SessionManager().setUser(null);
        // Rediriger vers la page de connexion
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
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
