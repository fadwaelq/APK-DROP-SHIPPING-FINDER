import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../utils/theme.dart';
import 'home_screen_v2.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreenV2()),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final result = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          Future.microtask(() {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreenV2()),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Erreur de connexion',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
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

  Future<void> _loginWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.loginWithGoogle();

      if (mounted) {
        if (result['success'] == true) {
          Future.microtask(() {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreenV2()),
              );
            }
          });
        } else {
          _showError(result['message'] ?? 'Erreur de connexion Google');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Erreur Google: $e');
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppTheme.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * .4,
                        child: Image.asset(
                          'assets/images/form.png', // Create or download a PNG logo
                          fit: BoxFit.contain,
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: AppTheme.spacingS),

                  // Title
                  Text(
                    'Connexion',
                    style: AppTheme.titleLarge.copyWith(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppTheme.spacingXS),

                  // Subtitle
                  Text(
                    'Bienvenue ! Connectez-vous pour continuer',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppTheme.spacingXL),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'vous@example.com',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!value.contains('@')) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppTheme.spacingL),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.textTertiary,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppTheme.spacingS),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.secondaryOrange,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingL),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.mediumGray,
                        disabledForegroundColor: AppTheme.textTertiary,
                        padding:
                            EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Se connecter',
                              style: AppTheme.labelLarge.copyWith(
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingL),

                  // Register Link
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte ? ',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Créer un compte',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.secondaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: AppTheme.spacingXL,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppTheme.textSecondary.withOpacity(0.3),
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Ou continuez avec",
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppTheme.textSecondary.withOpacity(0.3),
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.spacingXL),

                  // Google Sign-In Button
                  OutlinedButton.icon(
                    onPressed: _isGoogleLoading ? null : _loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                      side: BorderSide(
                        color: AppTheme.textSecondary.withOpacity(0.3),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                    ),
                    icon: _isGoogleLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryOrange,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/images/google_logo.png',
                            height: 24,
                            width: 24,
                          ),
                    label: Text(
                      'Continuer avec Google',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingXL),

                  // Terms and Privacy
                  Text(
                    'En continuant, vous acceptez les conditions d\'utilisation et notre politique de confidentialité',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
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
