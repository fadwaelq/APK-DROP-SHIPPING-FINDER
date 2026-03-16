// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get nav_home => 'Startseite';

  @override
  String get nav_search => 'Suche';

  @override
  String get nav_fav => 'Favoriten';

  @override
  String get nav_profile => 'Profil';

  @override
  String get greeting => 'Hallo,';

  @override
  String get profit_score => 'Rentabilitätswert';

  @override
  String get avg_profit => 'Durchschn. Gewinn';

  @override
  String get products => 'Produkte';

  @override
  String get top_niches => 'Top-Nischen';

  @override
  String get trending_products => 'Trendprodukte';

  @override
  String get see_all => 'Alles sehen';

  @override
  String get lang_title => 'Sprache';

  @override
  String get settings_title => 'Einstellungen & Präferenzen';

  @override
  String get confirm_lang_title => 'Sprache ändern?';

  @override
  String confirm_lang_body(String lang) {
    return 'Möchten Sie die App-Sprache auf $lang ändern?';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String lang_changed(String lang) {
    return 'Die App-Sprache ist jetzt: $lang';
  }

  @override
  String get events => 'Events';

  @override
  String get community => 'Community';

  @override
  String get rewards => 'Belohnungen';

  @override
  String get pref_title => 'Präferenzen';

  @override
  String get support_title => 'Support';

  @override
  String get activity_title => 'Meine Aktivitäten';

  @override
  String get logout => 'Abmelden';

  @override
  String get pref_general => 'Allgemeine Präferenz';

  @override
  String get lang_item => 'Sprache';

  @override
  String get currency_item => 'Anzeigewährung';

  @override
  String get currency_usd => 'Dollar Américain';

  @override
  String get currency_eur => 'Euro';

  @override
  String get currency_mad => 'Dirham Marocain';

  @override
  String get currency_gbp => 'Livre Sterling';

  @override
  String get currency_sar => 'Riyal Saoudien';

  @override
  String get change_pwd_item => 'Kennwort ändern';

  @override
  String get faceid_item => 'Face ID | Touch ID aktivieren';

  @override
  String get legal_support => 'Rechtliche Informationen und Support';

  @override
  String get privacy_policy => 'Datenschutz-Bestimmungen';

  @override
  String get app_version => 'App-Version';

  @override
  String get contact_support => 'Kontakt Support & Unterstützung';

  @override
  String get coin_balance => 'Münzstand';

  @override
  String get active_streak => 'Aktive Serie';

  @override
  String days_streak(int count) {
    return '$count Tage';
  }

  @override
  String get bonus_text => 'Täglicher Bonus';

  @override
  String coins_per_day(int count) {
    return '+$count Münzen/Tag';
  }

  @override
  String get history_btn => 'Verlauf';

  @override
  String get shop_btn => 'Shop';

  @override
  String level_text(int level) {
    return 'Ebene $level';
  }

  @override
  String get elite_trader => 'Elite-Händler';

  @override
  String xp_for_level(int nextLevel) {
    return 'XP für Ebene $nextLevel';
  }

  @override
  String get daily_missions => 'Tägliche Missionen';

  @override
  String get weekly_missions => 'Wöchentliche Missionen';

  @override
  String mission_analyze(int count) {
    return 'Analysieren Sie heute $count Produkte';
  }

  @override
  String get mission_share => 'Einen Trend teilen';

  @override
  String get mission_report => 'Wochenbericht ansehen';

  @override
  String get mission_fav => '5 Produkte zu Favoriten hinzufügen';

  @override
  String get mission_event => 'An einer Veranstaltung teilnehmen';

  @override
  String get missions_tab => 'Missionen';

  @override
  String get success_tab => 'Erfolge';

  @override
  String get boutique_tab => 'Shop';

  @override
  String get claim_btn => 'Beanspruchen';

  @override
  String get tab_populaires => 'Beliebt';

  @override
  String get tab_suivis => 'Folgen';

  @override
  String get tab_webinaires => 'Webinare';

  @override
  String get tab_lancements => 'Starts';

  @override
  String get no_events => 'Keine Ereignisse gefunden';

  @override
  String get no_posts => 'Keine Beiträge gefunden';

  @override
  String get no_badges_found => 'Aucun badge trouvé';

  @override
  String get reward_pro => 'Pro-Analyse';

  @override
  String get reward_pro_desc => 'Eingehende Produktanalyse';

  @override
  String get reward_trend => 'Erweiterte Trends';

  @override
  String get reward_trend_desc => 'Zugriff auf erweiterte Trends';

  @override
  String get reward_social => 'Social Dev';

  @override
  String get reward_social_desc => 'Social-Media-Entwickler';

  @override
  String get reward_bonus => 'Diamant-Bonus';

  @override
  String get reward_bonus_desc => 'Exklusive Belohnung';

  @override
  String get success_report => 'Premium-Bericht';

  @override
  String get success_report_desc => 'Analyse aller Produkte';

  @override
  String get success_badge => 'Exklusives Abzeichen';

  @override
  String get success_badge_desc => 'Abzeichen für Elite-Mitglieder';

  @override
  String get success_vip => 'Event VIP-Zugang';

  @override
  String get success_vip_desc => 'Bevorzugter Zugang zu Veranstaltungen';

  @override
  String get success_boost => 'XP Boost x2';

  @override
  String get success_boost_desc => 'Doppelte XP für 24 Stunden';

  @override
  String get tag_new => 'Neu';

  @override
  String reset_timer(Object hours) {
    return 'Wird in ${hours}h zurückgesetzt';
  }

  @override
  String get your_balance => 'Ihr Kontostand';

  @override
  String get activate_btn => 'Aktivieren';

  @override
  String get popular_tag => 'BELIEBT';

  @override
  String get coins_label => 'MÜNZEN';

  @override
  String get upcoming => 'Anstehend';

  @override
  String this_week(int count) {
    return '+$count diese Woche';
  }

  @override
  String get registrations => 'Anmeldungen';

  @override
  String in_queue(int count) {
    return '$count in der Warteschlange';
  }

  @override
  String get view_calendar => 'Kalender anzeigen';

  @override
  String get product_launch_tag => 'Produkteinführung';

  @override
  String get no_events_found => 'Keine Ereignisse gefunden';

  @override
  String get tab_tous => 'Alle';

  @override
  String get online => 'Online';

  @override
  String get free => 'Kostenlos';

  @override
  String get atelier => 'Workshop';

  @override
  String get conference => 'Konferenz';

  @override
  String get populaire_tag => 'Beliebt';

  @override
  String participants(String count) {
    return '$count Teilnehmer';
  }

  @override
  String get active_members => 'Aktive Mitglieder';

  @override
  String get daily_posts => 'Tägliche Beiträge';

  @override
  String get community_growth => 'Wachstum';

  @override
  String get tab_for_you => 'Für dich';

  @override
  String post_time(int count) {
    return 'vor ${count}h';
  }

  @override
  String get no_posts_found => 'Keine Beiträge gefunden';

  @override
  String get members_online => 'Mitglieder online';

  @override
  String get trending_topics => 'Trendthemen';

  @override
  String get search_find_winning => 'Gewinnerprodukte finden';

  @override
  String get search_analyze_hint => 'Markt in Echtzeit analysieren';

  @override
  String get search_input_hint =>
      'Suchen Sie nach einem Schlüsselwort oder Produkt...';

  @override
  String get search_no_results => 'Keine Ergebnisse gefunden';

  @override
  String get search_global_score => 'Gesamtpunktzahl';

  @override
  String get filter_trending => 'Trend-Kategorien';

  @override
  String get filter_margin => 'Hohe geschätzte Marge';

  @override
  String get filter_new => 'Neue Produkteinführungen';

  @override
  String get filter_viral => 'Hoher Viralitäts-Score';

  @override
  String get dashboard_title => 'Mein Dashboard';

  @override
  String get stat_analyzed => 'Dateien\nAnalysiert';

  @override
  String get stat_support => 'Support\nStunden';

  @override
  String get stat_tasks => 'Aktive\nAufgaben';

  @override
  String get period_this_week => 'Diese Woche';

  @override
  String get period_this_month => 'Diesen Monat';

  @override
  String get period_total => 'Gesamt';

  @override
  String get score_evolution => 'Durchschnittliche Score-Entwicklung';

  @override
  String get detailed_stats_title => 'Detaillierte Statistiken';

  @override
  String get stat_detailed_analyzed => 'Analysierte Produktdateien';

  @override
  String get stat_detailed_economic => 'Wirtschaftliche Produkte';

  @override
  String get since_beginning => 'Seit Beginn';

  @override
  String get total_time_label => 'Gesamtzeit';

  @override
  String get streak_days_title => 'Aktive Beobachtungstage';

  @override
  String streak_days_msg(int count) {
    return 'Du bist in Topform! $count aufeinanderfolgende Tage aktiver Beobachtung.';
  }

  @override
  String get cancel_renewal => 'Verlängerung kündigen';

  @override
  String get view_billing => 'Rechnungsverlauf und Belege anzeigen';

  @override
  String get compare_plans => 'Alle Pläne vergleichen';

  @override
  String get enter_otp => 'Bitte geben Sie den OTP-Code ein';

  @override
  String get otp_verified => 'Code erfolgreich verifiziert!';

  @override
  String get code_sent => 'Ein neuer Code wurde an Ihre E-Mail gesendet';

  @override
  String get contact_btn => 'Kontakt';

  @override
  String get view_btn => 'Ansehen';

  @override
  String get save_btn => 'Speichern';

  @override
  String view_on_source(String source) {
    return 'Auf $source ansehen';
  }

  @override
  String get code_copied => 'Code kopiert!';

  @override
  String get name_label => 'Name';

  @override
  String get points_label => 'Punkte';

  @override
  String sharing_code(String code) {
    return 'Ich teile meinen Code: $code';
  }

  @override
  String get selling_price => 'Verkaufspreis';

  @override
  String get estimated_profit => 'Geschätzter Gewinn';

  @override
  String get pricing_disclaimer =>
      'Diese Preise sind Schätzungen und können je nach bestellter Menge variieren';

  @override
  String get performance_analysis => 'Performance-Analyse';

  @override
  String get market_insights => 'Markteinblicke';

  @override
  String get trending_up_label => 'Aufwärtstrend';

  @override
  String get strong_demand_label => 'Starke Nachfrage';

  @override
  String get large_margin_label => 'Große Marge';

  @override
  String monthly_sales_est(String count) {
    return 'Geschätzte ${count}K+ monatliche Verkäufe';
  }

  @override
  String profit_margin_est(String percent) {
    return '$percent% Gewinnspanne';
  }

  @override
  String get supplier_label => 'Lieferant';

  @override
  String reviews_count(String rating, String count) {
    return '$rating/5 • $count Bewertungen';
  }

  @override
  String get supplier_price => 'Lieferantenpreis';

  @override
  String get email_verification => 'E-Mail-Verifizierung';

  @override
  String get verify_your_email => 'Verifizieren Sie Ihre E-Mail';

  @override
  String get otp_description =>
      'Ein 6-stelliger Verifizierungscode wurde gesendet an';

  @override
  String get did_not_receive_code => 'Code nicht erhalten?';

  @override
  String get resend_btn => 'Erneut senden';

  @override
  String get otp_expiry => 'Der Code läuft nach 10 Minuten ab';

  @override
  String get go_to_search_btn => 'Zur Suche gehen...';

  @override
  String get sign_up_btn => 'Registrieren';

  @override
  String get audio_tech_category => 'Audio & Technik';

  @override
  String get product_desc_fallback =>
      'Hochwertige Bluetooth-Audiokopfhörer mit aktiver Geräuschunterdrückung, 30 Stunden Akkulaufzeit und ergonomischem Design für optimalen Komfort.';

  @override
  String get product_view_details => 'Produktdetails anzeigen';

  @override
  String get product_title_fallback => 'Premium-Funkkopfhörer';

  @override
  String get score => 'Punktzahl';

  @override
  String get my_favorites => 'Meine Favoriten';

  @override
  String saved_products_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gespeicherte Produkte',
      one: '1 gespeichertes Produkt',
      zero: 'Keine gespeicherten Produkte',
    );
    return '$_temp0';
  }

  @override
  String get empty_watchlist_title => 'Ihre Merkliste ist leer';

  @override
  String get empty_watchlist_subtitle =>
      'Finden Sie zunächst Gewinnprodukte, um sie zu überwachen.';

  @override
  String get discover_trending_title => 'Trendprodukte entdecken';

  @override
  String get discover_trending_subtitle =>
      'Finden Sie Produkte mit hohem Potenzial, um Ihre personalisierte Überwachung zu starten.';

  @override
  String get start_search_btn => 'Suche starten';

  @override
  String get advice_title => 'Rat';

  @override
  String get advice_subtitle =>
      'Überprüfen Sie regelmäßig Ihre Favoriten, um die Entwicklung von Trends und Ergebnissen zu verfolgen';

  @override
  String get discover_more_products_btn => 'Mehr Produkte entdecken';

  @override
  String get unknown_product => 'Unbekanntes Produkt';

  @override
  String get recently_added => 'Vor kurzem';

  @override
  String get price_label => 'Preis';

  @override
  String get profit_label => 'Profit';

  @override
  String get tracked_products => 'Verfolgte Produkte';

  @override
  String get active_trends => 'Aktive Trends';

  @override
  String get pro_plan => 'Pro-Plan';

  @override
  String active_until(Object date) {
    return 'Aktiv bis $date';
  }

  @override
  String get theme_color => 'Themenfarbe';

  @override
  String get choose_avatar => 'Wähle einen Avatar';

  @override
  String get verify_account_btn => 'Konto verifizieren';

  @override
  String get referral_rewards => 'Empfehlungsbelohnungen';

  @override
  String get active_referrals => 'Aktive Empfehlungen';

  @override
  String get points_earned => 'Verdiente Punkte';

  @override
  String get how_it_works => 'Wie funktioniert es?';

  @override
  String get referral_step_1 => 'Teile deinen einzigartigen Code';

  @override
  String get referral_step_2 => 'Deine Freunde melden sich an';

  @override
  String get referral_step_3 => 'Verdiene Bonuspunkte';

  @override
  String get your_referral_code => 'Dein Empfehlungscode';

  @override
  String get my_referrals => 'Meine Empfehlungen';

  @override
  String get share_code_btn => 'Meinen Code teilen';

  @override
  String get unlimited_alerts => 'Unbegrenzte Warnungen';

  @override
  String get complete_analysis => 'Vollständige Analysen';

  @override
  String get priority_support => 'Prioritärer Support';

  @override
  String get sales_volume_analysis => 'Verkaufsvolumenanalyse';

  @override
  String get data_export => 'Datenexport';

  @override
  String get benefits_included => 'Enthaltene Vorteile';

  @override
  String get manage_payment => 'Zahlung verwalten';

  @override
  String get upgrade_premium => 'Auf Premium upgraden';

  @override
  String get my_subscription => 'Mein Abonnement';

  @override
  String get your_current_plan => 'Dein aktueller Plan';

  @override
  String get premium_monthly => 'Premium Monatlich';

  @override
  String get free_plan => 'Kostenloser Plan';

  @override
  String get freemium_limit => 'Kostenloses Limit erreicht';

  @override
  String get demand_label => 'Nachfrage';

  @override
  String get profitability_label => 'Rentabilität';

  @override
  String get competition_label => 'Wettbewerb';

  @override
  String get trend_label => 'Trend';

  @override
  String get preferences => 'Einstellungen';

  @override
  String get support_section => 'Support';

  @override
  String get notifications_label => 'Benachrichtigungen';

  @override
  String get privacy_label => 'Datenschutz';

  @override
  String get help_center => 'Hilfe-Center';

  @override
  String get upgrade_to_pro => 'Auf Pro upgraden';

  @override
  String get data_security => 'Daten & Sicherheit';

  @override
  String get faq_tutorials => 'FAQ & Tutorials';

  @override
  String get unlock_all_features => 'Alle Funktionen freischalten';

  @override
  String get alerts_trends => 'Warnungen & Trends';

  @override
  String get verification_title => 'Verifizierung';

  @override
  String get verification_desc =>
      'Geben Sie den Code ein, der gesendet wurde an';

  @override
  String get profile_label => 'Profil';

  @override
  String get verify_email_title => 'Überprüfen Sie Ihr Postfach';

  @override
  String get verification_sent_to =>
      'Wir haben einen Verifizierungscode\ngesendet an';

  @override
  String get verification_enter_code =>
      '. Bitte\ngeben Sie ihn unten ein, um Ihr Konto zu aktivieren.';

  @override
  String resend_code_timer(Object seconds) {
    return 'Code erneut senden ${seconds}s';
  }

  @override
  String get terms_privacy_notice =>
      'Durch Fortfahren akzeptieren Sie unsere Nutzungsbedingungen und unsere\nDatenschutzerklärung';

  @override
  String get login_title => 'Anmelden';

  @override
  String get login_welcome =>
      'Willkommen zurück! Melden Sie sich an, um fortzufahren';

  @override
  String get email_label => 'E-Mail';

  @override
  String get email_hint => 'sie@beispiel.de';

  @override
  String get password_label => 'Passwort';

  @override
  String get password_hint => '********';

  @override
  String get forgot_password_btn => 'Passwort vergessen?';

  @override
  String get signin_btn => 'Anmelden';

  @override
  String get dont_have_account => 'Noch kein Konto?';

  @override
  String get create_account_btn => 'Ein Konto erstellen';

  @override
  String get register_title => 'Registrieren';

  @override
  String get register_welcome =>
      'Willkommen! Erstellen Sie ein Konto, um loszulegen';

  @override
  String get already_have_account => 'Haben Sie bereits ein Konto?';

  @override
  String get signup_btn => 'Registrieren';

  @override
  String get full_name_label => 'Vollständiger Name';

  @override
  String get full_name_hint => 'Vorname Nachname';

  @override
  String get continue_with => 'Oder weiter mit';

  @override
  String get login_as_guest => 'Als Gast anmelden';

  @override
  String get confirm_password_label => 'Passwort bestätigen';

  @override
  String get user_label => 'Benutzer';

  @override
  String get forgot_password_desc =>
      'Geben Sie die mit Ihrem Konto verknüpfte E-Mail-Adresse ein und wir senden Ihnen einen Link zum Zurücksetzen Ihres Passworts.';

  @override
  String get send_link_btn => 'Link senden';

  @override
  String get reset_link_sent => 'Link zum Zurücksetzen gesendet!';

  @override
  String get verify_btn => 'Verifizieren';

  @override
  String get referral_status_joined => 'Beigetreten';

  @override
  String get referral_status_pending => 'Ausstehend';

  @override
  String get support_home_title => 'Support & Assistance';

  @override
  String get support_home_subtitle =>
      '\"Need help? Our team is here to support you in your success\"';

  @override
  String get send_email_title => 'Send us an email';

  @override
  String get send_email_subtitle => 'Response within 24h';

  @override
  String get chat_with_agent_title => 'Chat with an agent';

  @override
  String get chat_with_agent_subtitle => 'Available 7/7';

  @override
  String get faq_title => 'FAQs';

  @override
  String get faq_q1 => 'How does the AI find winning products?';

  @override
  String get faq_a1 =>
      'Our AI analyzes sales data, social trends, and market signals in real-time to identify products with the highest profit potential.';

  @override
  String get faq_q2 => 'How often are the products updated?';

  @override
  String get faq_a2 =>
      'Updates are made daily to ensure you have access to the latest market opportunities.';

  @override
  String get faq_q3 => 'Can I cancel my subscription at any time?';

  @override
  String get faq_a3 =>
      'Yes, you can cancel your subscription at any time from your profile settings without any additional fees.';

  @override
  String get faq_q4 => 'Are my searches confidential?';

  @override
  String get faq_a4 =>
      'Absolutely. Your search data and favorites are strictly private and are never shared with other users.';

  @override
  String get faq_q5 => 'How to contact support in case of a problem?';

  @override
  String get faq_a5 =>
      'You can contact us via the support form or by email. Our team generally responds in less than 24 hours.';

  @override
  String referral_share_msg(String code) {
    return 'Melde dich mit meinem Code $code an und erhalte Bonuspunkte!';
  }

  @override
  String get guest => 'Gast';
}
