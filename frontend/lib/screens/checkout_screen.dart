import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/google_play_logo.dart';
import '../services/session_manager.dart';
import 'google_play_redeem_screen.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String planName;
  final String planPrice;

  const CheckoutScreen({
    super.key,
    required this.planName,
    required this.planPrice,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'stripe';

  void _handleCheckout() {
    // Navigation directe sans appel au backend pour le moment
    if (_selectedPaymentMethod == 'stripe') {
      Navigator.pushNamed(context, '/payment_details');
    } else if (_selectedPaymentMethod == 'paypal') {
      Navigator.pushNamed(context, '/paypal');
    } else if (_selectedPaymentMethod == 'google_play') {
      Navigator.pushNamed(context, '/google_play');
    }
  }

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
          'Finaliser votre abonnement Premium',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 32),
            _buildPaymentMethodSection(),
            const SizedBox(height: 48),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif de la commande',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Votre Plan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Plan sélectionné : ${widget.planName}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          Text(
            'Renouvellement le 17 Déc. 2025',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 20),
          Text(
            'TOTAL À PAYER : ${widget.planPrice} \$',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisir un moyen de paiement',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          id: 'stripe',
          title: 'Carte Bancaire (via Stripe)',
          icon: Icons.credit_card,
        ),
        _buildPaymentOption(
          id: 'paypal',
          title: 'PayPal',
          icon: Icons.payment,
        ),
        _buildPaymentOption(
          id: 'google_play',
          title: 'Google Play Balance',
          icon: Icons.play_arrow,
          customIcon: const GooglePlayLogo(size: 20),
          subtitle: 'Current Balance : 120 \$',
          showRedeem: true,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required IconData icon,
    Widget? customIcon,
    String? subtitle,
    bool showRedeem = false,
  }) {
    bool isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                customIcon ?? Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[400]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.textPrimary : Colors.grey[600],
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            if (isSelected && showRedeem) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GooglePlayRedeemScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Redeem Gift Card ',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primary,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'Payer et Activer mon Abonnement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
