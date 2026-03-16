import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/otp_input_field.dart';
import '../services/api_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String _currentOtp = '';
  bool _isLoading = false;

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
              
              Text(
                AppLocalizations.of(context)!.verify_email_title,
                style: const TextStyle(
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
                      TextSpan(text: AppLocalizations.of(context)!.verification_sent_to + ' '),
                      TextSpan(
                        text: displayEmail,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: AppLocalizations.of(context)!.verification_enter_code),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              OtpInputField(
                length: 6,
                onCompleted: (otp) {
                  setState(() {
                    _currentOtp = otp;
                  });
                },
              ),
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_currentOtp.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez entrer le code complet à 6 chiffres')),
                    );
                    return;
                  }
                  
                  setState(() => _isLoading = true);
                  final result = await ApiService().verifyOTP(displayEmail, _currentOtp);
                  setState(() => _isLoading = false);

                  if (result['success'] == true) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compte vérifié ! Vous pouvez maintenant vous connecter.')),
                      );
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'] ?? 'Erreur lors de la vérification')),
                      );
                    }
                  }
                },
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(AppLocalizations.of(context)!.verify_account_btn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                AppLocalizations.of(context)!.resend_code_timer(60),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 120), // Spacer before bottom text
              
              Text(
                AppLocalizations.of(context)!.terms_privacy_notice,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
