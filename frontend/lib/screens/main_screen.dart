import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'recompenses_screen.dart';
import 'evenements_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Récupère les arguments passés à la route
    final args = ModalRoute.of(context)?.settings.arguments;
    String userName = 'Invité';
    String? email;

    if (args is String) {
      userName = args;
    } else if (args is Map<String, dynamic>) {
      userName = args['name'] ?? 'Utilisateur';
      email = args['email'];
    }

    final List<Widget> screens = [
      HomeScreen(userName: userName),
      const RecompensesScreen(),
      const FavoritesScreen(),
      const EvenementsScreen(),
      ProfileScreen(userName: userName, email: email),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.inventory_2_outlined, 0),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.emoji_events_outlined, 1),
            label: 'Récompenses',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.favorite_border, 2),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.event_outlined, 3),
            label: 'Événements',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person_outline, 4),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon),
    );
  }
}
