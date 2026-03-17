import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/google_play_logo.dart';
import '../services/api_service.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  String _selectedAmount = '20';
  String _paymentMethod = 'card'; // 'card', 'paypal', 'google'
  final TextEditingController _customAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFFFF3E0),
                  Color(0xFFFFE0B2),
                  Color(0xFFFFB74D),
                  Color(0xFFF7931E),
                ],
                stops: [0.0, 0.3, 0.5, 0.8, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Back and Title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Faire une Donation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'contribuer a notre mission',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.favorite, color: Colors.orange, size: 28),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Amounts Card
                    _buildAmountsCard(),
                    const SizedBox(height: 30),
                    // Payment Card
                    _buildPaymentCard(),
                    const SizedBox(height: 120), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
          // Navbar
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

  Widget _buildAmountsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAmountRow(['10', '20', '25', '50']),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Dons Directs', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text(r'$', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _customAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '00',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                _selectedAmount = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(List<String> amounts) {
    return Column(
      children: [
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             const Text('Dons Directs', style: TextStyle(fontWeight: FontWeight.bold)),
             ...amounts.map((amount) => _buildAmountItem(amount)),
           ],
        ),
      ],
    );
  }

  Widget _buildAmountItem(String amount) {
    bool isSelected = _selectedAmount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = amount;
          _customAmountController.clear();
        });
      },
      child: Row(
        children: [
          Text('\$$amount', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: isSelected
                ? Container(
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8D1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choisir un moyen de paiement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildPaymentMethodTile('card', Icons.credit_card, 'Carte Bancaire (via Stripe)'),
          _buildPaymentMethodTile('paypal', Icons.paypal, 'PayPal', color: Colors.blue.shade800),
          _buildPaymentMethodTile(
            'google', 
            Icons.play_arrow_rounded, 
            'Google Play Balance', 
            color: Colors.blue,
            customIcon: const GooglePlayLogo(size: 24),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _handleDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                'Continuer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(String id, IconData icon, String title, {Color color = Colors.black, Widget? customIcon}) {
    bool isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            customIcon ?? Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: id == 'paypal' ? Colors.blue.shade800 : (id == 'google' ? Colors.blue : Colors.black),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: isSelected ? Colors.orange : Colors.white,
                boxShadow: [
                   BoxShadow(
                     color: Colors.black.withValues(alpha: 0.1),
                     blurRadius: 4,
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDonation() async {
     double? amount = double.tryParse(_selectedAmount);
     if (amount == null || amount <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Veuillez entrer un montant valide')),
       );
       return;
     }

     // Record donation attempt in backend
     final result = await ApiService().recordDonation(amount, _paymentMethod);
     
     if (result['success'] == true) {
       // Proceed to detailed provider screen
       if (!mounted) return;
       if (_paymentMethod == 'card') {
         Navigator.pushNamed(context, '/payment_details');
       } else if (_paymentMethod == 'paypal') {
         Navigator.pushNamed(context, '/paypal');
       } else if (_paymentMethod == 'google') {
         Navigator.pushNamed(context, '/google_play');
       }
     } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Erreur: ${result['message']}')),
         );
       }
     }
  }
}
