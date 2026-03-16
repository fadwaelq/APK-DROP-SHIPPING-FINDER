import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

enum PaymentType {
  creditCard,
  paypal,
  googlePlay,
}

class PaymentSuccessScreen extends StatelessWidget {
  final String amount;
  final String date;
  final PaymentType paymentType;
  final String confirmationNumber;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.date,
    required this.paymentType,
    required this.confirmationNumber,
  });

  Widget _getPaymentMethodWidget() {
    switch (paymentType) {
      case PaymentType.paypal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mode de paiement : ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
            Image.asset('assets/images/paypal.png', height: 20),
          ],
        );
      case PaymentType.googlePlay:
        return const Text.rich(
          TextSpan(
            text: 'Mode de paiement : ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            children: [
              TextSpan(text: 'Google Play', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        );
      case PaymentType.creditCard:
        return const Text.rich(
          TextSpan(
            text: 'Mode de paiement : ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            children: [
              TextSpan(text: 'Carte Bancaire', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6DE860), // Lighter top green
              Color(0xFF8FF08A), // Mid yellow-green
              Color(0xFFEAFFEA), // Bottom almost white-green
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top padding
              const SizedBox(height: 60),

              // Success Checkmark Icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF33B633), // Darker green circle
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                  weight: 800,
                ),
              ),

              const SizedBox(height: 30),

              // Glassmorphism/Stylized Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer border ring effect
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8CD88C).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                    // Inner card content
                    Container(
                      height: 310,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA1C7A1).withValues(alpha: 0.6), // Translucent sage green
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Paiement réussi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'numéro de confirmation :$confirmationNumber',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Amount Row
                          _buildInfoBox(
                            text: 'Montant du paiement : ',
                            value: '$amount\$',
                          ),
                          const SizedBox(height: 12),

                          // Date Row
                          _buildInfoBox(
                            text: 'La Date de paiement : ',
                            value: date,
                          ),
                          const SizedBox(height: 12),

                          // Payment Method Row (Special Highlighted Border)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue, width: 3), // Strong blue outline for selected
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: _getPaymentMethodWidget(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Return Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      // Depending on how routing is set up, you might want to navigate
                      // explicitly to the Profile Screen index here.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E9B1E), // Vibrant green button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: const Color(0xFF1E9B1E).withValues(alpha: 0.5),
                    ),
                    child: const Text(
                      'Retour au Profil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Bottom Navigation Bar
              CustomBottomNavBar(
                currentIndex: -1,
                onTap: (index) {
                  // Handled internally by CustomBottomNavBar
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({required String text, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
