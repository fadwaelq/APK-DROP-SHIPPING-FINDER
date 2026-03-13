import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Once auth state is loaded, navigate appropriately
        if (!authProvider.isLoading) {
          // Schedule navigation after frame is rendered
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.isAuthenticated) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              Navigator.pushReplacementNamed(context, '/onboarding');
            }
          });
        }
        
        // Show splash UI regardless of auth state
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Dropshipping Finder',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find profitable products',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}