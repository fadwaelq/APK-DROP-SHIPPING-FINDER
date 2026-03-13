import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: context.labelMedium.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: context.titleLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}