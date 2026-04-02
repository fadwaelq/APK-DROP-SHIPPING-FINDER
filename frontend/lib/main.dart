import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:dropshipping_app/l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/session_manager.dart';
import 'services/language_manager.dart';
import 'services/currency_manager.dart';
import 'services/connectivity_service.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_screen.dart';
import 'screens/recompenses_screen.dart';
import 'screens/evenements_screen.dart';
import 'screens/communaute_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/support_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/my_subscription_screen.dart';
import 'screens/payment_management_screen.dart';
import 'screens/donation_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/tableau_de_bord_screen.dart';
import 'screens/badges_screen.dart';
import 'screens/parrainage_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/currency_selection_screen.dart';
import 'screens/app_version_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/paypal_details_screen.dart';
import 'screens/payment_details_screen.dart';
import 'screens/google_play_redeem_screen.dart';
import 'screens/benchmark_screen.dart';
import 'services/favorites_manager.dart'; // Added this import
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load essential services first, defer heavy operations
  await SessionManager().loadSession();
  await LanguageManager().loadLanguage();
  await CurrencyManager().loadCurrency();
  
  // Initialize connectivity service (fast)
  await ConnectivityService().initialize();
  
  // Load .env file (non-blocking)
  unawaited(() async {
    try {
      await dotenv.load(fileName: "assets/.env");
    } catch (e) {
      // Fallback si le fichier .env est manquant dans assets
      await dotenv.load(fileName: ".env").catchError((_) => null);
    }
  }());
  
  runApp(const DropshippingApp());
}

class DropshippingApp extends StatelessWidget {
  const DropshippingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SessionManager()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider.value(value: LanguageManager()),
        ChangeNotifierProvider.value(value: CurrencyManager()),
        ChangeNotifierProvider.value(value: ConnectivityService()),
        Provider.value(value: FavoritesManager()),
      ],
      child: ListenableBuilder(
        listenable: LanguageManager(),
        builder: (context, child) {
          return MaterialApp(
            title: 'Dropshipping Finder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: LanguageManager().locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: '/splash',

            routes: {
              '/splash': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/verification': (context) => const VerificationScreen(),
              '/forgot_password': (context) => const ForgotPasswordScreen(),
              '/home': (context) => const MainScreen(),
              '/recompenses': (context) => const RecompensesScreen(),
              '/evenements': (context) => const EvenementsScreen(),
              '/communaute': (context) => const CommunauteScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/language': (context) => const LanguageSelectionScreen(),
              '/support': (context) => const HelpCenterScreen(),
              '/contact_support': (context) => const SupportScreen(),
              '/subscription': (context) => const SubscriptionScreen(),
              '/my_subscription': (context) => const MySubscriptionScreen(isPremium: true),
              '/payment_management': (context) => const PaymentManagementScreen(),
              '/donation': (context) => const DonationScreen(),
              '/create_post': (context) => const CreatePostScreen(),
              '/tableau_de_bord': (context) => const TableauDeBordScreen(),
              '/badges': (context) => const BadgesScreen(),
              '/parrainage': (context) => const ParrainageScreen(),
              '/search': (context) => const SearchScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/currency': (context) => const CurrencySelectionScreen(),
              '/app_version': (context) => const AppVersionScreen(),
              '/privacy_policy': (context) => const PrivacyPolicyScreen(),
              '/paypal': (context) => const PaypalDetailsScreen(),
              '/payment_details': (context) => const PaymentDetailsScreen(),
              '/google_play': (context) => const GooglePlayRedeemScreen(),
              '/benchmark': (context) => const BenchmarkScreen(),
            },
  
          );
        },
      ),
    );
  }
}
