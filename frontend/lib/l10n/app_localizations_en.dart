// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nav_home => 'Home';

  @override
  String get nav_search => 'Search';

  @override
  String get nav_fav => 'Favorites';

  @override
  String get nav_profile => 'Profile';

  @override
  String get greeting => 'Hello,';

  @override
  String get profit_score => 'Profitability Score';

  @override
  String get avg_profit => 'Avg Profit';

  @override
  String get products => 'Products';

  @override
  String get top_niches => 'Top Niches';

  @override
  String get trending_products => 'Trending Products';

  @override
  String get see_all => 'See all';

  @override
  String get lang_title => 'Language';

  @override
  String get settings_title => 'Settings & Preferences';

  @override
  String get confirm_lang_title => 'Change Language?';

  @override
  String confirm_lang_body(String lang) {
    return 'Do you want to change the application language to $lang?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String lang_changed(String lang) {
    return 'App language is now: $lang';
  }

  @override
  String get events => 'Events';

  @override
  String get community => 'Community';

  @override
  String get rewards => 'Rewards';

  @override
  String get pref_title => 'Preferences';

  @override
  String get support_title => 'Support';

  @override
  String get activity_title => 'My Activities';

  @override
  String get logout => 'Logout';

  @override
  String get pref_general => 'General Preference';

  @override
  String get lang_item => 'Language';

  @override
  String get currency_item => 'Display Currency';

  @override
  String get currency_usd => 'US Dollar';

  @override
  String get currency_eur => 'Euro';

  @override
  String get currency_mad => 'Moroccan Dirham';

  @override
  String get currency_gbp => 'British Pound';

  @override
  String get currency_sar => 'Saudi Riyal';

  @override
  String get change_pwd_item => 'Change password';

  @override
  String get faceid_item => 'Enable Face ID | Touch ID';

  @override
  String get legal_support => 'Legal Information and Support';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get app_version => 'App Version';

  @override
  String get contact_support => 'Contact Support & Assistance';

  @override
  String get coin_balance => 'Coin Balance';

  @override
  String get active_streak => 'Active streak';

  @override
  String days_streak(int count) {
    return '$count days';
  }

  @override
  String get bonus_text => 'Daily bonus';

  @override
  String coins_per_day(int count) {
    return '+$count coins/day';
  }

  @override
  String get history_btn => 'History';

  @override
  String get shop_btn => 'Shop';

  @override
  String level_text(int level) {
    return 'Level $level';
  }

  @override
  String get elite_trader => 'Elite Trader';

  @override
  String xp_for_level(int nextLevel) {
    return 'XP for level $nextLevel';
  }

  @override
  String get daily_missions => 'Daily Missions';

  @override
  String get weekly_missions => 'Weekly Missions';

  @override
  String mission_analyze(int count) {
    return 'Analyze $count products today';
  }

  @override
  String get mission_share => 'Share a trend';

  @override
  String get mission_report => 'View weekly report';

  @override
  String get mission_fav => 'Add 5 products to favorites';

  @override
  String get mission_event => 'Participate in an event';

  @override
  String get missions_tab => 'Missions';

  @override
  String get success_tab => 'Success';

  @override
  String get boutique_tab => 'Shop';

  @override
  String get claim_btn => 'Claim';

  @override
  String get tab_populaires => 'Popular';

  @override
  String get tab_suivis => 'Following';

  @override
  String get tab_webinaires => 'Webinars';

  @override
  String get tab_lancements => 'Launches';

  @override
  String get no_events => 'No events found';

  @override
  String get no_posts => 'No posts found';

  @override
  String get no_badges_found => 'No badges found';

  @override
  String get reward_pro => 'Pro Analysis';

  @override
  String get reward_pro_desc => 'In-depth product analysis';

  @override
  String get reward_trend => 'Advanced Trends';

  @override
  String get reward_trend_desc => 'Access to advanced trends';

  @override
  String get reward_social => 'Social Dev';

  @override
  String get reward_social_desc => 'Social media developer';

  @override
  String get reward_bonus => 'Diamond Bonus';

  @override
  String get reward_bonus_desc => 'Exclusive reward';

  @override
  String get success_report => 'Premium Report';

  @override
  String get success_report_desc => 'Analysis of all products';

  @override
  String get success_badge => 'Exclusive Badge';

  @override
  String get success_badge_desc => 'Badge for elite members';

  @override
  String get success_vip => 'Event VIP Access';

  @override
  String get success_vip_desc => 'Priority access to events';

  @override
  String get success_boost => 'XP Boost x2';

  @override
  String get success_boost_desc => 'Double XP for 24h';

  @override
  String get tag_new => 'New';

  @override
  String reset_timer(Object hours) {
    return 'Resets in ${hours}h';
  }

  @override
  String get your_balance => 'Your balance';

  @override
  String get activate_btn => 'Activate';

  @override
  String get popular_tag => 'POPULAR';

  @override
  String get coins_label => 'COINS';

  @override
  String get upcoming => 'Upcoming';

  @override
  String this_week(int count) {
    return '+$count this week';
  }

  @override
  String get registrations => 'Registrations';

  @override
  String in_queue(int count) {
    return '$count in queue';
  }

  @override
  String get view_calendar => 'View Calendar';

  @override
  String get product_launch_tag => 'Product Launch';

  @override
  String get no_events_found => 'No events found';

  @override
  String get tab_tous => 'All';

  @override
  String get online => 'Online';

  @override
  String get free => 'Free';

  @override
  String get atelier => 'Workshop';

  @override
  String get conference => 'Conference';

  @override
  String get populaire_tag => 'Popular';

  @override
  String participants(String count) {
    return '$count participants';
  }

  @override
  String get active_members => 'Active Members';

  @override
  String get daily_posts => 'Daily Posts';

  @override
  String get community_growth => 'Growth';

  @override
  String get tab_for_you => 'For you';

  @override
  String post_time(int count) {
    return '${count}h ago';
  }

  @override
  String get no_posts_found => 'No posts found';

  @override
  String get members_online => 'Members online';

  @override
  String get trending_topics => 'Trending topics';

  @override
  String get search_find_winning => 'Find winning products';

  @override
  String get search_analyze_hint => 'Analyze market in real-time';

  @override
  String get search_input_hint => 'Search a keyword or product...';

  @override
  String get search_no_results => 'No results found';

  @override
  String get search_global_score => 'Global Score';

  @override
  String get filter_trending => 'Trending Categories';

  @override
  String get filter_margin => 'High Estimated Margin';

  @override
  String get filter_new => 'New Launches';

  @override
  String get filter_viral => 'High Virality Score';

  @override
  String get dashboard_title => 'My Dashboard';

  @override
  String get stat_analyzed => 'Files\nAnalyzed';

  @override
  String get stat_support => 'To Sav\nHours';

  @override
  String get stat_tasks => 'Active\nTasks';

  @override
  String get period_this_week => 'This week';

  @override
  String get period_this_month => 'This month';

  @override
  String get period_total => 'Total';

  @override
  String get score_evolution => 'Average Score Evolution';

  @override
  String get detailed_stats_title => 'Detailed Statistics';

  @override
  String get stat_detailed_analyzed => 'Product Files Analyzed';

  @override
  String get stat_detailed_economic => 'Economic Products';

  @override
  String get since_beginning => 'Since the beginning';

  @override
  String get total_time_label => 'Total time';

  @override
  String get streak_days_title => 'Active Streak Days';

  @override
  String streak_days_msg(int count) {
    return 'You are on fire! $count consecutive days of active watching.';
  }

  @override
  String get cancel_renewal => 'Cancel renewal';

  @override
  String get view_billing => 'View billing history and receipts';

  @override
  String get compare_plans => 'Compare all plans';

  @override
  String get enter_otp => 'Please enter the OTP code';

  @override
  String get otp_verified => 'Code verified successfully!';

  @override
  String get code_sent => 'A new code has been sent to your email';

  @override
  String get contact_btn => 'Contact';

  @override
  String get view_btn => 'View';

  @override
  String get save_btn => 'Save';

  @override
  String view_on_source(String source) {
    return 'View on $source';
  }

  @override
  String get code_copied => 'Code copied!';

  @override
  String get name_label => 'Name';

  @override
  String get points_label => 'Points';

  @override
  String sharing_code(String code) {
    return 'I share my code: $code';
  }

  @override
  String get selling_price => 'Selling price';

  @override
  String get estimated_profit => 'Estimated profit';

  @override
  String get pricing_disclaimer =>
      'These prices are estimates and may vary based on quantity ordered';

  @override
  String get performance_analysis => 'Performance Analysis';

  @override
  String get market_insights => 'Market Insights';

  @override
  String get trending_up_label => 'Trending up';

  @override
  String get strong_demand_label => 'Strong demand';

  @override
  String get large_margin_label => 'Large margin';

  @override
  String monthly_sales_est(String count) {
    return '${count}K+ estimated monthly sales';
  }

  @override
  String profit_margin_est(String percent) {
    return '$percent% profit margin';
  }

  @override
  String get supplier_label => 'Supplier';

  @override
  String reviews_count(String rating, String count) {
    return '$rating/5 • $count reviews';
  }

  @override
  String get supplier_price => 'Supplier price';

  @override
  String get email_verification => 'Email Verification';

  @override
  String get verify_your_email => 'Verify your email';

  @override
  String get otp_description => 'A 6-digit verification code has been sent to';

  @override
  String get did_not_receive_code => 'Didn\'t receive the code?';

  @override
  String get resend_btn => 'Resend';

  @override
  String get otp_expiry => 'The code expires after 10 minutes';

  @override
  String get go_to_search_btn => 'Go to search...';

  @override
  String get sign_up_btn => 'Sign Up';

  @override
  String get audio_tech_category => 'Audio & Tech';

  @override
  String get product_desc_fallback =>
      'High-quality Bluetooth audio headphones with active noise cancellation, 30h battery life and ergonomic design for optimal comfort.';

  @override
  String get product_view_details => 'View product details';

  @override
  String get product_title_fallback => 'Premium Wireless Headphones';

  @override
  String get score => 'Score';

  @override
  String get my_favorites => 'My Favorites';

  @override
  String saved_products_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products saved',
      one: '1 saved product',
      zero: 'No saved products',
    );
    return '$_temp0';
  }

  @override
  String get empty_watchlist_title => 'Your Watchlist is Empty';

  @override
  String get empty_watchlist_subtitle =>
      'Start by finding winning products to monitor them.';

  @override
  String get discover_trending_title => 'Discover Trending Products';

  @override
  String get discover_trending_subtitle =>
      'Find high-potential products to start your personalized monitoring.';

  @override
  String get start_search_btn => 'Start search';

  @override
  String get advice_title => 'Advice';

  @override
  String get advice_subtitle =>
      'Check your favorites regularly to follow the evolution of trends and scores';

  @override
  String get discover_more_products_btn => 'Discover more products';

  @override
  String get unknown_product => 'Unknown Product';

  @override
  String get recently_added => 'Recently';

  @override
  String get price_label => 'Price';

  @override
  String get profit_label => 'Profit';

  @override
  String get tracked_products => 'Tracked products';

  @override
  String get active_trends => 'Active trends';

  @override
  String get pro_plan => 'Pro Plan';

  @override
  String active_until(Object date) {
    return 'Active until $date';
  }

  @override
  String get theme_color => 'Theme color';

  @override
  String get choose_avatar => 'Choose an avatar';

  @override
  String get verify_account_btn => 'Verify account';

  @override
  String get referral_rewards => 'Referral Rewards';

  @override
  String get active_referrals => 'Active Referrals';

  @override
  String get points_earned => 'Points Earned';

  @override
  String get how_it_works => 'How it works?';

  @override
  String get referral_step_1 => 'Share your unique code';

  @override
  String get referral_step_2 => 'Your friends sign up';

  @override
  String get referral_step_3 => 'Earn bonus points';

  @override
  String get your_referral_code => 'Your referral code';

  @override
  String get my_referrals => 'My referrals';

  @override
  String get share_code_btn => 'Share my code';

  @override
  String get unlimited_alerts => 'Unlimited alerts';

  @override
  String get complete_analysis => 'Complete analysis';

  @override
  String get priority_support => 'Priority support';

  @override
  String get sales_volume_analysis => 'Sales volume analysis';

  @override
  String get data_export => 'Data export';

  @override
  String get benefits_included => 'Benefits included';

  @override
  String get manage_payment => 'Manage payment';

  @override
  String get upgrade_premium => 'Upgrade to Premium';

  @override
  String get my_subscription => 'My subscription';

  @override
  String get your_current_plan => 'Your current plan';

  @override
  String get premium_monthly => 'Premium Monthly';

  @override
  String get free_plan => 'Free Plan';

  @override
  String get freemium_limit => 'Freemium limit reached';

  @override
  String get demand_label => 'Demand';

  @override
  String get profitability_label => 'Profitability';

  @override
  String get competition_label => 'Competition';

  @override
  String get trend_label => 'Trend';

  @override
  String get preferences => 'Preferences';

  @override
  String get support_section => 'Support';

  @override
  String get notifications_label => 'Notifications';

  @override
  String get privacy_label => 'Privacy';

  @override
  String get help_center => 'Help Center';

  @override
  String get upgrade_to_pro => 'Upgrade to Pro';

  @override
  String get data_security => 'Data & Security';

  @override
  String get faq_tutorials => 'FAQ & Tutorials';

  @override
  String get unlock_all_features => 'Unlock all features';

  @override
  String get alerts_trends => 'Alerts & Trends';

  @override
  String get verification_title => 'Verification';

  @override
  String get verification_desc => 'Enter the code sent to';

  @override
  String get profile_label => 'Profile';

  @override
  String get verify_email_title => 'Check your mailbox';

  @override
  String get verification_sent_to => 'We have sent a verification\ncode to';

  @override
  String get verification_enter_code =>
      '. Please\nenter it below to activate your account.';

  @override
  String resend_code_timer(Object seconds) {
    return 'Resend code ${seconds}s';
  }

  @override
  String get terms_privacy_notice =>
      'By continuing, you agree to our terms of use and our\nprivacy policy';

  @override
  String get login_title => 'Login';

  @override
  String get login_welcome => 'Welcome back! Login to continue';

  @override
  String get email_label => 'Email';

  @override
  String get email_hint => 'you@example.com';

  @override
  String get password_label => 'Password';

  @override
  String get password_hint => '********';

  @override
  String get forgot_password_btn => 'Forgot password?';

  @override
  String get signin_btn => 'Sign In';

  @override
  String get dont_have_account => 'Don\'t have an account yet?';

  @override
  String get create_account_btn => 'Create an account';

  @override
  String get register_title => 'Sign Up';

  @override
  String get register_welcome => 'Welcome! Create an account to get started';

  @override
  String get already_have_account => 'Already have an account?';

  @override
  String get signup_btn => 'Sign Up';

  @override
  String get full_name_label => 'Full Name';

  @override
  String get full_name_hint => 'First Last';

  @override
  String get continue_with => 'Or continue with';

  @override
  String get login_as_guest => 'Log in as guest';

  @override
  String get confirm_password_label => 'Confirm password';

  @override
  String get user_label => 'User';

  @override
  String get forgot_password_desc =>
      'Enter the email address associated with your account and we will send you a link to reset your password.';

  @override
  String get send_link_btn => 'Send link';

  @override
  String get reset_link_sent => 'Reset link sent!';

  @override
  String get verify_btn => 'Verify';

  @override
  String get referral_status_joined => 'Joined';

  @override
  String get referral_status_pending => 'Pending';

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
    return 'Sign up with my code $code and get bonus points!';
  }

  @override
  String get guest => 'Guest';
}
