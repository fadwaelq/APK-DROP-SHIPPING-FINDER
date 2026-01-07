import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen_v2.dart';
import 'with_status_bar.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // If still loading, show a splash or loading screen
    if (authProvider.isLoading) {
      return const WithStatusBar(
        child: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    // If user is authenticated, show home screen
    // Otherwise, show onboarding/login
    return authProvider.isAuthenticated 
        ? const WithStatusBar(child: HomeScreenV2()) 
        : const WithStatusBar(child: OnboardingScreen());
  }
}