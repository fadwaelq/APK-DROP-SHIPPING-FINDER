import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

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
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: AppTheme.cardShadow.map((shadow) {
          return BoxShadow(
            color: shadow.color,
            blurRadius: shadow.blurRadius,
            offset: Offset(shadow.offset.dx,
                -shadow.offset.dy), // Invert Y for bottom shadow
            spreadRadius: shadow.spreadRadius,
          );
        }).toList(),
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Accueil',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.search,
                activeIcon: Icons.search,
                label: 'Recherche',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: 'Favoris',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryOrange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primaryOrange : AppTheme.textTertiary,
              size: 24,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color:
                    isActive ? AppTheme.primaryOrange : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
