import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../services/session_manager.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Extracts a friendly first name from the email address.
  /// e.g. "Fadwa.elq1@gmail.com" → "Fadwa"
  String _extractFirstName(String email) {
    if (email.isEmpty) return 'Vous';
    final local = email.split('@').first; // "Fadwa.elq1"
    final part = local.split('.').first;  // "Fadwa"
    final digit = RegExp(r'\d');
    final name = part.replaceAll(digit, ''); // remove any trailing digits
    if (name.isEmpty) return 'Vous';
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
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
              const SizedBox(height: 60),
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
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.login_title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.login_welcome,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

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

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: Text(
                    AppLocalizations.of(context)!.forgot_password_btn,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
                    return;
                  }

                  setState(() => _isLoading = true);
                  final result = await ApiService().login(email, password);
                  setState(() => _isLoading = false);

                  if (result['success'] == true) {
                    final firstName = _extractFirstName(email);

                    print('🔍 LOGIN SUCCESS_RESULT CLES : ${result.keys.toList()}');

                    // Extraction du Token JWT (access + refresh)
                    String? token;
                    String? refreshToken;
                    if (result['access'] != null) {
                      token = result['access'];
                      refreshToken = result['refresh'];
                    } else if (result['tokens'] != null && result['tokens']['access'] != null) {
                      token = result['tokens']['access'];
                      refreshToken = result['tokens']['refresh'];
                    } else if (result['data'] != null && result['data']['access'] != null) {
                      token = result['data']['access'];
                      refreshToken = result['data']['refresh'];
                    }
                    
                    // Save to SessionManager avec les tokens
                    await SessionManager().setUser(UserModel(
                      id: '1',
                      firstName: firstName,
                      lastName: '',
                      email: email,
                    ), token: token, refreshToken: refreshToken);

                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                        arguments: {
                          'name': firstName,
                          'email': email,
                        },
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'] ?? 'Erreur de connexion')),
                      );
                    }
                  }
                },
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(AppLocalizations.of(context)!.signin_btn,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.dont_have_account + ' ',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.create_account_btn,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 120),
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
