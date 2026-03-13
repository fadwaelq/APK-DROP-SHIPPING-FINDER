import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.verifyOTP(widget.email, _otpController.text);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email vérifié avec succès !')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Erreur de vérification')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.resendOTP(widget.email);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Un nouveau code a été envoyé à votre email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Erreur d\'envoi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppTheme.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacingXL),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: AppTheme.textPrimary,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'Vérifier votre compte',
                    style: AppTheme.displaySmall,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Entrez le code de vérification envoyé à votre email',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  Container(
                    padding: AppTheme.cardPadding,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                      boxShadow: AppTheme.cardShadow,
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            labelText: 'Code de vérification',
                            hintText: 'Entrez le code à 6 chiffres',
                            prefixIcon: Icon(
                              Icons.sms_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.secondaryOrange, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le code de vérification';
                            }
                            if (value.length != 6) {
                              return 'Le code doit contenir 6 chiffres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          // Call verify OTP method
                                          // This is a placeholder - actual implementation depends on your auth provider
                                          Navigator.of(context).pushReplacementNamed('/home');
                                        }
                                      },
                                child: authProvider.isLoading
                                    ? const CircularProgressIndicator(strokeWidth: 2)
                                    : const Text('Vérifier'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Center(
                    child: Text(
                      'Vous n\'avez pas reçu de code?',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Resend OTP
                      },
                      child: Text(
                        'Renvoyer le code',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}