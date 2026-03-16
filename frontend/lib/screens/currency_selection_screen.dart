import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../services/currency_manager.dart';

class CurrencySelectionScreen extends StatefulWidget {
  const CurrencySelectionScreen({super.key});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  late String _tempSelectedCode;

  String _getCurrencyName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'USD': return l10n.currency_usd;
      case 'EUR': return l10n.currency_eur;
      case 'MAD': return l10n.currency_mad;
      case 'GBP': return l10n.currency_gbp;
      case 'SAR': return l10n.currency_sar;
      default: return code;
    }
  }

  @override
  void initState() {
    super.initState();
    _tempSelectedCode = CurrencyManager().selectedCurrencyCode;
  }

  @override
  Widget build(BuildContext context) {
    final currencyManager = CurrencyManager();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Devise d\'affichage',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélectionnez votre devise préférée. Tous les prix des produits seront convertis automatiquement selon le taux de change actuel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: currencyManager.supportedCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = currencyManager.supportedCurrencies[index];
                  final isSelected = _tempSelectedCode == currency.code;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _tempSelectedCode = currency.code;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFCCAA) : const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              currency.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '${_getCurrencyName(context, currency.code)} (${currency.code}${currency.symbol.isNotEmpty ? ' - ' + currency.symbol : ''})',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await currencyManager.setCurrency(_tempSelectedCode);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Devise mise à jour')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Enregistre',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
