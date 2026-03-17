import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Large Orange Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.register_title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.register_welcome,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              CustomTextField(
                label: AppLocalizations.of(context)!.full_name_label,
                hintText: AppLocalizations.of(context)!.full_name_hint,
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: AppLocalizations.of(context)!.email_label,
                hintText: AppLocalizations.of(context)!.email_hint,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: AppLocalizations.of(context)!.password_label,
                hintText: AppLocalizations.of(context)!.password_hint,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: AppLocalizations.of(context)!.confirm_password_label,
                hintText: AppLocalizations.of(context)!.password_hint,
                isPassword: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  final name = _nameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  final confirm = _confirmPasswordController.text.trim();
                  
                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
                    return;
                  }
                  if (password != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les mots de passe ne correspondent pas')));
                    return;
                  }

                  setState(() => _isLoading = true);
                  final result = await ApiService().register(name, email, password);
                  setState(() => _isLoading = false);

                  if (result['success'] == true) {
                    if (mounted) {
                      Navigator.pushNamed(
                        context, 
                        '/verification',
                        arguments: email,
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'] ?? 'Erreur lors de l\'inscription')),
                      );
                    }
                  }
                },
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(AppLocalizations.of(context)!.signup_btn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.already_have_account + ' ',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.signin_btn,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      AppLocalizations.of(context)!.continue_with,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                ],
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   SocialLoginButton(
                    assetPath: 'assets/google_logo.png',
                    onPressed: () async {
                      final authService = AuthService();
                      final result = await authService.signInWithGoogle();
                      if (result.success && mounted) {
                        // Save to SessionManager
                        SessionManager().setUser(result.user);
                        
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                          arguments: {
                            'name': result.user?.firstName ?? AppLocalizations.of(context)!.user_label,
                            'email': result.user?.email,
                          },
                        );
                      } else if (result.message != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.message!)),
                        );
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  await SessionManager().setUser(null); // Clear session for Guest
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                      arguments: AppLocalizations.of(context)!.guest,
                    );
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.login_as_guest,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
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
