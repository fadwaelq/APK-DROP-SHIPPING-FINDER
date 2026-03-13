import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/otp_input_field.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve email passed from register screen
    final String? emailArg = ModalRoute.of(context)?.settings.arguments as String?;
    final String displayEmail = (emailArg != null && emailArg.isNotEmpty) ? emailArg : 'votre@email.com';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.search, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dropshipping\nFinder',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              
              const Text(
                'Vérifiez votre boîte mail',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      const TextSpan(text: 'Nous avons envoyé un code\nde vérification à '),
                      TextSpan(
                        text: displayEmail,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '. Veuillez\nle saisir ci-dessous pour activer votre compte.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              const OtpInputField(),
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Vérifier le compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Renvoyer le code 60s',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 120), // Spacer before bottom text
              
              const Text(
                'En continuant, vous acceptez nos conditions d\'utilisation et notre\npolitique de confidentialité',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
