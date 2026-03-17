import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            icon: Icons.widgets_outlined,
            activeIcon: Icons.widgets,
            label: 'Accueil',
            index: 0,
          ),
          _buildNavItem(
            context,
            icon: Icons.search,
            activeIcon: Icons.search,
            label: 'Recherche',
            index: 1,
          ),
          _buildNavItem(
            context,
            icon: Icons.favorite_border,
            activeIcon: Icons.favorite,
            label: 'Favoris',
            index: 2,
          ),
          _buildNavItem(
            context,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (isActive) return;
        
        // Always call the provided callback
        onTap(index);
        
        // ONLY navigate if we are not already on the main screen (which handles its own state)
        // or if we explicitly want to jump back from a pushed screen.
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute != '/home') {
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/home', 
            (route) => false,
            arguments: {'initialIndex': index},
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppTheme.primaryOrange : Colors.white60,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryOrange : Colors.white60,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}