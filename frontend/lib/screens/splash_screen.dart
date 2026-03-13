import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
            // Optional loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}