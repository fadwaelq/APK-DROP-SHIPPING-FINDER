// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get nav_home => 'الرئيسية';

  @override
  String get nav_search => 'بحث';

  @override
  String get nav_fav => 'المفضلة';

  @override
  String get nav_profile => 'الملف الشخصي';

  @override
  String get greeting => 'مرحباً،';

  @override
  String get profit_score => 'درجة الربحية';

  @override
  String get avg_profit => 'متوسط الربح';

  @override
  String get products => 'منتجات';

  @override
  String get top_niches => 'أفضل المجالات';

  @override
  String get trending_products => 'منتجات شائعة';

  @override
  String get see_all => 'عرض الكل';

  @override
  String get lang_title => 'اللغة';

  @override
  String get settings_title => 'الإعدادات والتفضيلات';

  @override
  String get confirm_lang_title => 'تغيير اللغة؟';

  @override
  String confirm_lang_body(String lang) {
    return 'هل تريد تغيير لغة التطبيق بالكامل إلى $lang؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String lang_changed(String lang) {
    return 'لغة التطبيق الآن هي: $lang';
  }

  @override
  String get events => 'فعاليات';

  @override
  String get community => 'مجتمع';

  @override
  String get rewards => 'مكافآت';

  @override
  String get pref_title => 'التفضيلات';

  @override
  String get support_title => 'الدعم';

  @override
  String get activity_title => 'أنشطتي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get pref_general => 'التفضيلات العامة';

  @override
  String get lang_item => 'اللغة';

  @override
  String get currency_item => 'عملة العرض';

  @override
  String get currency_usd => 'دولار أمريكي';

  @override
  String get currency_eur => 'يورو';

  @override
  String get currency_mad => 'درهم مغربي';

  @override
  String get currency_gbp => 'جنيه إسترليني';

  @override
  String get currency_sar => 'ريال سعودي';

  @override
  String get change_pwd_item => 'تغيير كلمة المرور';

  @override
  String get faceid_item => 'تفعيل بصمة الوجه | اليد';

  @override
  String get legal_support => 'المعلومات القانونية والدعم';

  @override
  String get privacy_policy => 'سياسة الخصوصية';

  @override
  String get app_version => 'اصدار التطبيق';

  @override
  String get contact_support => 'الاتصال بالدعم والمساعدة';

  @override
  String get coin_balance => 'رصيد الكوينز';

  @override
  String get active_streak => 'سلسلة النشاط';

  @override
  String days_streak(int count) {
    return '$count أيام';
  }

  @override
  String get bonus_text => 'مكافأة يومية';

  @override
  String coins_per_day(int count) {
    return '+$count كوينز/يوم';
  }

  @override
  String get history_btn => 'السجل';

  @override
  String get shop_btn => 'المتجر';

  @override
  String level_text(int level) {
    return 'المستوى $level';
  }

  @override
  String get elite_trader => 'تاجر النخبة';

  @override
  String xp_for_level(int nextLevel) {
    return 'XP للمستوى $nextLevel';
  }

  @override
  String get daily_missions => 'المهام اليومية';

  @override
  String get weekly_missions => 'المهام الأسبوعية';

  @override
  String mission_analyze(int count) {
    return 'تحليل $count منتجات اليوم';
  }

  @override
  String get mission_share => 'مشاركة اتجاه';

  @override
  String get mission_report => 'عرض التقرير الأسبوعي';

  @override
  String get mission_fav => 'إضافة 5 منتجات للمفضلة';

  @override
  String get mission_event => 'المشاركة في فعالية';

  @override
  String get missions_tab => 'المهام';

  @override
  String get success_tab => 'النجاحات';

  @override
  String get boutique_tab => 'المتجر';

  @override
  String get claim_btn => 'مطالبة';

  @override
  String get tab_populaires => 'شائع';

  @override
  String get tab_suivis => 'متابع';

  @override
  String get tab_webinaires => 'ندوات';

  @override
  String get tab_lancements => 'إطلاقات';

  @override
  String get no_events => 'لا توجد فعاليات';

  @override
  String get no_posts => 'لا توجد منشورات';

  @override
  String get no_badges_found => 'Aucun badge trouvé';

  @override
  String get reward_pro => 'تحليل احترافي';

  @override
  String get reward_pro_desc => 'تحليل منتجات مفصل';

  @override
  String get reward_trend => 'اتجاهات متقدمة';

  @override
  String get reward_trend_desc => 'الوصول إلى اتجاهات متقدمة';

  @override
  String get reward_social => 'مطور اجتماعي';

  @override
  String get reward_social_desc => 'مطور وسائل التواصل الاجتماعي';

  @override
  String get reward_bonus => 'مكافأة ماسية';

  @override
  String get reward_bonus_desc => 'مكافأة حصرية';

  @override
  String get success_report => 'تقرير مميز';

  @override
  String get success_report_desc => 'تحليل جميع المنتجات';

  @override
  String get success_badge => 'شارة حصرية';

  @override
  String get success_badge_desc => 'شارة للأعضاء النخبة';

  @override
  String get success_vip => 'دخول VIP للفعاليات';

  @override
  String get success_vip_desc => 'دخول ذو أولوية للفعاليات';

  @override
  String get success_boost => 'تعزيز XP x2';

  @override
  String get success_boost_desc => 'ضاعف XP لمدة 24 ساعة';

  @override
  String get tag_new => 'جديد';

  @override
  String reset_timer(Object hours) {
    return 'يتم التحديث خلال $hours ساعات';
  }

  @override
  String get your_balance => 'رصيدك';

  @override
  String get activate_btn => 'تفعيل';

  @override
  String get popular_tag => 'شائع';

  @override
  String get coins_label => 'كوينز';

  @override
  String get upcoming => 'قادم';

  @override
  String this_week(int count) {
    return '+$count هذا الأسبوع';
  }

  @override
  String get registrations => 'التسجيلات';

  @override
  String in_queue(int count) {
    return '$count في قائمة الانتظار';
  }

  @override
  String get view_calendar => 'عرض التقويم';

  @override
  String get product_launch_tag => 'إطلاق منتج';

  @override
  String get no_events_found => 'لم يتم العثور على فعاليات';

  @override
  String get tab_tous => 'الكل';

  @override
  String get online => 'عبر الإنترنت';

  @override
  String get free => 'مجاني';

  @override
  String get atelier => 'ورشة عمل';

  @override
  String get conference => 'مؤتمر';

  @override
  String get populaire_tag => 'شائع';

  @override
  String participants(String count) {
    return '$count مشاركين';
  }

  @override
  String get active_members => 'الأعضاء النشطين';

  @override
  String get daily_posts => 'المنشورات اليومية';

  @override
  String get community_growth => 'النمو';

  @override
  String get tab_for_you => 'لك';

  @override
  String post_time(int count) {
    return 'منذ $count ساعات';
  }

  @override
  String get no_posts_found => 'لم يتم العثور على منشورات';

  @override
  String get members_online => 'الأعضاء المتصلون';

  @override
  String get trending_topics => 'المواضيع الشائعة';

  @override
  String get search_find_winning => 'البحث عن المنتجات الرابحة';

  @override
  String get search_analyze_hint => 'تحليل السوق في الوقت الحقيقي';

  @override
  String get search_input_hint => 'ابحث عن كلمة رئيسية أو منتج...';

  @override
  String get search_no_results => 'لم يتم العثور على نتائج';

  @override
  String get search_global_score => 'النتيجة الإجمالية';

  @override
  String get filter_trending => 'فئات شائعة';

  @override
  String get filter_margin => 'هامش مرتفع مقدر';

  @override
  String get filter_new => 'إطلاقات جديدة';

  @override
  String get filter_viral => 'درجة انتشار عالية';

  @override
  String get dashboard_title => 'لوحة القيادة الخاصة بي';

  @override
  String get stat_analyzed => 'الملفات\nالمحللة';

  @override
  String get stat_support => 'ساعات\nالدعم';

  @override
  String get stat_tasks => 'المهام\nالنشطة';

  @override
  String get period_this_week => 'هذا الأسبوع';

  @override
  String get period_this_month => 'هذا الشهر';

  @override
  String get period_total => 'الإجمالي';

  @override
  String get score_evolution => 'تطور متوسط النتيجة';

  @override
  String get detailed_stats_title => 'إحصائيات مفصلة';

  @override
  String get stat_detailed_analyzed => 'ملفات المنتج المحللة';

  @override
  String get stat_detailed_economic => 'منتجات اقتصادية';

  @override
  String get since_beginning => 'منذ البداية';

  @override
  String get total_time_label => 'الوقت الإجمالي';

  @override
  String get streak_days_title => 'أيام المشاهدة النشطة';

  @override
  String streak_days_msg(int count) {
    return 'أنت في القمة! $count أيام متتالية من المشاهدة النشطة.';
  }

  @override
  String get cancel_renewal => 'إلغاء التجديد';

  @override
  String get view_billing => 'عرض سجل الفواتير والإيصالات';

  @override
  String get compare_plans => 'مقارنة جميع الخطط';

  @override
  String get enter_otp => 'يرجى إدخال رمز التحقق';

  @override
  String get otp_verified => 'تم التحقق من الرمز بنجاح!';

  @override
  String get code_sent => 'تم إرسال رمز جديد إلى بريدك الإلكتروني';

  @override
  String get contact_btn => 'اتصال';

  @override
  String get view_btn => 'عرض';

  @override
  String get save_btn => 'حفظ';

  @override
  String view_on_source(String source) {
    return 'عرض على $source';
  }

  @override
  String get code_copied => 'تم نسخ الرمز!';

  @override
  String get name_label => 'الاسم';

  @override
  String get points_label => 'النقاط';

  @override
  String sharing_code(String code) {
    return 'أشارك كودي: $code';
  }

  @override
  String get selling_price => 'سعر البيع';

  @override
  String get estimated_profit => 'الربح المقدر';

  @override
  String get pricing_disclaimer =>
      'هذه الأسعار تقديرية وقد تختلف بناءً على الكمية المطلوبة';

  @override
  String get performance_analysis => 'تحليل الأداء';

  @override
  String get market_insights => 'رؤى السوق';

  @override
  String get trending_up_label => 'تصاعدي';

  @override
  String get strong_demand_label => 'طلب قوي';

  @override
  String get large_margin_label => 'هامش كبير';

  @override
  String monthly_sales_est(String count) {
    return '${count}K+ مبيعات شهرية مقدرة';
  }

  @override
  String profit_margin_est(String percent) {
    return '$percent% هامش الربح';
  }

  @override
  String get supplier_label => 'المورد';

  @override
  String reviews_count(String rating, String count) {
    return '$rating/5 • $count مراجعة';
  }

  @override
  String get supplier_price => 'سعر المورد';

  @override
  String get email_verification => 'التحقق من البريد الإلكتروني';

  @override
  String get verify_your_email => 'تحقق من بريدك الإلكتروني';

  @override
  String get otp_description => 'تم إرسال رمز تحقق مكون من 6 أرقام إلى';

  @override
  String get did_not_receive_code => 'لم تستلم الرمز؟';

  @override
  String get resend_btn => 'إعادة الإرسال';

  @override
  String get otp_expiry => 'تنتهي صلاحية الرمز بعد 10 دقائق';

  @override
  String get go_to_search_btn => 'الذهاب إلى البحث...';

  @override
  String get sign_up_btn => 'تسجيل';

  @override
  String get audio_tech_category => 'صوتيات وتكنولوجيا';

  @override
  String get product_desc_fallback =>
      'سماعات بلوتوث عالية الجودة مع خاصية إلغاء الضجيج النشطة، وبطارية تدوم 30 ساعة وتصميم مريح لأفضل راحة.';

  @override
  String get product_view_details => 'عرض تفاصيل المنتج';

  @override
  String get product_title_fallback => 'سماعات رأس لاسلكية فاخرة';

  @override
  String get score => 'النتيجة';

  @override
  String get my_favorites => 'مفضلاتي';

  @override
  String saved_products_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتجات محفوظة',
      one: 'منتج واحد محفوظ',
      zero: 'لا توجد منتجات محفوظة',
    );
    return '$_temp0';
  }

  @override
  String get empty_watchlist_title => 'قائمة المراقبة فارغة';

  @override
  String get empty_watchlist_subtitle =>
      'ابدأ بالعثور على المنتجات الرابحة لمراقبتها.';

  @override
  String get discover_trending_title => 'اكتشف المنتجات الرائجة';

  @override
  String get discover_trending_subtitle =>
      'اعثر على منتجات ذات إمكانات عالية لبدء مراقبتك الشخصية.';

  @override
  String get start_search_btn => 'بدء البحث';

  @override
  String get advice_title => 'نصيحة';

  @override
  String get advice_subtitle =>
      'تحقق من مفضلاتك بانتظام لمتابعة تطور الاتجاهات والنتائج';

  @override
  String get discover_more_products_btn => 'اكتشف المزيد من المنتجات';

  @override
  String get unknown_product => 'منتج غير معروف';

  @override
  String get recently_added => 'مؤخراً';

  @override
  String get price_label => 'السعر';

  @override
  String get profit_label => 'الربح';

  @override
  String get tracked_products => 'منتجات متتابعة';

  @override
  String get active_trends => 'اتجاهات نشطة';

  @override
  String get pro_plan => 'خطة برو';

  @override
  String active_until(Object date) {
    return 'نشط حتى $date';
  }

  @override
  String get theme_color => 'لون المظهر';

  @override
  String get choose_avatar => 'اختر صورة شخصية';

  @override
  String get verify_account_btn => 'تأكيد الحساب';

  @override
  String get referral_rewards => 'مكافآت الإحالة';

  @override
  String get active_referrals => 'إحالات نشطة';

  @override
  String get points_earned => 'النقاط المكتسبة';

  @override
  String get how_it_works => 'كيف يعمل؟';

  @override
  String get referral_step_1 => 'شارك كودك الفريد';

  @override
  String get referral_step_2 => 'يسجل أصدقاؤك';

  @override
  String get referral_step_3 => 'اكسب نقاط مكافأة';

  @override
  String get your_referral_code => 'كود الإحالة الخاص بك';

  @override
  String get my_referrals => 'إحالاتي';

  @override
  String get share_code_btn => 'مشاركة الكود الخاص بي';

  @override
  String get unlimited_alerts => 'تنبيهات غير محدودة';

  @override
  String get complete_analysis => 'تحليلات كاملة';

  @override
  String get priority_support => 'دعم ذو أولوية';

  @override
  String get sales_volume_analysis => 'تحليل حجم المبيعات';

  @override
  String get data_export => 'تصدير البيانات';

  @override
  String get benefits_included => 'المزايا المتضمنة';

  @override
  String get manage_payment => 'إدارة الدفع';

  @override
  String get upgrade_premium => 'الترقية إلى بريميوم';

  @override
  String get my_subscription => 'اشتراكي';

  @override
  String get your_current_plan => 'خطة عملك الحالية';

  @override
  String get premium_monthly => 'بريميوم شهري';

  @override
  String get free_plan => 'الخطة المجانية';

  @override
  String get freemium_limit => 'الوصول للحد المجاني';

  @override
  String get demand_label => 'الطلب';

  @override
  String get profitability_label => 'الربحية';

  @override
  String get competition_label => 'المنافسة';

  @override
  String get trend_label => 'الاتجاه';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get support_section => 'الدعم';

  @override
  String get notifications_label => 'تنبيهات';

  @override
  String get privacy_label => 'الخصوصية';

  @override
  String get help_center => 'مركز المساعدة';

  @override
  String get upgrade_to_pro => 'الترقية إلى برو';

  @override
  String get data_security => 'البيانات والأمان';

  @override
  String get faq_tutorials => 'الأسئلة الشائعة والبرامج التعليمية';

  @override
  String get unlock_all_features => 'فتح جميع المزايا';

  @override
  String get alerts_trends => 'تنبيهات واتجاهات';

  @override
  String get verification_title => 'تأكيد';

  @override
  String get verification_desc => 'أدخل الكود المرسل إلى';

  @override
  String get profile_label => 'الملف الشخصي';

  @override
  String get verify_email_title => 'تحقق من بريدك الإلكتروني';

  @override
  String get verification_sent_to => 'لقد أرسلنا كود\nتأكيد إلى';

  @override
  String get verification_enter_code => '. يرجى\nإدخاله أدناه لتفعيل حسابك.';

  @override
  String resend_code_timer(Object seconds) {
    return 'إعادة إرسال الكود $seconds ثانية';
  }

  @override
  String get terms_privacy_notice =>
      'من خلال الاستمرار، فإنك توافق على شروط الاستخدام و\nسياسة الخصوصية الخاصة بنا';

  @override
  String get login_title => 'تسجيل الدخول';

  @override
  String get login_welcome => 'مرحباً بعودتك! سجل دخولك للمتابعة';

  @override
  String get email_label => 'البريد الإلكتروني';

  @override
  String get email_hint => 'you@example.com';

  @override
  String get password_label => 'كلمة المرور';

  @override
  String get password_hint => '********';

  @override
  String get forgot_password_btn => 'نسيت كلمة المرور؟';

  @override
  String get signin_btn => 'تسجيل الدخول';

  @override
  String get dont_have_account => 'ليس لديك حساب بعد؟';

  @override
  String get create_account_btn => 'إنشاء حساب';

  @override
  String get register_title => 'إنشاء حساب';

  @override
  String get register_welcome => 'مرحباً! أنشئ حساباً للبدء';

  @override
  String get already_have_account => 'لديك حساب بالفعل؟';

  @override
  String get signup_btn => 'إنشاء حساب';

  @override
  String get full_name_label => 'الاسم الكامل';

  @override
  String get full_name_hint => 'الاسم الأول والأخير';

  @override
  String get continue_with => 'أو تابع المهمة باستخدام';

  @override
  String get login_as_guest => 'الدخول كضيف';

  @override
  String get confirm_password_label => 'تأكيد كلمة المرور';

  @override
  String get user_label => 'مستخدم';

  @override
  String get forgot_password_desc =>
      'أدخل عنوان البريد الإلكتروني المرتبط بحسابك وسنرسل لك رابطاً لإعادة تعيين كلمة المرور الخاصة بك.';

  @override
  String get send_link_btn => 'إرسال الرابط';

  @override
  String get reset_link_sent => 'تم إرسال رابط إعادة التعيين!';

  @override
  String get verify_btn => 'تحقق';

  @override
  String get referral_status_joined => 'انضم';

  @override
  String get referral_status_pending => 'قيد الانتظار';

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
    return 'سجل باستخدام الكود الخاص بي $code واحصل على نقاط إضافية!';
  }

  @override
  String get guest => 'ضيف';
}
