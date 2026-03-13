import 'package:dropshipping_finder/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_verification_code_field/flutter_verification_code_field.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import 'verify_otp_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _otpValue = "";

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final result = await authProvider.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          // Registration successful - user needs to verify OTP
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Inscription réussie! Vérifiez votre email pour le code OTP.',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppTheme.successGreen,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
          );

          // Navigate to OTP verification screen
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VerifyOTPScreen(
              email: _emailController.text.trim(),
              purpose: OtpPurpose.register, // 🔥 ICI
            ),
          ),
        );

        } else {
          // Handle registration errors
          String errorMessage = 'Erreur d\'inscription';

          // Check if there are specific field errors
          if (result['errors'] != null && result['errors'] is Map) {
            final errors = result['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];

            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessages.add(value.first.toString());
              }
            });

            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('\n');
            }
          } else if (result['message'] != null) {
            errorMessage = result['message'];
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppTheme.errorRed,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur: $e',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
int _currentIndex = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Changer le mot de passe',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
               const SizedBox(height: AppTheme.spacingXL),
                const SizedBox(height: AppTheme.spacingXL),
                // Username field
              TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe actuel',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                
                // Email field
                 TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingXL),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                
                VerificationCodeField(
              length: 4,
              onFilled: (value) {
                setState(() {
                  _otpValue = value;
                });
              },
              size: const Size(40, 60),
              spaceBetween: 15,
              matchingPattern: RegExp(r'^\d+$'),
            ),
                const SizedBox(height: AppTheme.spacingXL),
                
                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.mediumGray,
                    disabledForegroundColor: AppTheme.textTertiary,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
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
                          'Enregistrer le Nouveau Mot de Passe',
                          style: AppTheme.labelLarge.copyWith(
                            fontSize: 16,
                          ),
                        ),
                ),
                // ignore: prefer_const_constructors
             
                
                const SizedBox(height: AppTheme.spacingXXL),
              ],
            ),
          ),
        ),
      ),
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
  
 void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 3:
        // Already on profile
        break;
    }
  }
}