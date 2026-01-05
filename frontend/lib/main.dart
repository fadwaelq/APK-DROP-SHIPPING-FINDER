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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    debugPrint('Warning: .env file not loaded: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
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
      // Add this Consumer to sync UserProvider with AuthProvider
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Update UserProvider when AuthProvider changes
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);

          // Use addPostFrameCallback to avoid build-time updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.user?.id != userProvider.user?.id) {
              userProvider.setUser(authProvider.user);
            }
          });

          return MaterialApp(
            title: 'Dropshipping Finder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const OnboardingScreen(),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreenV2(),
              '/search': (context) => const SearchScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/subscription': (context) => const SubscriptionScreen(),
            },
          );
        },
      ),
    );
  }
}
