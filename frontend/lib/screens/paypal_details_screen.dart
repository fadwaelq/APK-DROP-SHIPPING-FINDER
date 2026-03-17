import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'payment_success_screen.dart';

class PaypalDetailsScreen extends StatefulWidget {
  const PaypalDetailsScreen({super.key});

  @override
  State<PaypalDetailsScreen> createState() => _PaypalDetailsScreenState();
}

class _PaypalDetailsScreenState extends State<PaypalDetailsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F5), // Light blueish background from mockup
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildCustomHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildPaypalLogo(),
                        const SizedBox(height: 32),
                        const Text(
                          'Connectez-vous à PayPal',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Entrez-vous identifiants PayPal pour continuer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildInputField(
                          label: 'Email PayPal',
                          hint: 'Exemple@gmail.com',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          label: 'Mot de passe PayPal',
                          hint: '***************',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 80),
                        _buildPayButton(),
                        const SizedBox(height: 120), // Spacer for floating navbar
                      ],
                    ),
                  ),
                ),
              ],
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
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'PayPal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF253B80), // PayPal blue
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaypalLogo() {
    return SizedBox(
      height: 100,
      width: 100,
      child: Image.asset(
        'assets/images/paypal.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF253B80)),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: 250,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                amount: '20',
                date: '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                paymentType: PaymentType.paypal,
                confirmationNumber: '${DateTime.now().millisecondsSinceEpoch}',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2585C6), // Match screenshot blue
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text(
          'Payez Via PayPal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

}
