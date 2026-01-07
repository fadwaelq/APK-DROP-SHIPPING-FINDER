import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class WithStatusBar extends StatelessWidget {
  final Widget child;

  const WithStatusBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay to match theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // White background for status bar
        statusBarIconBrightness: Brightness.dark, // Black icons for status bar
        systemNavigationBarColor: Colors.white, // White background for navigation bar
        systemNavigationBarIconBrightness: Brightness.dark, // Black icons for navigation bar
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        top: true, // Only apply SafeArea to top (status bar)
        bottom: false, // Let bottom navigation handle its own padding
        child: child,
      ),
    );
  }
}
