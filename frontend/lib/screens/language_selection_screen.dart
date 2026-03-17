import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/language_manager.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<Map<String, String>> _languages = [
    {'name': 'Français', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'العربية', 'code': 'ar', 'flag': '🇸🇦'},
    {'name': 'Español', 'code': 'es', 'flag': '🇪🇸'},
    {'name': 'Deutsch', 'code': 'de', 'flag': '🇩🇪'},
  ];

  late String _selectedLanguageCode;
  int _selectedIndex = 3; // Par défaut Profil pour la nav bar si on vient du profil

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = LanguageManager().selectedLanguageCode;
  }

  Future<void> _confirmLanguageChange(Map<String, String> lang) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n.confirm_lang_title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.confirm_lang_body(lang['name']!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _selectedLanguageCode = lang['code']!);
      await LanguageManager().setLocale(Locale(lang['code']!));
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.lang_changed(lang['name']!),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.lang_title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final lang = _languages[index];
          bool isSelected = _selectedLanguageCode == lang['code'];
          return GestureDetector(
            onTap: () => _confirmLanguageChange(lang),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFDAB9) : const Color(0xFFF5F5F5),
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
                children: [
                   Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Text(
                    lang['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check, color: AppColors.primary, size: 24),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, 'nav_home'),
              _buildNavItem(1, Icons.search_rounded, 'nav_search'),
              _buildNavItem(2, Icons.favorite_border_rounded, 'nav_fav'),
              _buildNavItem(3, Icons.person_rounded, 'nav_profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String labelKey) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (index == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.white70,
              size: 24,
            ),
          ),
          if (isSelected)
            Text(
              _getLabel(context, labelKey),
              style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  String _getLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'nav_home': return l10n.nav_home;
      case 'nav_search': return l10n.nav_search;
      case 'nav_fav': return l10n.nav_fav;
      case 'nav_profile': return l10n.nav_profile;
      default: return key;
    }
  }
}
