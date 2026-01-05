import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../utils/theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: AppTheme.screenPadding,
                child: Column(
                  children: [
                    _buildPlanCard(
                      context,
                      plan: SubscriptionPlan.starter,
                      isRecommended: false,
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    _buildPlanCard(
                      context,
                      plan: SubscriptionPlan.pro,
                      isRecommended: true,
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    _buildPlanCard(
                      context,
                      plan: SubscriptionPlan.premium,
                      isRecommended: false,
                    ),
                    SizedBox(height: AppTheme.spacingL),
                    _buildMoneyBackGuarantee(),
                    SizedBox(height: AppTheme.spacingXXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.orangeGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Passer à Pro',
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          SizedBox(height: AppTheme.spacingL),
          Container(
            padding: EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.trending_up,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'Boostez votre business',
            style: AppTheme.displaySmall.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: AppTheme.spacingXS),
          Text(
            'Choisissez le plan qui correspond à vos objectifs',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required SubscriptionPlan plan,
    required bool isRecommended,
  }) {
    // Define plan details
    String name;
    String price;
    List<String> features;
    Color accentColor;
    IconData icon;

    switch (plan) {
      case SubscriptionPlan.starter:
        name = 'Starter';
        price = '99';
        features = [
          '100 recherches par mois',
          'Analyse de base',
          '5 favoris',
          'Support email',
          'Historique 7 jours',
        ];
        accentColor = const Color(0xFF5B8DEF);
        icon = Icons.rocket_launch_outlined;
        break;
      case SubscriptionPlan.pro:
        name = 'Pro';
        price = '249';
        features = [
          'Recherches illimitées',
          'Analyse avancée',
          'Favoris illimités',
          'Support prioritaire',
          'Historique 30 jours',
          'Export données',
          'Alertes tendances',
        ];
        accentColor = AppTheme.secondaryOrange;
        icon = Icons.workspace_premium;
        break;
      case SubscriptionPlan.premium:
        name = 'Premium';
        price = '499';
        features = [
          'Tout du plan Pro',
          'Analyse prédictive',
          'API accès',
          'Support 24/7',
          'Historique illimité',
          'Formation exclusive',
          'Conseiller dédié',
          'Outils marketing',
        ];
        accentColor = const Color(0xFFFFA726);
        icon = Icons.diamond;
        break;
      default:
        name = 'Free';
        price = '0';
        features = [];
        accentColor = AppTheme.mediumGray;
        icon = Icons.star;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: isRecommended
            ? Border.all(color: AppTheme.secondaryOrange, width: 2)
            : Border.all(color: AppTheme.borderColor, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.warningYellow,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                  topRight: Radius.circular(AppTheme.borderRadiusLarge),
                ),
              ),
              child: Text(
                'Le plus populaire',
                style: AppTheme.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingS),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTheme.headlineSmall.copyWith(
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingXS),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              price,
                              style: AppTheme.displayMedium.copyWith(
                                fontSize: 32,
                                color: accentColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 6,
                                left: 2,
                              ),
                              child: Text(
                                'DH/mois',
                                style: AppTheme.labelMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacingL),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: accentColor,
                            size: 20,
                          ),
                          SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: AppTheme.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleSubscribe(context, plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: AppTheme.buttonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      'Choisir $name',
                      style: AppTheme.labelLarge.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyBackGuarantee() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: AppTheme.infoBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: AppTheme.infoBlue,
            size: 32,
          ),
          SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garantie satisfait ou remboursé 14 jours',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: AppTheme.spacingXS),
                Text(
                  'Annulez à tout moment, sans frais cachés',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(BuildContext context, SubscriptionPlan plan) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer l\'abonnement',
          style: AppTheme.headlineSmall,
        ),
        content: Text(
          'Vous allez souscrire au plan ${plan.displayName} pour ${plan.price} DH/mois.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryOrange,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Confirmer',
              style: AppTheme.labelMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await userProvider.updateSubscription(plan);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Abonnement mis à jour avec succès !',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
          ),
        );
        Navigator.pop(context);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userProvider.error ?? 'Erreur lors de la mise à jour',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
          ),
        );
      }
    }
  }
}