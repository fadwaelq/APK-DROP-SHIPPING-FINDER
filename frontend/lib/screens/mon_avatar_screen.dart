import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/favorites_manager.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rpm_editor_screen.dart';
import 'subscription_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';
import 'package:provider/provider.dart';
import '../services/session_manager.dart';
import '../models/user_model.dart';

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
    final session = Provider.of<SessionManager>(context, listen: false);
    if (mounted && session.user != null) {
      setState(() {
        _avatarUrl = session.user!.avatarUrl;
      });
    }
  }

  Future<void> _saveAvatarUrl(String url) async {
    debugPrint('Saving avatar URL: $url');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rpm_avatar_url', url);
    if (mounted) {
      setState(() {
        _avatarUrl = url;
      });
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

  // No longer needed for 3D view

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark sleek background
      body: _buildImmersiveLayout(context),
    );
  }

  Widget _buildImmersiveLayout(BuildContext context) {
    final bool has3DAvatar = _avatarUrl != null && _avatarUrl!.isNotEmpty;

    return Stack(
      children: [
        // 1. Immersive Background (Gradient + Subtle Mesh)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        // 2. The 3D Avatar (Hero)
        Positioned.fill(
          top: 100,
          bottom: 120,
          child: has3DAvatar
              ? ModelViewer(
                  key: ValueKey(_avatarUrl!),
                  backgroundColor: Colors.transparent,
                  src: _avatarUrl!,
                  alt: "3D Avatar",
                  ar: true,
                  autoRotate: true,
                  cameraControls: true,
                  loading: Loading.eager,
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, size: 200, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 20),
                      const Text(
                        "Aucun Avatar 3D",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ],
                  ),
                ),
        ),

        // 3. Floating Header (Glass)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingActionButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                Text(
                  'MY AVATAR 3D'.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                _buildFloatingActionButton(
                  icon: Icons.refresh,
                  onTap: _openRPMEditor,
                ),
              ],
            ),
          ),
        ),

        // 4. Bottom Controls (Glass Card)
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!has3DAvatar) ...[
                  _buildPrimaryButton(
                    label: "CRÉER MON AVATAR 3D",
                    icon: Icons.auto_awesome,
                    onTap: _openRPMEditor,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          label: "MODIFIER",
                          icon: Icons.edit_note,
                          onTap: _openRPMEditor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildPrimaryButton(
                          label: "SAUVEGARDER",
                          icon: Icons.check,
                          onTap: _handleSaveProfile,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildGhostButton(
                    label: "PARTAGER AVEC LE MONDE",
                    icon: Icons.share_outlined,
                    onTap: () {},
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openRPMEditor() async {
    final String? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RPMEditorScreen()),
    );
    
    if (result != null && result.isNotEmpty) {
      await _saveAvatarUrl(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar 3D mis à jour !'),
            backgroundColor: Color(0xFF00B4DB),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSaveProfile() async {
    setState(() => _isLoadingStats = true);
    
    try {
      if (_avatarUrl != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('rpm_avatar_url', _avatarUrl!);
      }

      final result = await SessionManager().updateUserField(
        avatarUrl: _avatarUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['success'] == true ? 'Profil sauvegardé !' : 'Avatar sauvegardé localement !'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Widget _buildFloatingActionButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF0083B0)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: const Color(0xFF00B4DB).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    label, 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGhostButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white60, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
