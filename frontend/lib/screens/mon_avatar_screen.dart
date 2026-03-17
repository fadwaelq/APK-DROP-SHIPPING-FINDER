import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'subscription_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

class MonAvatarScreen extends StatefulWidget {
  final String userName;
  final String? email;

  const MonAvatarScreen({
    super.key,
    required this.userName,
    this.email,
  });

  @override
  State<MonAvatarScreen> createState() => _MonAvatarScreenState();
}

class _MonAvatarScreenState extends State<MonAvatarScreen> {
  bool _notificationsEnabled = true;

  // Avatar color options
  final List<Color> _avatarColors = [
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.pink,
    Colors.teal,
  ];
  int _selectedAvatarColor = 0;

  // Avatar emoji list
  final List<String> _avatarEmojis = ['🧑', '👨', '👩', '🧔', '👱', '🧕'];
  int _selectedEmoji = 0;

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
                children: [
                  _buildAvatarCustomizer(),
                  const SizedBox(height: 24),
                  _buildStats(),
                  const SizedBox(height: 24),
                  _buildSection('Préférences', [
                    _buildMenuItem(
                      icon: Icons.notifications_none_outlined,
                      title: 'Notifications',
                      subtitle: 'Alertes et tendances',
                      iconColor: Colors.blue,
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (v) => setState(() => _notificationsEnabled = v),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Confidentialité',
                      subtitle: 'Données et sécurité',
                      iconColor: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Support', [
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Centre d\'aide',
                      subtitle: 'FAQ et tutoriels',
                      iconColor: Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SupportScreen()),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Passer à Pro',
                      subtitle: 'Débloquer toutes les fonctionnalités',
                      iconColor: Colors.orange,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '-50%',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                      ),
                    ),
                  ]),
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text(
                  'Profil',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.settings_outlined, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Avatar circle
          GestureDetector(
            onTap: () => _showAvatarPicker(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: _avatarColors[_selectedAvatarColor].withOpacity(0.2),
                    child: Text(
                      _avatarEmojis[_selectedEmoji],
                      style: const TextStyle(fontSize: 38),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.userName,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (widget.email != null && widget.email!.isNotEmpty)
            Text(widget.email!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          // Pro plan banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange[800],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Plan Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Actif jusqu\'au 25 nov. 2025', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildAvatarCustomizer() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Couleur de thème', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_avatarColors.length, (index) {
              final isSelected = _selectedAvatarColor == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatarColor = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _avatarColors[index],
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 2.5)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: _avatarColors[index].withOpacity(0.5), blurRadius: 8)]
                        : [],
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('12', 'Favoris'),
          _buildDivider(),
          _buildStatItem('847', 'Vues'),
          _buildDivider(),
          _buildStatItem('87', 'Score'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[200]);
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: items),
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
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choisir un avatar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 6,
                  shrinkWrap: true,
                  children: List.generate(_avatarEmojis.length, (i) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedEmoji = i);
                        setSheetState(() {});
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _selectedEmoji == i
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(_avatarEmojis[i], style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
