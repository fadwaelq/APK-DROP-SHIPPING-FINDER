import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: const Text(
          'Politique de Confidentialité',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          _buildExpansionTile(
            'Collecte des données',
            'Nous collectons les informations nécessaires à votre expérience, telles que votre nom, email et préférences d\'utilisation pour personnaliser vos résultats.',
          ),
          const SizedBox(height: 16),
          _buildExpansionTile(
            'Utilisation de l\'IA',
            'Nos algorithmes d\'IA analysent les tendances du marché en temps réel pour vous proposer les meilleurs produits gagnants sans compromettre votre vie privée.',
          ),
          const SizedBox(height: 16),
          _buildExpansionTile(
            'Sécurité et Paiement',
            'Toutes les transactions sont sécurisées par cryptage SSL. Nous ne stockons jamais vos informations de carte bancaire sur nos serveurs.',
          ),
          const SizedBox(height: 16),
          _buildExpansionTile(
            'Vos Droits',
            'Vous disposez d\'un droit d\'accès, de rectification et de suppression de vos données personnelles à tout moment depuis vos paramètres.',
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF), // Light peach/white background like in screenshot
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
