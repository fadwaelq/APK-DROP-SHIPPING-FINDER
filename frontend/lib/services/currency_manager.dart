import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });
}

class CurrencyManager extends ChangeNotifier {
  static final CurrencyManager _instance = CurrencyManager._internal();
  factory CurrencyManager() => _instance;
  CurrencyManager._internal();

  String _selectedCurrencyCode = 'USD';
  
  final List<Currency> supportedCurrencies = [
    Currency(code: 'USD', name: 'Dollar Américain', symbol: '\$', flag: '🇺🇸'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    Currency(code: 'MAD', name: 'Dirham Marocain', symbol: 'MAD', flag: '🇲🇦'),
    Currency(code: 'GBP', name: 'Livre Sterling', symbol: '£', flag: '🇬🇧'),
    Currency(code: 'SAR', name: 'Riyal Saoudien', symbol: 'SAR', flag: '🇸🇦'),
  ];

  String get selectedCurrencyCode => _selectedCurrencyCode;
  
  Currency get selectedCurrency => supportedCurrencies.firstWhere(
    (c) => c.code == _selectedCurrencyCode,
    orElse: () => supportedCurrencies[0],
  );

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrencyCode = prefs.getString('selected_currency') ?? 'USD';
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    _selectedCurrencyCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', code);
    notifyListeners();
  }
}
