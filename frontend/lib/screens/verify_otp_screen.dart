// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_verification_code_field/flutter_verification_code_field.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

enum OtpPurpose {
  register,
  forgotPassword,
}


class VerifyOTPScreen extends StatefulWidget {
  final String email;
  final OtpPurpose purpose;

  const VerifyOTPScreen({
    super.key,
    required this.email,
    required this.purpose,
  });

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
      SnackBar(content: Text(AppLocalizations.of(context)!.enter_otp)),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Map<String, dynamic> result;

    // 🔥 Choisir l'API selon le contexte
    if (widget.purpose == OtpPurpose.register) {
      result = await authProvider.verifyOTP(widget.email, _otpValue);
    } else {
      result = await authProvider.verifyOTP(
        widget.email,
        _otpValue,
      );
    }

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.otp_verified)),
      );

      // 🔥 Redirection selon le contexte
      if (widget.purpose == OtpPurpose.register) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        Navigator.of(context).pushReplacementNamed('/reset-password');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur de vérification'),
        ),
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

    Map<String, dynamic> result;

    // 🔥 Choisir l'API selon le contexte
    if (widget.purpose == OtpPurpose.register) {
      result = await authProvider.resendOTP(widget.email);
    } else {
      result = await authProvider.requestPasswordReset(widget.email);
    }

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.code_sent),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur d\'envoi'),
        ),
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
          AppLocalizations.of(context)!.email_verification,
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
            const SizedBox(height: AppTheme.spacingXL),

            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 50,
                color: AppTheme.primaryOrange,
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Title
            Text(
              AppLocalizations.of(context)!.verify_your_email,
              textAlign: TextAlign.center,
              style: AppTheme.displaySmall.copyWith(
                fontSize: 28,
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Description
            Text(
              AppLocalizations.of(context)!.otp_description,
              textAlign: TextAlign.center,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: AppTheme.spacingS),

            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryOrange,
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // OTP Input
            VerificationCodeField(
              length: 6,
              onFilled: (value) {
                setState(() {
                  _otpValue = value;
                });
              },
              size: const Size(40, 60),
              spaceBetween: 15,
              matchingPattern: RegExp(r'^\d+$'),
            ),

            const SizedBox(height: AppTheme.spacingL),

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
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.verify_btn,
                      style: AppTheme.labelLarge.copyWith(
                        fontSize: 16,
                      ),
                    ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.did_not_receive_code} ',
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
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.secondaryOrange,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.resend_btn,
                          style: AppTheme.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryOrange,
                          ),
                        ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingM),

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
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.infoBlue,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.otp_expiry,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.infoBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }
}