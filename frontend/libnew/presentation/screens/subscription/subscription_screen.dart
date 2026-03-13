import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppTheme.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingXL),
                Text(
                  'Mon abonnement',
                  style: AppTheme.displaySmall,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Container(
                  padding: AppTheme.cardPadding,
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
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: AppTheme.inputPadding,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppTheme.secondaryOrange,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plan actuel',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Gratuit',
                                  style: AppTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3, // 30% for free tier
                          decoration: BoxDecoration(
                            color: AppTheme.infoBlue,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0/5',
                            style: AppTheme.bodySmall,
                          ),
                          Text(
                            '5',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Choisir un plan',
                  style: AppTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Container(
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
                    children: [
                      ListTile(
                        title: Text(
                          'Premium',
                          style: AppTheme.titleLarge,
                        ),
                        subtitle: Text(
                          'Accès complet à toutes les fonctionnalités',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        trailing: Text(
                          '€29/mois',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.infoBlue,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFeature('Recherche illimitée de produits'),
                            const SizedBox(height: AppTheme.spacingS),
                            _buildFeature('Analyses détaillées'),
                            const SizedBox(height: AppTheme.spacingS),
                            _buildFeature('Support prioritaire'),
                            const SizedBox(height: AppTheme.spacingS),
                            _buildFeature('Export de données'),
                            const SizedBox(height: AppTheme.spacingM),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle premium subscription
                                },
                                child: const Text('Souscrire'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: AppTheme.successGreen,
        ),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}