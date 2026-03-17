import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
              const Text(
                'Inscription',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bienvenue ! Connectez-vous pour continuer',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              const CustomTextField(
                label: 'Nom et Prénom',
                hintText: '',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hintText: '',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              const CustomTextField(
                label: 'Mot de passe',
                hintText: '',
                isPassword: true,
              ),
              const SizedBox(height: 16),
              const CustomTextField(
                label: 'Confirmer le mot de passe',
                hintText: '',
                isPassword: true,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/verification',
                    arguments: _emailController.text.trim(),
                  );
                },
                child: const Text('S\'inscrire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Déjà un compte ? ',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Ou continuez avec',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE0E0E0))),
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
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                          arguments: {
                            'name': result.user?.firstName ?? 'Utilisateur',
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
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                    arguments: 'Invité',
                  );
                },
                child: const Text(
                  'Se connecter en tant qu\'invité',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
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
