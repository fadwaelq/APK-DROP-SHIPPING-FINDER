import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<UserProvider, AuthProvider>(
          builder: (context, userProvider, authProvider, child) {
            final user = userProvider.user ?? authProvider.user;

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, user),
                  _buildStats(user),
                  _buildPreferences(context, userProvider),
                  _buildSupport(context),
                  _buildLogoutButton(context, authProvider),
                  SizedBox(height: AppTheme.spacingXL),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _navigateToPage(index);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: AppTheme.spacingL,
        left: AppTheme.spacingM,
        right: AppTheme.spacingM,
        bottom: AppTheme.spacingXL,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.orangeGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Header bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profil',
                style: AppTheme.headlineMedium.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingL),
          
          // Avatar
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: user?.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      user!.avatarUrl!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 45,
                    color: AppTheme.primaryOrange,
                  ),
          ),
          SizedBox(height: AppTheme.spacingS),
          
          // User info
          Text(
            user?.name ?? 'Omar beniss',
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          SizedBox(height: AppTheme.spacingXS),
          Text(
            user?.email ?? 'omarben@email.com',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: AppTheme.spacingL),
          
          // Subscription Badge
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/subscription');
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.warningYellow,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusCircle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: AppTheme.spacingXS),
                  Text(
                    'Plan ${user?.subscriptionPlan.displayName ?? 'Pro'}',
                    style: AppTheme.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingXS),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(User? user) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                '${user?.favoriteCount ?? 12}',
                'Favoris',
              ),
            ),
            SizedBox(width: AppTheme.spacingS),
            Expanded(
              child: _buildStatItem(
                '${user?.viewCount ?? 847}',
                'Vues',
              ),
            ),
            SizedBox(width: AppTheme.spacingS),
            Expanded(
              child: _buildStatItem(
                '${user?.profitabilityScore ?? 87}',
                'Score',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.displayMedium.copyWith(
              fontSize: 28,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacingXS),
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences(BuildContext context, UserProvider userProvider) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Préférences',
            style: AppTheme.titleLarge.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
          ),
          SizedBox(height: AppTheme.spacingM),
          _buildPreferenceItem(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFF5B8DEF),
            iconBg: const Color(0xFFE8F1FF),
            title: 'Notifications',
            subtitle: 'Alertes et tendances',
            trailing: Switch(
              value: userProvider.user?.notificationsEnabled ?? true,
              onChanged: (value) {
                userProvider.toggleNotifications(value);
              },
              activeTrackColor: AppTheme.secondaryOrange.withOpacity(0.5),
              activeColor: AppTheme.secondaryOrange,
            ),
          ),
          SizedBox(height: AppTheme.spacingS),
          _buildPreferenceItem(
            icon: Icons.lock_outline,
            iconColor: const Color(0xFFB47AEA),
            iconBg: const Color(0xFFF3EBFF),
            title: 'Confidentialité',
            subtitle: 'Données et sécurité',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupport(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support',
            style: AppTheme.titleLarge.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
          ),
          SizedBox(height: AppTheme.spacingM),
          _buildPreferenceItem(
            icon: Icons.help_outline,
            iconColor: AppTheme.successGreen,
            iconBg: const Color(0xFFE8F5E9),
            title: 'Centre d\'aide',
            subtitle: 'FAQ et tutoriels',
            onTap: () {
              // TODO: Implement help center
            },
          ),
          SizedBox(height: AppTheme.spacingS),
          _buildPreferenceItem(
            icon: Icons.workspace_premium,
            iconColor: const Color(0xFFFF9800),
            iconBg: const Color(0xFFFFF3E0),
            title: 'Passer à Pro',
            subtitle: 'Débloquer toutes les fonctionnalités',
            trailing: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: AppTheme.spacingXS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.secondaryOrange,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusCircle),
              ),
              child: Text(
                '-50%',
                style: AppTheme.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/subscription');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required Color iconColor,
    Color? iconBg,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(AppTheme.spacingS),
        decoration: BoxDecoration(
          color: iconBg ?? iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textSecondary.withOpacity(0.7),
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppTheme.textTertiary,
          ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingL,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                title: Text(
                  'Se déconnecter',
                  style: AppTheme.headlineSmall,
                ),
                content: Text(
                  'Êtes-vous sûr de vouloir vous déconnecter ?',
                  style: AppTheme.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Annuler',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'Se déconnecter',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true && mounted) {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFEBEE),
            foregroundColor: AppTheme.errorRed,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, size: 20),
              SizedBox(width: AppTheme.spacingS),
              Text(
                'Se déconnecter',
                style: AppTheme.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 3:
        // Already on profile
        break;
    }
  }
}