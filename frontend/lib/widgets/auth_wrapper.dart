import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen_v2.dart';
import '../screens/splash_screen.dart';
import 'with_status_bar.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // If still loading, show the splash screen with logo
    if (authProvider.isLoading) {
      return const WithStatusBar(
        child: SplashScreen()
      );
    }
    
    // If user is authenticated, show home screen
    // Otherwise, show onboarding/login
    return authProvider.isAuthenticated 
        ? const WithStatusBar(child: HomeScreenV2()) 
        : const WithStatusBar(child: OnboardingScreen());
  }
}