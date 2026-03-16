import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/session_manager.dart';
import '../services/favorites_manager.dart';
import 'home_screen.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Charger les favoris globalement au démarrage de l'app principale
    FavoritesManager().loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('initialIndex')) {
        _selectedIndex = args['initialIndex'] as int;
      }
      _initialized = true;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SessionManager(),
      builder: (context, child) {
        final sessionUser = SessionManager().user;
        
        String userName = sessionUser?.firstName ?? 'Invité';
        String? email = sessionUser?.email;
        
        // Additional check for name/email in arguments, but priority to initialIndex
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map<String, dynamic>) {
          userName = args['name'] ?? userName;
          email = args['email'] ?? email;
        } else if (args is String) {
          userName = args;
        }

        final List<Widget> screens = [
          HomeScreen(userName: userName),
          const SearchScreen(),
          const FavoritesScreen(),
          ProfileScreen(userName: userName, email: email),
        ];

        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }

}
