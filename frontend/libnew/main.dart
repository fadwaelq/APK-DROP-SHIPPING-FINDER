import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'data/services/api_service.dart';
import 'data/services/secure_storage_service.dart';
import 'data/services/google_auth_service.dart';
import 'data/datasources/remote/auth_remote_data_source.dart';
import 'data/datasources/local/auth_local_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/product/get_products_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/verify_otp_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/profile/edit_profile_screen.dart';
import 'presentation/screens/profile/subscription_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/product/search_screen.dart';
import 'presentation/screens/shared/onboarding_screen.dart';
import 'presentation/widgets/shared/auth_wrapper.dart';
import 'presentation/widgets/shared/with_status_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    debugPrint('Warning: .env file not loaded: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.white, // White background for navigation bar
      systemNavigationBarIconBrightness:
          Brightness.dark, // Black icons for navigation bar
      statusBarIconBrightness: Brightness.dark, // Black icons for status bar
      statusBarColor: Colors.white, // White background for status bar
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  runApp(const DropshippingFinderApp());
}

class DropshippingFinderApp extends StatelessWidget {
  const DropshippingFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<ApiService>(
          create: (_) => ApiService(http.Client()),
        ),
        Provider<SecureStorageService>(
          create: (_) => SecureStorageService(),
        ),
        Provider<GoogleAuthService>(
          create: (_) {
            final googleAuth = GoogleAuthService();
            // Initialize with client IDs from configuration
            googleAuth.initialize(
              clientId: AppConfig.googleClientId, // iOS client ID
              serverClientId: AppConfig.googleServerClientId, // Web client ID
            );
            return googleAuth;
          },
        ),

        // Data Sources
        Provider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSourceImpl(
            client: http.Client(),
            baseUrl: AppConfig.baseUrl,
          ),
        ),
        Provider<AuthLocalDataSource>(
          create: (_) => AuthLocalDataSourceImpl(),
        ),

        // Repositories
        Provider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: context.read<AuthRemoteDataSource>(),
            localDataSource: context.read<AuthLocalDataSource>(),
          ),
        ),
        Provider<ProductRepositoryImpl>(
          create: (context) => ProductRepositoryImpl(),
        ),

        // Use Cases
        Provider<LoginUsecase>(
          create: (context) => LoginUsecase(context.read<AuthRepositoryImpl>()),
        ),
        Provider<RegisterUsecase>(
          create: (context) =>
              RegisterUsecase(context.read<AuthRepositoryImpl>()),
        ),
        Provider<LogoutUsecase>(
          create: (context) =>
              LogoutUsecase(context.read<AuthRepositoryImpl>()),
        ),
        Provider<GetProductsUsecase>(
          create: (context) =>
              GetProductsUsecase(context.read<ProductRepositoryImpl>()),
        ),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            loginUsecase: context.read<LoginUsecase>(),
            registerUsecase: context.read<RegisterUsecase>(),
            logoutUsecase: context.read<LogoutUsecase>(),
            googleAuthService: context.read<GoogleAuthService>(),
          ),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(
            context.read<GetProductsUsecase>(),
          ),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Dropshipping Finder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => WithStatusBar(
                child: AuthWrapper(
                  builder: (context, isAuthenticated) {
                    if (isAuthenticated) {
                      return const HomeScreen();
                    } else {
                      return const LoginScreen();
                    }
                  },
                ),
              ),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/verify-otp': (context) => VerifyOtpScreen(
                email: '',
              ),
          '/home': (context) => const HomeScreen(),
          '/search': (context) => const SearchScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/subscription': (context) => const SubscriptionScreen(),
        },
      ),
    );
  }
}
