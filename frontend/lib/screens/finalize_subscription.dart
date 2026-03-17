// ignore_for_file: deprecated_member_use

import '../widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'payment_details_screen.dart';
import 'paypal_details_screen.dart';
import 'google_play_redeem_screen.dart';

enum PaymentMethod {
  stripe,
  paypal,
  googlePlay,
}

class PremiumCheckoutScreen extends StatefulWidget {
  const PremiumCheckoutScreen({super.key});

  @override
  State<PremiumCheckoutScreen> createState() =>
      _PremiumCheckoutScreenState();
}

class _PremiumCheckoutScreenState
    extends State<PremiumCheckoutScreen> {

  PaymentMethod _selectedMethod = PaymentMethod.stripe;

  int _currentIndex = 3; // index Premium

  void _navigateToPage(int index) {
    if (index == 3) return; // déjà sur Premium

    Widget page;

    switch (index) {
      case 0:
        page = const HomeScreen(userName: 'Utilisateur');
        break;
      case 1:
        page = const SearchScreen();
        break;
      case 2:
        page = const ProfileScreen(userName: 'Utilisateur');
        break;
      default:
        page = const HomeScreen(userName: 'Utilisateur');
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Finaliser votre abonnement Premium',
          style: AppTheme.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOrderSummary(),
            const SizedBox(height: AppTheme.spacingL),
            _buildPaymentMethods(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildPayButton(),
          ],
        ),
      ),

      // 🔥 Bottom Navigation ajoutée
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

  // =========================
  // ORDER SUMMARY CARD
  // =========================

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.lightGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif de la commande',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Votre Plan',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            'Plan sélectionné : Premium Mensuel',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            'Renouvellement le 17 Déc. 2025',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'TOTAL À PAYER : 249 \$ SubscriptionPlan plan',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // PAYMENT METHODS CARD
  // =========================

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.lightGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisir un moyen de paiement',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildPaymentOption(
            title: 'Carte Bancaire (via Stripe)',
            icon: Icons.credit_card,
            method: PaymentMethod.stripe,
          ),
          _buildPaymentOption(
            title: 'PayPal',
            icon: Icons.account_balance_wallet,
            method: PaymentMethod.paypal,
          ),
          _buildPaymentOption(
            title: 'Google Play Balance',
            icon: Icons.play_arrow,
            method: PaymentMethod.googlePlay,
            subtitle: 'Current Balance : 120 \$',
            showRedeem: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required PaymentMethod method,
    String? subtitle,
    bool showRedeem = false,
  }) {
    final bool isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: AppTheme.spacingM),
        padding:
            const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.secondaryOrange.withOpacity(0.05)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: isSelected
                ? AppTheme.secondaryOrange
                : AppTheme.lightGray,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.secondaryOrange
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Radio<PaymentMethod>(
                  value: method,
                  groupValue: _selectedMethod,
                  activeColor: AppTheme.secondaryOrange,
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value!;
                    });
                  },
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
                  padding: const EdgeInsets.only(left: 40),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Redeem Gift Card ',
                          style: TextStyle(
                            color: AppTheme.secondaryOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline,
                          color: AppTheme.secondaryOrange,
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

  // =========================
  // PAY BUTTON
  // =========================

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: () {
        if (_selectedMethod == PaymentMethod.stripe) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentDetailsScreen(),
            ),
          );
        } else if (_selectedMethod == PaymentMethod.paypal) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaypalDetailsScreen(),
            ),
          );
        } else if (_selectedMethod == PaymentMethod.googlePlay) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GooglePlayRedeemScreen(),
            ),
          );
        } else {
          // TODO: logique paiement pour MoMo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paiement en cours...')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.secondaryOrange,
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
                  AppTheme.borderRadiusMedium),
        ),
      ),
      child: Text(
        'Payer et Activer mon Abonnement',
        style: AppTheme.labelLarge.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
