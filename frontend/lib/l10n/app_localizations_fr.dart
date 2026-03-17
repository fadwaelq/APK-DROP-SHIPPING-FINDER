// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get nav_home => 'Accueil';

  @override
  String get nav_search => 'Recherche';

  @override
  String get nav_fav => 'Favoris';

  @override
  String get nav_profile => 'Profil';

  @override
  String get greeting => 'Bonjour,';

  @override
  String get profit_score => 'Score de Rentabilité';

  @override
  String get avg_profit => 'Profit moy.';

  @override
  String get products => 'Produits';

  @override
  String get top_niches => 'Top niches';

  @override
  String get trending_products => 'Produits Tendance';

  @override
  String get see_all => 'Voir tout';

  @override
  String get lang_title => 'Langue';

  @override
  String get settings_title => 'Paramètres & Préférences';

  @override
  String get confirm_lang_title => 'Changer la langue ?';

  @override
  String confirm_lang_body(String lang) {
    return 'Voulez-vous changer la langue de toute l\'application en $lang ?';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String lang_changed(String lang) {
    return 'La langue de l\'application est maintenant : $lang';
  }

  @override
  String get events => 'Événements';

  @override
  String get community => 'Communauté';

  @override
  String get rewards => 'Récompenses';

  @override
  String get pref_title => 'Préférences';

  @override
  String get support_title => 'Support';

  @override
  String get activity_title => 'Mes Activités';

  @override
  String get logout => 'Déconnexion';

  @override
  String get pref_general => 'Preference générale';

  @override
  String get lang_item => 'Langue';

  @override
  String get currency_item => 'Devise d\'affichage';

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
  String get change_pwd_item => 'changer le mot de passe';

  @override
  String get faceid_item => 'Activer Face ID | Touch ID';

  @override
  String get legal_support => 'Information Légales and Support';

  @override
  String get privacy_policy => 'Politique de confidentialité';

  @override
  String get app_version => 'Version de l\'application';

  @override
  String get contact_support => 'Contact Support & Assistance';

  @override
  String get coin_balance => 'Solde de Coins';

  @override
  String get active_streak => 'Série active';

  @override
  String days_streak(int count) {
    return '$count jours';
  }

  @override
  String get bonus_text => 'Bonus quotidien';

  @override
  String coins_per_day(int count) {
    return '+$count coins/jour';
  }

  @override
  String get history_btn => 'Historique';

  @override
  String get shop_btn => 'Boutique';

  @override
  String level_text(int level) {
    return 'Niveau $level';
  }

  @override
  String get elite_trader => 'Élite Trader';

  @override
  String xp_for_level(int nextLevel) {
    return 'XP pour niveau $nextLevel';
  }

  @override
  String get daily_missions => 'Missions Quotidiennes';

  @override
  String get weekly_missions => 'Missions Hebdomadaires';

  @override
  String mission_analyze(int count) {
    return 'Analyser $count produits aujourd\'hui';
  }

  @override
  String get mission_share => 'Partager une tendance';

  @override
  String get mission_report => 'Consulter le rapport hebdomadaire';

  @override
  String get mission_fav => 'Ajouter 5 produits aux favoris';

  @override
  String get mission_event => 'Participer à un événement';

  @override
  String get missions_tab => 'Missions';

  @override
  String get success_tab => 'Succès';

  @override
  String get boutique_tab => 'Boutique';

  @override
  String get claim_btn => 'Récupérer';

  @override
  String get tab_populaires => 'Populaires';

  @override
  String get tab_suivis => 'Suivis';

  @override
  String get tab_webinaires => 'Webinaires';

  @override
  String get tab_lancements => 'Lancements';

  @override
  String get no_events => 'Aucun événement trouvé';

  @override
  String get no_posts => 'Aucune publication trouvée';

  @override
  String get no_badges_found => 'Aucun badge trouvé';

  @override
  String get reward_pro => 'Analyse Pro';

  @override
  String get reward_pro_desc => 'Analyse approfondie de produits';

  @override
  String get reward_trend => 'Tendances Avancées';

  @override
  String get reward_trend_desc => 'Accès tendances avancées';

  @override
  String get reward_social => 'Social Dev';

  @override
  String get reward_social_desc => 'Développeur réseaux sociaux';

  @override
  String get reward_bonus => 'Bonus Diamant';

  @override
  String get reward_bonus_desc => 'Récompense exclusive';

  @override
  String get success_report => 'Rapport Premium';

  @override
  String get success_report_desc => 'Analyse de tous les produits';

  @override
  String get success_badge => 'Badge Exclusif';

  @override
  String get success_badge_desc => 'Badge pour les élite';

  @override
  String get success_vip => 'Accès VIP Événement';

  @override
  String get success_vip_desc => 'Accès prioritaire aux événements';

  @override
  String get success_boost => 'Boost XP x2';

  @override
  String get success_boost_desc => 'Double XP pendant 24h';

  @override
  String get tag_new => 'Nouveau';

  @override
  String reset_timer(Object hours) {
    return 'Se réinitialise dans ${hours}h';
  }

  @override
  String get your_balance => 'Votre solde';

  @override
  String get activate_btn => 'Activer';

  @override
  String get popular_tag => 'POPULAIRE';

  @override
  String get coins_label => 'COINS';

  @override
  String get upcoming => 'À venir';

  @override
  String this_week(int count) {
    return '+$count cette semaine';
  }

  @override
  String get registrations => 'Inscriptions';

  @override
  String in_queue(int count) {
    return '$count en file d\'attente';
  }

  @override
  String get view_calendar => 'Voir Calendrier';

  @override
  String get product_launch_tag => 'Lancement produit';

  @override
  String get no_events_found => 'Aucun événement trouvé';

  @override
  String get tab_tous => 'Tous';

  @override
  String get online => 'En ligne';

  @override
  String get free => 'Gratuit';

  @override
  String get atelier => 'Atelier';

  @override
  String get conference => 'Conférence';

  @override
  String get populaire_tag => 'Populaire';

  @override
  String participants(String count) {
    return '$count participants';
  }

  @override
  String get active_members => 'Membres Actifs';

  @override
  String get daily_posts => 'Posts Quotidiens';

  @override
  String get community_growth => 'Croissance';

  @override
  String get tab_for_you => 'Pour vous';

  @override
  String post_time(int count) {
    return 'il y a ${count}h';
  }

  @override
  String get no_posts_found => 'Aucune publication trouvée';

  @override
  String get members_online => 'Membres en ligne';

  @override
  String get trending_topics => 'Sujets tendances';

  @override
  String get search_find_winning => 'Trouver des produits gagnants';

  @override
  String get search_analyze_hint => 'Analysez le marché en temps réel';

  @override
  String get search_input_hint => 'Rechercher un mot-clé ou un produit...';

  @override
  String get search_no_results => 'Aucun résultat trouvé';

  @override
  String get search_global_score => 'Score Global';

  @override
  String get filter_trending => 'Catégories Tendance';

  @override
  String get filter_margin => 'Haute Marge Estimée';

  @override
  String get filter_new => 'Nouveaux Lancements';

  @override
  String get filter_viral => 'Score Viralité Élevé';

  @override
  String get dashboard_title => 'Mon Tableau de Bord';

  @override
  String get stat_analyzed => 'Fiches\nAnalysées';

  @override
  String get stat_support => 'Au Sav\nHeure';

  @override
  String get stat_tasks => 'Tâches\nActives';

  @override
  String get period_this_week => 'Cette semaine';

  @override
  String get period_this_month => 'Ce mois';

  @override
  String get period_total => 'Total';

  @override
  String get score_evolution => 'Évolution du Score Moyen';

  @override
  String get detailed_stats_title => 'Statistiques détaillées';

  @override
  String get stat_detailed_analyzed => 'Fiches Produits Analysées';

  @override
  String get stat_detailed_economic => 'Produits Économiques';

  @override
  String get since_beginning => 'Depuis le début';

  @override
  String get total_time_label => 'Temps total';

  @override
  String get streak_days_title => 'Série de Jours de Veille';

  @override
  String streak_days_msg(int count) {
    return 'Vous êtes en feu ! $count jours consécutifs de veille active.';
  }

  @override
  String get cancel_renewal => 'Annuler le renouvellement';

  @override
  String get view_billing => 'Voir l\'historique des factures et reçus';

  @override
  String get compare_plans => 'Comparer tous les plans';

  @override
  String get enter_otp => 'Veuillez entrer le code OTP';

  @override
  String get otp_verified => 'Code vérifié avec succès !';

  @override
  String get code_sent => 'Un nouveau code a été envoyé à votre email';

  @override
  String get contact_btn => 'Contacter';

  @override
  String get view_btn => 'Voir';

  @override
  String get save_btn => 'Enregistrer';

  @override
  String view_on_source(String source) {
    return 'Voir sur $source';
  }

  @override
  String get code_copied => 'Code copié !';

  @override
  String get name_label => 'Nom';

  @override
  String get points_label => 'Points';

  @override
  String sharing_code(String code) {
    return 'Je partage mon code : $code';
  }

  @override
  String get selling_price => 'Prix de vente';

  @override
  String get estimated_profit => 'Profit estimé';

  @override
  String get pricing_disclaimer =>
      'Ces prix sont estimés et peuvent varier en fonction de la quantité commandée';

  @override
  String get performance_analysis => 'Analyse de Performance';

  @override
  String get market_insights => 'Insights Marché';

  @override
  String get trending_up_label => 'Tendance à la hausse';

  @override
  String get strong_demand_label => 'Forte demande';

  @override
  String get large_margin_label => 'Marge importante';

  @override
  String monthly_sales_est(String count) {
    return '${count}K+ ventes mensuelles estimées';
  }

  @override
  String profit_margin_est(String percent) {
    return '$percent% de marge bénéficiaire';
  }

  @override
  String get supplier_label => 'Fournisseur';

  @override
  String reviews_count(String rating, String count) {
    return '$rating/5 • $count avis';
  }

  @override
  String get supplier_price => 'Prix fournisseur';

  @override
  String get email_verification => 'Vérification Email';

  @override
  String get verify_your_email => 'Vérifiez votre email';

  @override
  String get otp_description =>
      'Un code de vérification à 6 chiffres a été envoyé à';

  @override
  String get did_not_receive_code => 'Vous n\'avez pas reçu le code ?';

  @override
  String get resend_btn => 'Renvoyer';

  @override
  String get otp_expiry => 'Le code expire après 10 minutes';

  @override
  String get go_to_search_btn => 'Aller à la recherche...';

  @override
  String get sign_up_btn => 'S\'inscrire';

  @override
  String get audio_tech_category => 'Audio & Tech';

  @override
  String get product_desc_fallback =>
      'Casque audio Bluetooth haute qualité avec réduction de bruit active, autonomie de 30h et design ergonomique pour un confort optimal.';

  @override
  String get product_view_details => 'Voir les détails du produit';

  @override
  String get product_title_fallback => 'Casque Sans-fil Premium';

  @override
  String get score => 'Score';

  @override
  String get my_favorites => 'Mes Favoris';

  @override
  String saved_products_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits sauvegardés',
      one: '1 produit sauvegardé',
      zero: 'Aucun produit sauvegardé',
    );
    return '$_temp0';
  }

  @override
  String get empty_watchlist_title => 'Votre Liste de Veille est Vide';

  @override
  String get empty_watchlist_subtitle =>
      'Commencez par trouver des produits gagnants pour les surveiller.';

  @override
  String get discover_trending_title => 'Découvrez les Produits Tendance';

  @override
  String get discover_trending_subtitle =>
      'Trouvez des produits à fort potentiel pour commencer votre veille personnalisée.';

  @override
  String get start_search_btn => 'Commencer la recherche';

  @override
  String get advice_title => 'Conseil';

  @override
  String get advice_subtitle =>
      'Consultez régulièrement vos favoris pour suivre l\'évolution des tendances et des scores';

  @override
  String get discover_more_products_btn => 'Découvrir plus de produits';

  @override
  String get unknown_product => 'Produit Inconnu';

  @override
  String get recently_added => 'Récemment';

  @override
  String get price_label => 'Prix';

  @override
  String get profit_label => 'Profit';

  @override
  String get tracked_products => 'Produits suivis';

  @override
  String get active_trends => 'Tendances actives';

  @override
  String get pro_plan => 'Plan Pro';

  @override
  String active_until(Object date) {
    return 'Actif jusqu\'au $date';
  }

  @override
  String get theme_color => 'Couleur de thème';

  @override
  String get choose_avatar => 'Choisir un avatar';

  @override
  String get verify_account_btn => 'Vérifier le compte';

  @override
  String get referral_rewards => 'Récompenses de parrainage';

  @override
  String get active_referrals => 'Filleuls actifs';

  @override
  String get points_earned => 'Points gagnés';

  @override
  String get how_it_works => 'Comment ça marche ?';

  @override
  String get referral_step_1 => 'Partagez votre code unique';

  @override
  String get referral_step_2 => 'Vos amis s\'inscrivent';

  @override
  String get referral_step_3 => 'Gagnez des points bonus';

  @override
  String get your_referral_code => 'Votre code de parrainage';

  @override
  String get my_referrals => 'Mes parrainages';

  @override
  String get share_code_btn => 'Partager mon code';

  @override
  String get unlimited_alerts => 'Alertes illimitées';

  @override
  String get complete_analysis => 'Analyses complètes';

  @override
  String get priority_support => 'Support prioritaire';

  @override
  String get sales_volume_analysis => 'Analyse volume de ventes';

  @override
  String get data_export => 'Export de données';

  @override
  String get benefits_included => 'Avantages inclus';

  @override
  String get manage_payment => 'Gérer le paiement';

  @override
  String get upgrade_premium => 'Passer Premium';

  @override
  String get my_subscription => 'Mon abonnement';

  @override
  String get your_current_plan => 'Votre forfait actuel';

  @override
  String get premium_monthly => 'Premium Mensuel';

  @override
  String get free_plan => 'Forfait Gratuit';

  @override
  String get freemium_limit => 'Limite freemium atteinte';

  @override
  String get demand_label => 'Demande';

  @override
  String get profitability_label => 'Rentabilité';

  @override
  String get competition_label => 'Concurrence';

  @override
  String get trend_label => 'Tendance';

  @override
  String get preferences => 'Préférences';

  @override
  String get support_section => 'Support';

  @override
  String get notifications_label => 'Notifications';

  @override
  String get privacy_label => 'Confidentialité';

  @override
  String get help_center => 'Centre d\'aide';

  @override
  String get upgrade_to_pro => 'Passer à Pro';

  @override
  String get data_security => 'Données et sécurité';

  @override
  String get faq_tutorials => 'FAQ et tutoriels';

  @override
  String get unlock_all_features => 'Débloquer toutes les fonctionnalités';

  @override
  String get alerts_trends => 'Alertes et tendances';

  @override
  String get verification_title => 'Vérification';

  @override
  String get verification_desc => 'Entrez le code envoyé à';

  @override
  String get profile_label => 'Profil';

  @override
  String get verify_email_title => 'Vérifiez votre boîte mail';

  @override
  String get verification_sent_to =>
      'Nous avons envoyé un code\nde vérification à';

  @override
  String get verification_enter_code =>
      '. Veuillez\nle saisir ci-dessous pour activer votre compte.';

  @override
  String resend_code_timer(Object seconds) {
    return 'Renvoyer le code ${seconds}s';
  }

  @override
  String get terms_privacy_notice =>
      'En continuant, vous acceptez nos conditions d\'utilisation et notre\npolitique de confidentialité';

  @override
  String get login_title => 'Connexion';

  @override
  String get login_welcome => 'Bienvenue ! Connectez-vous pour continuer';

  @override
  String get email_label => 'Email';

  @override
  String get email_hint => 'vous@exemple.com';

  @override
  String get password_label => 'Mot de passe';

  @override
  String get password_hint => '********';

  @override
  String get forgot_password_btn => 'Mot de passe oublié ?';

  @override
  String get signin_btn => 'Se connecter';

  @override
  String get dont_have_account => 'Pas encore de compte ?';

  @override
  String get create_account_btn => 'Créer un compte';

  @override
  String get register_title => 'S\'inscrire';

  @override
  String get register_welcome => 'Bienvenue ! Créez un compte pour commencer';

  @override
  String get already_have_account => 'Déjà un compte ?';

  @override
  String get signup_btn => 'S\'inscrire';

  @override
  String get full_name_label => 'Nom complet';

  @override
  String get full_name_hint => 'Prénom Nom';

  @override
  String get continue_with => 'Ou continuez avec';

  @override
  String get login_as_guest => 'Se connecter en tant qu\'invité';

  @override
  String get confirm_password_label => 'Confirmer le mot de passe';

  @override
  String get user_label => 'Utilisateur';

  @override
  String get forgot_password_desc =>
      'Saisissez l\'adresse e-mail associée à votre compte et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get send_link_btn => 'Envoyer le lien';

  @override
  String get reset_link_sent => 'Lien de réinitialisation envoyé !';

  @override
  String get verify_btn => 'Vérifier';

  @override
  String get referral_status_joined => 'Inscrit';

  @override
  String get referral_status_pending => 'En attente';

  @override
  String get support_home_title => 'Support & Assistance';

  @override
  String get support_home_subtitle =>
      '\"Besoin d\'aide ? Notre équipe est là pour vous accompagner dans votre réussite\"';

  @override
  String get send_email_title => 'Envoyez-nous un e-mail';

  @override
  String get send_email_subtitle => 'Réponse sous 24h';

  @override
  String get chat_with_agent_title => 'Discuter avec un agent';

  @override
  String get chat_with_agent_subtitle => 'Disponible 7j/7';

  @override
  String get faq_title => 'FAQs';

  @override
  String get faq_q1 => 'Comment l\'IA trouve-t-elle les produits gagnants ?';

  @override
  String get faq_a1 =>
      'Notre IA analyse en temps réel les données de ventes, les tendances sociales et les signaux du marché pour identifier les produits avec le plus haut potentiel de profit.';

  @override
  String get faq_q2 => 'À quelle fréquence les produits sont-ils mis à jour ?';

  @override
  String get faq_a2 =>
      'Les mises à jour sont effectuées quotidiennement pour vous garantir l\'accès aux dernières opportunités du marché.';

  @override
  String get faq_q3 => 'Puis-je annuler mon abonnement à tout moment ?';

  @override
  String get faq_a3 =>
      'Oui, vous pouvez annuler votre abonnement à tout moment depuis vos paramètres de profil sans aucun frais supplémentaire.';

  @override
  String get faq_q4 => 'Mes recherches sont-elles confidentielles ?';

  @override
  String get faq_a4 =>
      'Absolument. Vos données de recherche et vos favoris sont strictement privés et ne sont jamais partagés avec d\'autres utilisateurs.';

  @override
  String get faq_q5 => 'Comment contacter le support en cas de problème ?';

  @override
  String get faq_a5 =>
      'Vous pouvez nous contacter via le formulaire d\'assistance ou par email. Notre équipe répond généralement en moins de 24 heures.';

  @override
  String referral_share_msg(String code) {
    return 'Inscrivez-vous avec mon code $code et gagnez des bonus !';
  }

  @override
  String get guest => 'Invité';
}
