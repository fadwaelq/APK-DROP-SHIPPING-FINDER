import 'package:dropshipping_finder/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/user_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen_v2.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'utils/theme.dart';
import 'widgets/with_status_bar.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    debugPrint('Warning: .env file not loaded: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, // White background for navigation bar
      systemNavigationBarIconBrightness: Brightness.dark, // Black icons for navigation bar
      statusBarIconBrightness: Brightness.dark, // Black icons for status bar
      statusBarColor: Colors.white, // White background for status bar
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  GoogleAuthService().initialize(
    clientId: dotenv.env['GOOGLE_CLIENT_ID'] ?? '',
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'], // Your Web Client ID
  );

  runApp(const DropshippingFinderApp());
}

class DropshippingFinderApp extends StatelessWidget {
  const DropshippingFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(),
          update: (context, auth, productProvider) {
            final userId = auth.user?.id;
            if (productProvider != null) {
              productProvider.setUser(userId);
            }
            return productProvider!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Dropshipping Finder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const WithStatusBar(child: AuthWrapper()),
        routes: {
          '/onboarding': (context) => const WithStatusBar(child: OnboardingScreen()),
          '/login': (context) => const WithStatusBar(child: LoginScreen()),
          '/home': (context) => const WithStatusBar(child: HomeScreenV2()),
          '/search': (context) => const WithStatusBar(child: SearchScreen()),
          '/favorites': (context) => const WithStatusBar(child: FavoritesScreen()),
          '/profile': (context) => const WithStatusBar(child: ProfileScreen()),
          '/subscription': (context) => const WithStatusBar(child: SubscriptionScreen()),
        },
      ),
    );
  }
}
