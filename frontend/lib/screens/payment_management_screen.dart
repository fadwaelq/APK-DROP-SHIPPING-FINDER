import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

class PaymentManagementScreen extends StatelessWidget {
  const PaymentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                _buildMainContent(context),
                const SizedBox(height: 120), // Spacer for floating navbar
              ],
            ),
          ),
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
      padding: const EdgeInsets.only(bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Mon Abonnement',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Votre Plan Actuel',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          const Text(
            'Premium Mensuel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Prochain renouvellement 17 Déc. 2025',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Premium Mensuel',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vos Cartes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildCreditCard(
            context,
            color: const Color(0xFF1A3A8A),
            number: '**** **** **00',
            date: '05/26',
            isSelected: true,
          ),
          const SizedBox(height: 12),
          _buildCreditCard(
            context,
            color: const Color(0xFF6B21A8),
            number: '**** **** **00',
            date: '06/26',
            isSelected: false,
          ),
          const SizedBox(height: 24),
          _buildAddCardButton(),
          const SizedBox(height: 32),
          const Text(
            'Autres méthodes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodItem(
            icon: Icons.play_arrow_rounded,
            iconColor: Colors.blue,
            title: 'Google Play Balance',
          ),
          _buildPaymentMethodItem(
            icon: Icons.paypal,
            iconColor: Colors.blue.shade800,
            title: 'PayPal',
          ),
          const SizedBox(height: 32),
          _buildConfirmButton(context),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('Annuler le renouvellement', style: TextStyle(color: Colors.grey)),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('Voir l\'historique des factures et reçus', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, {
    required Color color,
    required String number,
    required String date,
    bool isSelected = false,
  }) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 65,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Icon(Icons.sim_card, color: Colors.amber, size: 12),
                   Text('VISA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('6230 4567 2345 5678', style: TextStyle(color: Colors.white70, fontSize: 6)),
                  Text(date, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 6)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(number, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.orange, size: 20),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Modifier', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddCardButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4D4D4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text(
            'Ajoutez une nouvelle carte',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text(
          'Confirmer les modifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
