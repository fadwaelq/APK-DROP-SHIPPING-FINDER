import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class LanguageManager extends ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  String get selectedLanguageCode => _locale.languageCode;

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language_code', locale.languageCode);
    notifyListeners();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString('selected_language_code');
    
    if (savedCode != null) {
      _locale = Locale(savedCode);
    } else {
      // Détection automatique de la langue du système
      String systemLocale = 'fr'; // Default language
      
      // Only use Platform.localeName on non-web platforms
      if (!kIsWeb) {
        try {
          systemLocale = Platform.localeName.split('_')[0];
        } catch (e) {
          // If Platform.localeName fails, fallback to 'fr'
          systemLocale = 'fr';
        }
      } else {
        // For web, try to get language from browser
        systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      }
      
      List<String> supportedLanguages = ['fr', 'en', 'ar', 'es', 'de'];
      
      if (supportedLanguages.contains(systemLocale)) {
        _locale = Locale(systemLocale);
      } else {
        _locale = const Locale('fr');
      }
    }
    notifyListeners();
  }
}
