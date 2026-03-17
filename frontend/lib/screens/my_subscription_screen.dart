import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'subscription_screen.dart';

class MySubscriptionScreen extends StatelessWidget {
  final bool isPremium;

  const MySubscriptionScreen({super.key, this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   _buildCurrentPlanCard(),
                   const SizedBox(height: 24),
                   _buildBenefitsCard(),
                   const SizedBox(height: 40),
                   _buildActionButtons(context),
                ],
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
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Mon Abonnement',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Votre Plan Actuel',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            isPremium ? 'Premium Mensuel' : 'Gratuit (Freemium)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isPremium 
              ? 'Prochain renouvellement 17 Déc. 2025'
              : 'Votre plan est limité à 10 recherches et 3 alertes par jour.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    return Container(); // We already have the info in the header per design
  }

  Widget _buildBenefitsCard() {
    final benefits = isPremium 
      ? [
          {'title': 'Alertes illimitées', 'included': true},
          {'title': 'Analyse complète des données', 'included': true},
          {'title': 'Support prioritaire', 'included': true},
        ]
      : [
          {'title': 'Volume de ventes analysé', 'included': false},
          {'title': 'Export des données', 'included': false},
          {'title': 'Support prioritaire', 'included': false},
        ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avantages inclus',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...benefits.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Icon(
                      b['included'] as bool ? Icons.check_circle : Icons.cancel,
                      color: b['included'] as bool ? Colors.green : Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      b['title'] as String,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (!isPremium) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              isPremium ? 'Gérer le Paiement' : 'Mettre à Niveau vers Premium',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isPremium) ...[
          TextButton(
            onPressed: () {},
            child: const Text('Annuler le renouvellement', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Voir l\'historique des factures et reçus', style: TextStyle(color: Colors.grey)),
          ),
        ] else
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
              );
            },
            child: const Text('Comparer tous les plans', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}
