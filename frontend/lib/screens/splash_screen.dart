import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import '../services/session_manager.dart';
import '../services/language_manager.dart';
import '../services/currency_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait a minimum of 2 seconds for smooth UX
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if all services are ready
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    final languageManager = Provider.of<LanguageManager>(context, listen: false);
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    
    // Navigate based on authentication status
    if (sessionManager.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image - adjust the asset path as needed
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback widget if logo.png doesn't exist
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 100,
                    color: Colors.black54,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            
            // App name
            const Text(
              'Dropshipping Finder',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            
            // Loading indicator with connectivity status
            Consumer<ConnectivityService>(
              builder: (context, connectivity, _) {
                return Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      connectivity.isChecking 
                        ? 'Vérification de la connexion...'
                        : connectivity.isConnected
                          ? 'Chargement en cours...'
                          : 'Mode hors ligne',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}