import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _faceIdEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings_title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.pref_general,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.language,
              title: AppLocalizations.of(context)!.lang_item,
              onTap: () {
                Navigator.pushNamed(context, '/language');
              },
            ),
            _buildSettingItem(
              icon: Icons.monetization_on_outlined,
              title: AppLocalizations.of(context)!.currency_item,
              onTap: () {
                Navigator.pushNamed(context, '/currency');
              },
            ),
            _buildSettingItem(
              icon: Icons.password,
              title: AppLocalizations.of(context)!.change_pwd_item,
              onTap: () {
                // ChangePasswordScreen might not be in routes yet, adding it if needed or keeping push
                Navigator.pushNamed(context, '/forgot_password'); // Simplified for now as fallback
              },
            ),
            _buildSettingSwitch(
              icon: Icons.security,
              title: AppLocalizations.of(context)!.faceid_item,
              value: _faceIdEnabled,
              onChanged: (val) => setState(() => _faceIdEnabled = val),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.legal_support,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              title: AppLocalizations.of(context)!.privacy_policy,
              onTap: () {
                Navigator.pushNamed(context, '/privacy_policy');
              },
            ),
            _buildSettingItem(
              title: AppLocalizations.of(context)!.app_version,
              onTap: () {
                Navigator.pushNamed(context, '/app_version');
              },
            ),
            _buildSettingItem(
              title: AppLocalizations.of(context)!.contact_support,
              onTap: () {
                Navigator.pushNamed(context, '/support');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({IconData? icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
