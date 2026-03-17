import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @nav_home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get nav_home;

  /// No description provided for @nav_search.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get nav_search;

  /// No description provided for @nav_fav.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get nav_fav;

  /// No description provided for @nav_profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get nav_profile;

  /// No description provided for @greeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour,'**
  String get greeting;

  /// No description provided for @profit_score.
  ///
  /// In fr, this message translates to:
  /// **'Score de Rentabilité'**
  String get profit_score;

  /// No description provided for @avg_profit.
  ///
  /// In fr, this message translates to:
  /// **'Profit moy.'**
  String get avg_profit;

  /// No description provided for @products.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get products;

  /// No description provided for @top_niches.
  ///
  /// In fr, this message translates to:
  /// **'Top niches'**
  String get top_niches;

  /// No description provided for @trending_products.
  ///
  /// In fr, this message translates to:
  /// **'Produits Tendance'**
  String get trending_products;

  /// No description provided for @see_all.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get see_all;

  /// No description provided for @lang_title.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get lang_title;

  /// No description provided for @settings_title.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres & Préférences'**
  String get settings_title;

  /// No description provided for @confirm_lang_title.
  ///
  /// In fr, this message translates to:
  /// **'Changer la langue ?'**
  String get confirm_lang_title;

  /// No description provided for @confirm_lang_body.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous changer la langue de toute l\'application en {lang} ?'**
  String confirm_lang_body(String lang);

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @lang_changed.
  ///
  /// In fr, this message translates to:
  /// **'La langue de l\'application est maintenant : {lang}'**
  String lang_changed(String lang);

  /// No description provided for @events.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get events;

  /// No description provided for @community.
  ///
  /// In fr, this message translates to:
  /// **'Communauté'**
  String get community;

  /// No description provided for @rewards.
  ///
  /// In fr, this message translates to:
  /// **'Récompenses'**
  String get rewards;

  /// No description provided for @pref_title.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get pref_title;

  /// No description provided for @support_title.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get support_title;

  /// No description provided for @activity_title.
  ///
  /// In fr, this message translates to:
  /// **'Mes Activités'**
  String get activity_title;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @pref_general.
  ///
  /// In fr, this message translates to:
  /// **'Preference générale'**
  String get pref_general;

  /// No description provided for @lang_item.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get lang_item;

  /// No description provided for @currency_item.
  ///
  /// In fr, this message translates to:
  /// **'Devise d\'affichage'**
  String get currency_item;

  /// No description provided for @currency_usd.
  ///
  /// In fr, this message translates to:
  /// **'Dollar Américain'**
  String get currency_usd;

  /// No description provided for @currency_eur.
  ///
  /// In fr, this message translates to:
  /// **'Euro'**
  String get currency_eur;

  /// No description provided for @currency_mad.
  ///
  /// In fr, this message translates to:
  /// **'Dirham Marocain'**
  String get currency_mad;

  /// No description provided for @currency_gbp.
  ///
  /// In fr, this message translates to:
  /// **'Livre Sterling'**
  String get currency_gbp;

  /// No description provided for @currency_sar.
  ///
  /// In fr, this message translates to:
  /// **'Riyal Saoudien'**
  String get currency_sar;

  /// No description provided for @change_pwd_item.
  ///
  /// In fr, this message translates to:
  /// **'changer le mot de passe'**
  String get change_pwd_item;

  /// No description provided for @faceid_item.
  ///
  /// In fr, this message translates to:
  /// **'Activer Face ID | Touch ID'**
  String get faceid_item;

  /// No description provided for @legal_support.
  ///
  /// In fr, this message translates to:
  /// **'Information Légales and Support'**
  String get legal_support;

  /// No description provided for @privacy_policy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacy_policy;

  /// No description provided for @app_version.
  ///
  /// In fr, this message translates to:
  /// **'Version de l\'application'**
  String get app_version;

  /// No description provided for @contact_support.
  ///
  /// In fr, this message translates to:
  /// **'Contact Support & Assistance'**
  String get contact_support;

  /// No description provided for @coin_balance.
  ///
  /// In fr, this message translates to:
  /// **'Solde de Coins'**
  String get coin_balance;

  /// No description provided for @active_streak.
  ///
  /// In fr, this message translates to:
  /// **'Série active'**
  String get active_streak;

  /// No description provided for @days_streak.
  ///
  /// In fr, this message translates to:
  /// **'{count} jours'**
  String days_streak(int count);

  /// No description provided for @bonus_text.
  ///
  /// In fr, this message translates to:
  /// **'Bonus quotidien'**
  String get bonus_text;

  /// No description provided for @coins_per_day.
  ///
  /// In fr, this message translates to:
  /// **'+{count} coins/jour'**
  String coins_per_day(int count);

  /// No description provided for @history_btn.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get history_btn;

  /// No description provided for @shop_btn.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get shop_btn;

  /// No description provided for @level_text.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level}'**
  String level_text(int level);

  /// No description provided for @elite_trader.
  ///
  /// In fr, this message translates to:
  /// **'Élite Trader'**
  String get elite_trader;

  /// No description provided for @xp_for_level.
  ///
  /// In fr, this message translates to:
  /// **'XP pour niveau {nextLevel}'**
  String xp_for_level(int nextLevel);

  /// No description provided for @daily_missions.
  ///
  /// In fr, this message translates to:
  /// **'Missions Quotidiennes'**
  String get daily_missions;

  /// No description provided for @weekly_missions.
  ///
  /// In fr, this message translates to:
  /// **'Missions Hebdomadaires'**
  String get weekly_missions;

  /// No description provided for @mission_analyze.
  ///
  /// In fr, this message translates to:
  /// **'Analyser {count} produits aujourd\'hui'**
  String mission_analyze(int count);

  /// No description provided for @mission_share.
  ///
  /// In fr, this message translates to:
  /// **'Partager une tendance'**
  String get mission_share;

  /// No description provided for @mission_report.
  ///
  /// In fr, this message translates to:
  /// **'Consulter le rapport hebdomadaire'**
  String get mission_report;

  /// No description provided for @mission_fav.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter 5 produits aux favoris'**
  String get mission_fav;

  /// No description provided for @mission_event.
  ///
  /// In fr, this message translates to:
  /// **'Participer à un événement'**
  String get mission_event;

  /// No description provided for @missions_tab.
  ///
  /// In fr, this message translates to:
  /// **'Missions'**
  String get missions_tab;

  /// No description provided for @success_tab.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success_tab;

  /// No description provided for @boutique_tab.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get boutique_tab;

  /// No description provided for @claim_btn.
  ///
  /// In fr, this message translates to:
  /// **'Récupérer'**
  String get claim_btn;

  /// No description provided for @tab_populaires.
  ///
  /// In fr, this message translates to:
  /// **'Populaires'**
  String get tab_populaires;

  /// No description provided for @tab_suivis.
  ///
  /// In fr, this message translates to:
  /// **'Suivis'**
  String get tab_suivis;

  /// No description provided for @tab_webinaires.
  ///
  /// In fr, this message translates to:
  /// **'Webinaires'**
  String get tab_webinaires;

  /// No description provided for @tab_lancements.
  ///
  /// In fr, this message translates to:
  /// **'Lancements'**
  String get tab_lancements;

  /// No description provided for @no_events.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement trouvé'**
  String get no_events;

  /// No description provided for @no_posts.
  ///
  /// In fr, this message translates to:
  /// **'Aucune publication trouvée'**
  String get no_posts;

  /// No description provided for @no_badges_found.
  ///
  /// In fr, this message translates to:
  /// **'Aucun badge trouvé'**
  String get no_badges_found;

  /// No description provided for @reward_pro.
  ///
  /// In fr, this message translates to:
  /// **'Analyse Pro'**
  String get reward_pro;

  /// No description provided for @reward_pro_desc.
  ///
  /// In fr, this message translates to:
  /// **'Analyse approfondie de produits'**
  String get reward_pro_desc;

  /// No description provided for @reward_trend.
  ///
  /// In fr, this message translates to:
  /// **'Tendances Avancées'**
  String get reward_trend;

  /// No description provided for @reward_trend_desc.
  ///
  /// In fr, this message translates to:
  /// **'Accès tendances avancées'**
  String get reward_trend_desc;

  /// No description provided for @reward_social.
  ///
  /// In fr, this message translates to:
  /// **'Social Dev'**
  String get reward_social;

  /// No description provided for @reward_social_desc.
  ///
  /// In fr, this message translates to:
  /// **'Développeur réseaux sociaux'**
  String get reward_social_desc;

  /// No description provided for @reward_bonus.
  ///
  /// In fr, this message translates to:
  /// **'Bonus Diamant'**
  String get reward_bonus;

  /// No description provided for @reward_bonus_desc.
  ///
  /// In fr, this message translates to:
  /// **'Récompense exclusive'**
  String get reward_bonus_desc;

  /// No description provided for @success_report.
  ///
  /// In fr, this message translates to:
  /// **'Rapport Premium'**
  String get success_report;

  /// No description provided for @success_report_desc.
  ///
  /// In fr, this message translates to:
  /// **'Analyse de tous les produits'**
  String get success_report_desc;

  /// No description provided for @success_badge.
  ///
  /// In fr, this message translates to:
  /// **'Badge Exclusif'**
  String get success_badge;

  /// No description provided for @success_badge_desc.
  ///
  /// In fr, this message translates to:
  /// **'Badge pour les élite'**
  String get success_badge_desc;

  /// No description provided for @success_vip.
  ///
  /// In fr, this message translates to:
  /// **'Accès VIP Événement'**
  String get success_vip;

  /// No description provided for @success_vip_desc.
  ///
  /// In fr, this message translates to:
  /// **'Accès prioritaire aux événements'**
  String get success_vip_desc;

  /// No description provided for @success_boost.
  ///
  /// In fr, this message translates to:
  /// **'Boost XP x2'**
  String get success_boost;

  /// No description provided for @success_boost_desc.
  ///
  /// In fr, this message translates to:
  /// **'Double XP pendant 24h'**
  String get success_boost_desc;

  /// No description provided for @tag_new.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get tag_new;

  /// No description provided for @reset_timer.
  ///
  /// In fr, this message translates to:
  /// **'Se réinitialise dans {hours}h'**
  String reset_timer(Object hours);

  /// No description provided for @your_balance.
  ///
  /// In fr, this message translates to:
  /// **'Votre solde'**
  String get your_balance;

  /// No description provided for @activate_btn.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get activate_btn;

  /// No description provided for @popular_tag.
  ///
  /// In fr, this message translates to:
  /// **'POPULAIRE'**
  String get popular_tag;

  /// No description provided for @coins_label.
  ///
  /// In fr, this message translates to:
  /// **'COINS'**
  String get coins_label;

  /// No description provided for @upcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get upcoming;

  /// No description provided for @this_week.
  ///
  /// In fr, this message translates to:
  /// **'+{count} cette semaine'**
  String this_week(int count);

  /// No description provided for @registrations.
  ///
  /// In fr, this message translates to:
  /// **'Inscriptions'**
  String get registrations;

  /// No description provided for @in_queue.
  ///
  /// In fr, this message translates to:
  /// **'{count} en file d\'attente'**
  String in_queue(int count);

  /// No description provided for @view_calendar.
  ///
  /// In fr, this message translates to:
  /// **'Voir Calendrier'**
  String get view_calendar;

  /// No description provided for @product_launch_tag.
  ///
  /// In fr, this message translates to:
  /// **'Lancement produit'**
  String get product_launch_tag;

  /// No description provided for @no_events_found.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement trouvé'**
  String get no_events_found;

  /// No description provided for @tab_tous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get tab_tous;

  /// No description provided for @online.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get online;

  /// No description provided for @free.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get free;

  /// No description provided for @atelier.
  ///
  /// In fr, this message translates to:
  /// **'Atelier'**
  String get atelier;

  /// No description provided for @conference.
  ///
  /// In fr, this message translates to:
  /// **'Conférence'**
  String get conference;

  /// No description provided for @populaire_tag.
  ///
  /// In fr, this message translates to:
  /// **'Populaire'**
  String get populaire_tag;

  /// No description provided for @participants.
  ///
  /// In fr, this message translates to:
  /// **'{count} participants'**
  String participants(String count);

  /// No description provided for @active_members.
  ///
  /// In fr, this message translates to:
  /// **'Membres Actifs'**
  String get active_members;

  /// No description provided for @daily_posts.
  ///
  /// In fr, this message translates to:
  /// **'Posts Quotidiens'**
  String get daily_posts;

  /// No description provided for @community_growth.
  ///
  /// In fr, this message translates to:
  /// **'Croissance'**
  String get community_growth;

  /// No description provided for @tab_for_you.
  ///
  /// In fr, this message translates to:
  /// **'Pour vous'**
  String get tab_for_you;

  /// No description provided for @post_time.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count}h'**
  String post_time(int count);

  /// No description provided for @no_posts_found.
  ///
  /// In fr, this message translates to:
  /// **'Aucune publication trouvée'**
  String get no_posts_found;

  /// No description provided for @members_online.
  ///
  /// In fr, this message translates to:
  /// **'Membres en ligne'**
  String get members_online;

  /// No description provided for @trending_topics.
  ///
  /// In fr, this message translates to:
  /// **'Sujets tendances'**
  String get trending_topics;

  /// No description provided for @search_find_winning.
  ///
  /// In fr, this message translates to:
  /// **'Trouver des produits gagnants'**
  String get search_find_winning;

  /// No description provided for @search_analyze_hint.
  ///
  /// In fr, this message translates to:
  /// **'Analysez le marché en temps réel'**
  String get search_analyze_hint;

  /// No description provided for @search_input_hint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un mot-clé ou un produit...'**
  String get search_input_hint;

  /// No description provided for @search_no_results.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat trouvé'**
  String get search_no_results;

  /// No description provided for @search_global_score.
  ///
  /// In fr, this message translates to:
  /// **'Score Global'**
  String get search_global_score;

  /// No description provided for @filter_trending.
  ///
  /// In fr, this message translates to:
  /// **'Catégories Tendance'**
  String get filter_trending;

  /// No description provided for @filter_margin.
  ///
  /// In fr, this message translates to:
  /// **'Haute Marge Estimée'**
  String get filter_margin;

  /// No description provided for @filter_new.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux Lancements'**
  String get filter_new;

  /// No description provided for @filter_viral.
  ///
  /// In fr, this message translates to:
  /// **'Score Viralité Élevé'**
  String get filter_viral;

  /// No description provided for @dashboard_title.
  ///
  /// In fr, this message translates to:
  /// **'Mon Tableau de Bord'**
  String get dashboard_title;

  /// No description provided for @stat_analyzed.
  ///
  /// In fr, this message translates to:
  /// **'Fiches\nAnalysées'**
  String get stat_analyzed;

  /// No description provided for @stat_support.
  ///
  /// In fr, this message translates to:
  /// **'Au Sav\nHeure'**
  String get stat_support;

  /// No description provided for @stat_tasks.
  ///
  /// In fr, this message translates to:
  /// **'Tâches\nActives'**
  String get stat_tasks;

  /// No description provided for @period_this_week.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get period_this_week;

  /// No description provided for @period_this_month.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get period_this_month;

  /// No description provided for @period_total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get period_total;

  /// No description provided for @score_evolution.
  ///
  /// In fr, this message translates to:
  /// **'Évolution du Score Moyen'**
  String get score_evolution;

  /// No description provided for @detailed_stats_title.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques détaillées'**
  String get detailed_stats_title;

  /// No description provided for @stat_detailed_analyzed.
  ///
  /// In fr, this message translates to:
  /// **'Fiches Produits Analysées'**
  String get stat_detailed_analyzed;

  /// No description provided for @stat_detailed_economic.
  ///
  /// In fr, this message translates to:
  /// **'Produits Économiques'**
  String get stat_detailed_economic;

  /// No description provided for @since_beginning.
  ///
  /// In fr, this message translates to:
  /// **'Depuis le début'**
  String get since_beginning;

  /// No description provided for @total_time_label.
  ///
  /// In fr, this message translates to:
  /// **'Temps total'**
  String get total_time_label;

  /// No description provided for @streak_days_title.
  ///
  /// In fr, this message translates to:
  /// **'Série de Jours de Veille'**
  String get streak_days_title;

  /// No description provided for @streak_days_msg.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes en feu ! {count} jours consécutifs de veille active.'**
  String streak_days_msg(int count);

  /// No description provided for @cancel_renewal.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le renouvellement'**
  String get cancel_renewal;

  /// No description provided for @view_billing.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'historique des factures et reçus'**
  String get view_billing;

  /// No description provided for @compare_plans.
  ///
  /// In fr, this message translates to:
  /// **'Comparer tous les plans'**
  String get compare_plans;

  /// No description provided for @enter_otp.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer le code OTP'**
  String get enter_otp;

  /// No description provided for @otp_verified.
  ///
  /// In fr, this message translates to:
  /// **'Code vérifié avec succès !'**
  String get otp_verified;

  /// No description provided for @code_sent.
  ///
  /// In fr, this message translates to:
  /// **'Un nouveau code a été envoyé à votre email'**
  String get code_sent;

  /// No description provided for @contact_btn.
  ///
  /// In fr, this message translates to:
  /// **'Contacter'**
  String get contact_btn;

  /// No description provided for @view_btn.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get view_btn;

  /// No description provided for @save_btn.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save_btn;

  /// No description provided for @view_on_source.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur {source}'**
  String view_on_source(String source);

  /// No description provided for @code_copied.
  ///
  /// In fr, this message translates to:
  /// **'Code copié !'**
  String get code_copied;

  /// No description provided for @name_label.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get name_label;

  /// No description provided for @points_label.
  ///
  /// In fr, this message translates to:
  /// **'Points'**
  String get points_label;

  /// No description provided for @sharing_code.
  ///
  /// In fr, this message translates to:
  /// **'Je partage mon code : {code}'**
  String sharing_code(String code);

  /// No description provided for @selling_price.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente'**
  String get selling_price;

  /// No description provided for @estimated_profit.
  ///
  /// In fr, this message translates to:
  /// **'Profit estimé'**
  String get estimated_profit;

  /// No description provided for @pricing_disclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Ces prix sont estimés et peuvent varier en fonction de la quantité commandée'**
  String get pricing_disclaimer;

  /// No description provided for @performance_analysis.
  ///
  /// In fr, this message translates to:
  /// **'Analyse de Performance'**
  String get performance_analysis;

  /// No description provided for @market_insights.
  ///
  /// In fr, this message translates to:
  /// **'Insights Marché'**
  String get market_insights;

  /// No description provided for @trending_up_label.
  ///
  /// In fr, this message translates to:
  /// **'Tendance à la hausse'**
  String get trending_up_label;

  /// No description provided for @strong_demand_label.
  ///
  /// In fr, this message translates to:
  /// **'Forte demande'**
  String get strong_demand_label;

  /// No description provided for @large_margin_label.
  ///
  /// In fr, this message translates to:
  /// **'Marge importante'**
  String get large_margin_label;

  /// No description provided for @monthly_sales_est.
  ///
  /// In fr, this message translates to:
  /// **'{count}K+ ventes mensuelles estimées'**
  String monthly_sales_est(String count);

  /// No description provided for @profit_margin_est.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% de marge bénéficiaire'**
  String profit_margin_est(String percent);

  /// No description provided for @supplier_label.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get supplier_label;

  /// No description provided for @reviews_count.
  ///
  /// In fr, this message translates to:
  /// **'{rating}/5 • {count} avis'**
  String reviews_count(String rating, String count);

  /// No description provided for @supplier_price.
  ///
  /// In fr, this message translates to:
  /// **'Prix fournisseur'**
  String get supplier_price;

  /// No description provided for @email_verification.
  ///
  /// In fr, this message translates to:
  /// **'Vérification Email'**
  String get email_verification;

  /// No description provided for @verify_your_email.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre email'**
  String get verify_your_email;

  /// No description provided for @otp_description.
  ///
  /// In fr, this message translates to:
  /// **'Un code de vérification à 6 chiffres a été envoyé à'**
  String get otp_description;

  /// No description provided for @did_not_receive_code.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas reçu le code ?'**
  String get did_not_receive_code;

  /// No description provided for @resend_btn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer'**
  String get resend_btn;

  /// No description provided for @otp_expiry.
  ///
  /// In fr, this message translates to:
  /// **'Le code expire après 10 minutes'**
  String get otp_expiry;

  /// No description provided for @go_to_search_btn.
  ///
  /// In fr, this message translates to:
  /// **'Aller à la recherche...'**
  String get go_to_search_btn;

  /// No description provided for @sign_up_btn.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get sign_up_btn;

  /// No description provided for @audio_tech_category.
  ///
  /// In fr, this message translates to:
  /// **'Audio & Tech'**
  String get audio_tech_category;

  /// No description provided for @product_desc_fallback.
  ///
  /// In fr, this message translates to:
  /// **'Casque audio Bluetooth haute qualité avec réduction de bruit active, autonomie de 30h et design ergonomique pour un confort optimal.'**
  String get product_desc_fallback;

  /// No description provided for @product_view_details.
  ///
  /// In fr, this message translates to:
  /// **'Voir les détails du produit'**
  String get product_view_details;

  /// No description provided for @product_title_fallback.
  ///
  /// In fr, this message translates to:
  /// **'Casque Sans-fil Premium'**
  String get product_title_fallback;

  /// No description provided for @score.
  ///
  /// In fr, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @my_favorites.
  ///
  /// In fr, this message translates to:
  /// **'Mes Favoris'**
  String get my_favorites;

  /// No description provided for @saved_products_count.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun produit sauvegardé} =1{1 produit sauvegardé} other{{count} produits sauvegardés}}'**
  String saved_products_count(num count);

  /// No description provided for @empty_watchlist_title.
  ///
  /// In fr, this message translates to:
  /// **'Votre Liste de Veille est Vide'**
  String get empty_watchlist_title;

  /// No description provided for @empty_watchlist_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Commencez par trouver des produits gagnants pour les surveiller.'**
  String get empty_watchlist_subtitle;

  /// No description provided for @discover_trending_title.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez les Produits Tendance'**
  String get discover_trending_title;

  /// No description provided for @discover_trending_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez des produits à fort potentiel pour commencer votre veille personnalisée.'**
  String get discover_trending_subtitle;

  /// No description provided for @start_search_btn.
  ///
  /// In fr, this message translates to:
  /// **'Commencer la recherche'**
  String get start_search_btn;

  /// No description provided for @advice_title.
  ///
  /// In fr, this message translates to:
  /// **'Conseil'**
  String get advice_title;

  /// No description provided for @advice_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Consultez régulièrement vos favoris pour suivre l\'évolution des tendances et des scores'**
  String get advice_subtitle;

  /// No description provided for @discover_more_products_btn.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir plus de produits'**
  String get discover_more_products_btn;

  /// No description provided for @unknown_product.
  ///
  /// In fr, this message translates to:
  /// **'Produit Inconnu'**
  String get unknown_product;

  /// No description provided for @recently_added.
  ///
  /// In fr, this message translates to:
  /// **'Récemment'**
  String get recently_added;

  /// No description provided for @price_label.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get price_label;

  /// No description provided for @profit_label.
  ///
  /// In fr, this message translates to:
  /// **'Profit'**
  String get profit_label;

  /// No description provided for @tracked_products.
  ///
  /// In fr, this message translates to:
  /// **'Produits suivis'**
  String get tracked_products;

  /// No description provided for @active_trends.
  ///
  /// In fr, this message translates to:
  /// **'Tendances actives'**
  String get active_trends;

  /// No description provided for @pro_plan.
  ///
  /// In fr, this message translates to:
  /// **'Plan Pro'**
  String get pro_plan;

  /// No description provided for @active_until.
  ///
  /// In fr, this message translates to:
  /// **'Actif jusqu\'au {date}'**
  String active_until(Object date);

  /// No description provided for @theme_color.
  ///
  /// In fr, this message translates to:
  /// **'Couleur de thème'**
  String get theme_color;

  /// No description provided for @choose_avatar.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un avatar'**
  String get choose_avatar;

  /// No description provided for @verify_account_btn.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le compte'**
  String get verify_account_btn;

  /// No description provided for @referral_rewards.
  ///
  /// In fr, this message translates to:
  /// **'Récompenses de parrainage'**
  String get referral_rewards;

  /// No description provided for @active_referrals.
  ///
  /// In fr, this message translates to:
  /// **'Filleuls actifs'**
  String get active_referrals;

  /// No description provided for @points_earned.
  ///
  /// In fr, this message translates to:
  /// **'Points gagnés'**
  String get points_earned;

  /// No description provided for @how_it_works.
  ///
  /// In fr, this message translates to:
  /// **'Comment ça marche ?'**
  String get how_it_works;

  /// No description provided for @referral_step_1.
  ///
  /// In fr, this message translates to:
  /// **'Partagez votre code unique'**
  String get referral_step_1;

  /// No description provided for @referral_step_2.
  ///
  /// In fr, this message translates to:
  /// **'Vos amis s\'inscrivent'**
  String get referral_step_2;

  /// No description provided for @referral_step_3.
  ///
  /// In fr, this message translates to:
  /// **'Gagnez des points bonus'**
  String get referral_step_3;

  /// No description provided for @your_referral_code.
  ///
  /// In fr, this message translates to:
  /// **'Votre code de parrainage'**
  String get your_referral_code;

  /// No description provided for @my_referrals.
  ///
  /// In fr, this message translates to:
  /// **'Mes parrainages'**
  String get my_referrals;

  /// No description provided for @share_code_btn.
  ///
  /// In fr, this message translates to:
  /// **'Partager mon code'**
  String get share_code_btn;

  /// No description provided for @unlimited_alerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes illimitées'**
  String get unlimited_alerts;

  /// No description provided for @complete_analysis.
  ///
  /// In fr, this message translates to:
  /// **'Analyses complètes'**
  String get complete_analysis;

  /// No description provided for @priority_support.
  ///
  /// In fr, this message translates to:
  /// **'Support prioritaire'**
  String get priority_support;

  /// No description provided for @sales_volume_analysis.
  ///
  /// In fr, this message translates to:
  /// **'Analyse volume de ventes'**
  String get sales_volume_analysis;

  /// No description provided for @data_export.
  ///
  /// In fr, this message translates to:
  /// **'Export de données'**
  String get data_export;

  /// No description provided for @benefits_included.
  ///
  /// In fr, this message translates to:
  /// **'Avantages inclus'**
  String get benefits_included;

  /// No description provided for @manage_payment.
  ///
  /// In fr, this message translates to:
  /// **'Gérer le paiement'**
  String get manage_payment;

  /// No description provided for @upgrade_premium.
  ///
  /// In fr, this message translates to:
  /// **'Passer Premium'**
  String get upgrade_premium;

  /// No description provided for @my_subscription.
  ///
  /// In fr, this message translates to:
  /// **'Mon abonnement'**
  String get my_subscription;

  /// No description provided for @your_current_plan.
  ///
  /// In fr, this message translates to:
  /// **'Votre forfait actuel'**
  String get your_current_plan;

  /// No description provided for @premium_monthly.
  ///
  /// In fr, this message translates to:
  /// **'Premium Mensuel'**
  String get premium_monthly;

  /// No description provided for @free_plan.
  ///
  /// In fr, this message translates to:
  /// **'Forfait Gratuit'**
  String get free_plan;

  /// No description provided for @freemium_limit.
  ///
  /// In fr, this message translates to:
  /// **'Limite freemium atteinte'**
  String get freemium_limit;

  /// No description provided for @demand_label.
  ///
  /// In fr, this message translates to:
  /// **'Demande'**
  String get demand_label;

  /// No description provided for @profitability_label.
  ///
  /// In fr, this message translates to:
  /// **'Rentabilité'**
  String get profitability_label;

  /// No description provided for @competition_label.
  ///
  /// In fr, this message translates to:
  /// **'Concurrence'**
  String get competition_label;

  /// No description provided for @trend_label.
  ///
  /// In fr, this message translates to:
  /// **'Tendance'**
  String get trend_label;

  /// No description provided for @preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferences;

  /// No description provided for @support_section.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get support_section;

  /// No description provided for @notifications_label.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications_label;

  /// No description provided for @privacy_label.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacy_label;

  /// No description provided for @help_center.
  ///
  /// In fr, this message translates to:
  /// **'Centre d\'aide'**
  String get help_center;

  /// No description provided for @upgrade_to_pro.
  ///
  /// In fr, this message translates to:
  /// **'Passer à Pro'**
  String get upgrade_to_pro;

  /// No description provided for @data_security.
  ///
  /// In fr, this message translates to:
  /// **'Données et sécurité'**
  String get data_security;

  /// No description provided for @faq_tutorials.
  ///
  /// In fr, this message translates to:
  /// **'FAQ et tutoriels'**
  String get faq_tutorials;

  /// No description provided for @unlock_all_features.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer toutes les fonctionnalités'**
  String get unlock_all_features;

  /// No description provided for @alerts_trends.
  ///
  /// In fr, this message translates to:
  /// **'Alertes et tendances'**
  String get alerts_trends;

  /// No description provided for @verification_title.
  ///
  /// In fr, this message translates to:
  /// **'Vérification'**
  String get verification_title;

  /// No description provided for @verification_desc.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code envoyé à'**
  String get verification_desc;

  /// No description provided for @profile_label.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile_label;

  /// No description provided for @verify_email_title.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre boîte mail'**
  String get verify_email_title;

  /// No description provided for @verification_sent_to.
  ///
  /// In fr, this message translates to:
  /// **'Nous avons envoyé un code\nde vérification à'**
  String get verification_sent_to;

  /// No description provided for @verification_enter_code.
  ///
  /// In fr, this message translates to:
  /// **'. Veuillez\nle saisir ci-dessous pour activer votre compte.'**
  String get verification_enter_code;

  /// No description provided for @resend_code_timer.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code {seconds}s'**
  String resend_code_timer(Object seconds);

  /// No description provided for @terms_privacy_notice.
  ///
  /// In fr, this message translates to:
  /// **'En continuant, vous acceptez nos conditions d\'utilisation et notre\npolitique de confidentialité'**
  String get terms_privacy_notice;

  /// No description provided for @login_title.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login_title;

  /// No description provided for @login_welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue ! Connectez-vous pour continuer'**
  String get login_welcome;

  /// No description provided for @email_label.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email_label;

  /// No description provided for @email_hint.
  ///
  /// In fr, this message translates to:
  /// **'vous@exemple.com'**
  String get email_hint;

  /// No description provided for @password_label.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password_label;

  /// No description provided for @password_hint.
  ///
  /// In fr, this message translates to:
  /// **'********'**
  String get password_hint;

  /// No description provided for @forgot_password_btn.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgot_password_btn;

  /// No description provided for @signin_btn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signin_btn;

  /// No description provided for @dont_have_account.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get dont_have_account;

  /// No description provided for @create_account_btn.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get create_account_btn;

  /// No description provided for @register_title.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register_title;

  /// No description provided for @register_welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue ! Créez un compte pour commencer'**
  String get register_welcome;

  /// No description provided for @already_have_account.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get already_have_account;

  /// No description provided for @signup_btn.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signup_btn;

  /// No description provided for @full_name_label.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get full_name_label;

  /// No description provided for @full_name_hint.
  ///
  /// In fr, this message translates to:
  /// **'Prénom Nom'**
  String get full_name_hint;

  /// No description provided for @continue_with.
  ///
  /// In fr, this message translates to:
  /// **'Ou continuez avec'**
  String get continue_with;

  /// No description provided for @login_as_guest.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter en tant qu\'invité'**
  String get login_as_guest;

  /// No description provided for @confirm_password_label.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirm_password_label;

  /// No description provided for @user_label.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get user_label;

  /// No description provided for @forgot_password_desc.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez l\'adresse e-mail associée à votre compte et nous vous enverrons un lien pour réinitialiser votre mot de passe.'**
  String get forgot_password_desc;

  /// No description provided for @send_link_btn.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get send_link_btn;

  /// No description provided for @reset_link_sent.
  ///
  /// In fr, this message translates to:
  /// **'Lien de réinitialisation envoyé !'**
  String get reset_link_sent;

  /// No description provided for @verify_btn.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get verify_btn;

  /// No description provided for @referral_status_joined.
  ///
  /// In fr, this message translates to:
  /// **'Inscrit'**
  String get referral_status_joined;

  /// No description provided for @referral_status_pending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get referral_status_pending;

  /// No description provided for @support_home_title.
  ///
  /// In fr, this message translates to:
  /// **'Support & Assistance'**
  String get support_home_title;

  /// No description provided for @support_home_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'\"Besoin d\'aide ? Notre équipe est là pour vous accompagner dans votre réussite\"'**
  String get support_home_subtitle;

  /// No description provided for @send_email_title.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez-nous un e-mail'**
  String get send_email_title;

  /// No description provided for @send_email_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Réponse sous 24h'**
  String get send_email_subtitle;

  /// No description provided for @chat_with_agent_title.
  ///
  /// In fr, this message translates to:
  /// **'Discuter avec un agent'**
  String get chat_with_agent_title;

  /// No description provided for @chat_with_agent_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Disponible 7j/7'**
  String get chat_with_agent_subtitle;

  /// No description provided for @faq_title.
  ///
  /// In fr, this message translates to:
  /// **'FAQs'**
  String get faq_title;

  /// No description provided for @faq_q1.
  ///
  /// In fr, this message translates to:
  /// **'Comment l\'IA trouve-t-elle les produits gagnants ?'**
  String get faq_q1;

  /// No description provided for @faq_a1.
  ///
  /// In fr, this message translates to:
  /// **'Notre IA analyse en temps réel les données de ventes, les tendances sociales et les signaux du marché pour identifier les produits avec le plus haut potentiel de profit.'**
  String get faq_a1;

  /// No description provided for @faq_q2.
  ///
  /// In fr, this message translates to:
  /// **'À quelle fréquence les produits sont-ils mis à jour ?'**
  String get faq_q2;

  /// No description provided for @faq_a2.
  ///
  /// In fr, this message translates to:
  /// **'Les mises à jour sont effectuées quotidiennement pour vous garantir l\'accès aux dernières opportunités du marché.'**
  String get faq_a2;

  /// No description provided for @faq_q3.
  ///
  /// In fr, this message translates to:
  /// **'Puis-je annuler mon abonnement à tout moment ?'**
  String get faq_q3;

  /// No description provided for @faq_a3.
  ///
  /// In fr, this message translates to:
  /// **'Oui, vous pouvez annuler votre abonnement à tout moment depuis vos paramètres de profil sans aucun frais supplémentaire.'**
  String get faq_a3;

  /// No description provided for @faq_q4.
  ///
  /// In fr, this message translates to:
  /// **'Mes recherches sont-elles confidentielles ?'**
  String get faq_q4;

  /// No description provided for @faq_a4.
  ///
  /// In fr, this message translates to:
  /// **'Absolument. Vos données de recherche et vos favoris sont strictement privés et ne sont jamais partagés avec d\'autres utilisateurs.'**
  String get faq_a4;

  /// No description provided for @faq_q5.
  ///
  /// In fr, this message translates to:
  /// **'Comment contacter le support en cas de problème ?'**
  String get faq_q5;

  /// No description provided for @faq_a5.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez nous contacter via le formulaire d\'assistance ou par email. Notre équipe répond généralement en moins de 24 heures.'**
  String get faq_a5;

  /// No description provided for @referral_share_msg.
  ///
  /// In fr, this message translates to:
  /// **'Inscrivez-vous avec mon code {code} et gagnez des bonus !'**
  String referral_share_msg(String code);

  /// No description provided for @guest.
  ///
  /// In fr, this message translates to:
  /// **'Invité'**
  String get guest;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
