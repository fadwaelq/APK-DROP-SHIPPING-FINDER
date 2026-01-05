import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_verification_code_field/flutter_verification_code_field.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String email;

  const VerifyOTPScreen({super.key, required this.email});

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  String _otpValue = "";

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.verifyOTP(widget.email, _otpValue);

      if (!mounted) return;

      if (result['success']) {
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

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Un nouveau code a été envoyé à votre email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Erreur d\'envoi')),
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
      appBar: AppBar(
        title: Text(
          'Vérification Email',
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
            SizedBox(height: AppTheme.spacingXL),

            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.email_outlined,
                size: 50,
                color: AppTheme.primaryOrange,
              ),
            ),

            SizedBox(height: AppTheme.spacingXL),

            // Title
            Text(
              'Vérifiez votre email',
              textAlign: TextAlign.center,
              style: AppTheme.displaySmall.copyWith(
                fontSize: 28,
              ),
            ),

            SizedBox(height: AppTheme.spacingM),

            // Description
            Text(
              'Un code de vérification à 4 chiffres a été envoyé à',
              textAlign: TextAlign.center,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),

            SizedBox(height: AppTheme.spacingS),

            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryOrange,
              ),
            ),

            SizedBox(height: AppTheme.spacingXL),

            // OTP Input
            VerificationCodeField(
              length: 4,
              onFilled: (value) {
                setState(() {
                  _otpValue = value;
                });
              },
              size: const Size(40, 60),
              spaceBetween: 26,
              matchingPattern: RegExp(r'^\d+$'),
            ),

            SizedBox(height: AppTheme.spacingL),

            // Verify Button
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                backgroundColor: AppTheme.secondaryOrange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.mediumGray,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Vérifier',
                      style: AppTheme.labelLarge.copyWith(
                        fontSize: 16,
                      ),
                    ),
            ),

            SizedBox(height: AppTheme.spacingL),

            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Vous n\'avez pas reçu le code ? ',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: _isResending ? null : _resendOTP,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _isResending
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.secondaryOrange,
                          ),
                        )
                      : Text(
                          'Renvoyer',
                          style: AppTheme.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryOrange,
                          ),
                        ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.spacingM),

            // Info Box
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(
                  color: AppTheme.infoBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.infoBlue,
                    size: 20,
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'Le code expire après 10 minutes',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.infoBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }
}