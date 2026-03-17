import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/api_service.dart';
import '../models/payment_method_model.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    setState(() => _isLoading = true);
    final result = await ApiService().getPaymentMethods();
    if (mounted) {
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        setState(() {
          _paymentMethods = data.map((json) => PaymentMethod.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        // Fallback or error handle
      }
    }
  }

  Future<void> _deleteCard(int id) async {
    final result = await ApiService().deletePaymentMethod(id);
    if (result['success'] == true) {
      _fetchPaymentMethods();
      if (mounted) {
        _showDismissibleDeletionConfirmation(context);
      }
    }
  }

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
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_paymentMethods.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Aucune carte enregistrée.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paymentMethods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final card = _paymentMethods[index];
                return _buildCreditCardItem(context, card);
              },
            ),

          const SizedBox(height: 24),
          _buildAddCardButton(context),
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
            onTap: () => Navigator.pushNamed(context, '/google_play'),
          ),
          _buildPaymentMethodItem(
            icon: Icons.paypal,
            iconColor: Colors.blue.shade800,
            title: 'PayPal',
            onTap: () => Navigator.pushNamed(context, '/paypal'),
          ),
          const SizedBox(height: 32),
          _buildConfirmButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCreditCardItem(BuildContext context, PaymentMethod card) {
    // Parse color hex safely
    Color cardColor;
    try {
      cardColor = Color(int.parse(card.colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      cardColor = const Color(0xFF1A3A8A);
    }

    return Row(
      children: [
        Container(
          width: 100,
          height: 65,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Icon(Icons.sim_card, color: Colors.amber, size: 12),
                   Text(card.cardType.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('6230 4567 2345 5678', style: TextStyle(color: Colors.white70, fontSize: 6)),
                  Text(card.expiryDate, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 6)),
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
                  Text('**** **** **${card.lastFour}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  if (card.isDefault) const Icon(Icons.check_circle, color: Colors.orange, size: 20),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(card.expiryDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  TextButton(
                    onPressed: () => _deleteCard(card.id),
                    child: const Text(
                      'Supprimer', 
                      style: TextStyle(
                        color: Colors.orange, 
                        fontWeight: FontWeight.bold, 
                        decoration: TextDecoration.underline
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddCardButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/payment_details'),
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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

  void _showDismissibleDeletionConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFA26D), Color(0xFFFF7120)],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Votre Carte été\nSupprimer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Auto-close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }
}
