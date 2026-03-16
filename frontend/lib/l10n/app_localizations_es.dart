// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get nav_home => 'Inicio';

  @override
  String get nav_search => 'Buscar';

  @override
  String get nav_fav => 'Favoritos';

  @override
  String get nav_profile => 'Perfil';

  @override
  String get greeting => 'Hola,';

  @override
  String get profit_score => 'Puntuación de Rentabilidad';

  @override
  String get avg_profit => 'Beneficio med.';

  @override
  String get products => 'Productos';

  @override
  String get top_niches => 'Mejores nichos';

  @override
  String get trending_products => 'Productos de Tendencia';

  @override
  String get see_all => 'Ver todo';

  @override
  String get lang_title => 'Idioma';

  @override
  String get settings_title => 'Ajustes y Preferencias';

  @override
  String get confirm_lang_title => '¿Cambiar idioma?';

  @override
  String confirm_lang_body(String lang) {
    return '¿Quieres cambiar el idioma de la aplicación a $lang?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String lang_changed(String lang) {
    return 'El idioma de la aplicación es ahora: $lang';
  }

  @override
  String get events => 'Eventos';

  @override
  String get community => 'Comunidad';

  @override
  String get rewards => 'Recompensas';

  @override
  String get pref_title => 'Preferencias';

  @override
  String get support_title => 'Soporte';

  @override
  String get activity_title => 'Mis Actividades';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get pref_general => 'Preferencia General';

  @override
  String get lang_item => 'Idioma';

  @override
  String get currency_item => 'Moneda de visualización';

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
  String get change_pwd_item => 'Cambiar la contraseña';

  @override
  String get faceid_item => 'Activar Face ID | Touch ID';

  @override
  String get legal_support => 'Información Legal y Soporte';

  @override
  String get privacy_policy => 'Política de privacidad';

  @override
  String get app_version => 'Versión de la aplicación';

  @override
  String get contact_support => 'Contacto Soporte y Asistencia';

  @override
  String get coin_balance => 'Saldo de Monedas';

  @override
  String get active_streak => 'Racha activa';

  @override
  String days_streak(int count) {
    return '$count días';
  }

  @override
  String get bonus_text => 'Bono diario';

  @override
  String coins_per_day(int count) {
    return '+$count monedas/día';
  }

  @override
  String get history_btn => 'Historial';

  @override
  String get shop_btn => 'Tienda';

  @override
  String level_text(int level) {
    return 'Nivel $level';
  }

  @override
  String get elite_trader => 'Comerciante de Élite';

  @override
  String xp_for_level(int nextLevel) {
    return 'XP para nivel $nextLevel';
  }

  @override
  String get daily_missions => 'Misiones Diarias';

  @override
  String get weekly_missions => 'Misiones Semanales';

  @override
  String mission_analyze(int count) {
    return 'Analizar $count productos hoy';
  }

  @override
  String get mission_share => 'Compartir una tendencia';

  @override
  String get mission_report => 'Ver informe semanal';

  @override
  String get mission_fav => 'Añadir 5 productos a favoritos';

  @override
  String get mission_event => 'Participar en un evento';

  @override
  String get missions_tab => 'Misiones';

  @override
  String get success_tab => 'Éxitos';

  @override
  String get boutique_tab => 'Tienda';

  @override
  String get claim_btn => 'Reclamar';

  @override
  String get tab_populaires => 'Popular';

  @override
  String get tab_suivis => 'Siguiendo';

  @override
  String get tab_webinaires => 'Webinars';

  @override
  String get tab_lancements => 'Lanzamientos';

  @override
  String get no_events => 'No se encontraron eventos';

  @override
  String get no_posts => 'No se encontraron publicaciones';

  @override
  String get no_badges_found => 'Aucun badge trouvé';

  @override
  String get reward_pro => 'Análisis Pro';

  @override
  String get reward_pro_desc => 'Análisis detallado de productos';

  @override
  String get reward_trend => 'Tendencias Avanzadas';

  @override
  String get reward_trend_desc => 'Acceso a tendencias avanzadas';

  @override
  String get reward_social => 'Social Dev';

  @override
  String get reward_social_desc => 'Desarrollador de redes sociales';

  @override
  String get reward_bonus => 'Bono Diamante';

  @override
  String get reward_bonus_desc => 'Recompensa exclusiva';

  @override
  String get success_report => 'Informe Premium';

  @override
  String get success_report_desc => 'Análisis de todos los productos';

  @override
  String get success_badge => 'Insignia Exclusiva';

  @override
  String get success_badge_desc => 'Insignia para miembros de élite';

  @override
  String get success_vip => 'Acceso VIP a Eventos';

  @override
  String get success_vip_desc => 'Acceso prioritario a eventos';

  @override
  String get success_boost => 'XP Boost x2';

  @override
  String get success_boost_desc => 'Doble XP durante 24h';

  @override
  String get tag_new => 'Nuevo';

  @override
  String reset_timer(Object hours) {
    return 'Se reinicia en ${hours}h';
  }

  @override
  String get your_balance => 'Tu saldo';

  @override
  String get activate_btn => 'Activar';

  @override
  String get popular_tag => 'POPULAR';

  @override
  String get coins_label => 'MONEDAS';

  @override
  String get upcoming => 'Próximos';

  @override
  String this_week(int count) {
    return '+$count esta semana';
  }

  @override
  String get registrations => 'Inscripciones';

  @override
  String in_queue(int count) {
    return '$count en cola';
  }

  @override
  String get view_calendar => 'Ver calendario';

  @override
  String get product_launch_tag => 'Lanzamiento';

  @override
  String get no_events_found => 'No se encontraron eventos';

  @override
  String get tab_tous => 'Todos';

  @override
  String get online => 'En línea';

  @override
  String get free => 'Gratis';

  @override
  String get atelier => 'Taller';

  @override
  String get conference => 'Conferencia';

  @override
  String get populaire_tag => 'Popular';

  @override
  String participants(String count) {
    return '$count participantes';
  }

  @override
  String get active_members => 'Miembros activos';

  @override
  String get daily_posts => 'Publicaciones diarias';

  @override
  String get community_growth => 'Crecimiento';

  @override
  String get tab_for_you => 'Para ti';

  @override
  String post_time(int count) {
    return 'hace ${count}h';
  }

  @override
  String get no_posts_found => 'No se encontraron publicaciones';

  @override
  String get members_online => 'Miembros en línea';

  @override
  String get trending_topics => 'Temas de tendencia';

  @override
  String get search_find_winning => 'Encontrar productos ganadores';

  @override
  String get search_analyze_hint => 'Analizar el mercado en tiempo real';

  @override
  String get search_input_hint => 'Buscar una palabra clave o producto...';

  @override
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get search_global_score => 'Puntuación Global';

  @override
  String get filter_trending => 'Categorías de Tendencia';

  @override
  String get filter_margin => 'Alto Margen Estimado';

  @override
  String get filter_new => 'Nuevos Lanzamientos';

  @override
  String get filter_viral => 'Puntuación de Viralidad Alta';

  @override
  String get dashboard_title => 'Mi Panel de Control';

  @override
  String get stat_analyzed => 'Archivos\nAnalizados';

  @override
  String get stat_support => 'Horas de\nSoporte';

  @override
  String get stat_tasks => 'Tareas\nActivas';

  @override
  String get period_this_week => 'Esta semana';

  @override
  String get period_this_month => 'Este mes';

  @override
  String get period_total => 'Total';

  @override
  String get score_evolution => 'Evolución de la Puntuación Media';

  @override
  String get detailed_stats_title => 'Estadísticas detalladas';

  @override
  String get stat_detailed_analyzed => 'Archivos de Productos Analizados';

  @override
  String get stat_detailed_economic => 'Productos Económicos';

  @override
  String get since_beginning => 'Desde el principio';

  @override
  String get total_time_label => 'Tiempo total';

  @override
  String get streak_days_title => 'Días de racha activa';

  @override
  String streak_days_msg(int count) {
    return '¡Estás en racha! $count días consecutivos de observación activa.';
  }

  @override
  String get cancel_renewal => 'Cancelar renovación';

  @override
  String get view_billing => 'Ver historial de facturación y recibos';

  @override
  String get compare_plans => 'Comparar todos los planes';

  @override
  String get enter_otp => 'Por favor, introduzca el código OTP';

  @override
  String get otp_verified => '¡Código verificado con éxito!';

  @override
  String get code_sent =>
      'Se ha enviado un nuevo código a su correo electrónico';

  @override
  String get contact_btn => 'Contactar';

  @override
  String get view_btn => 'Ver';

  @override
  String get save_btn => 'Guardar';

  @override
  String view_on_source(String source) {
    return 'Ver en $source';
  }

  @override
  String get code_copied => '¡Código copiado!';

  @override
  String get name_label => 'Nombre';

  @override
  String get points_label => 'Puntos';

  @override
  String sharing_code(String code) {
    return 'Comparto mi código: $code';
  }

  @override
  String get selling_price => 'Precio de venta';

  @override
  String get estimated_profit => 'Beneficio estimado';

  @override
  String get pricing_disclaimer =>
      'Estos precios son estimaciones y pueden variar según la cantidad pedida';

  @override
  String get performance_analysis => 'Análisis de Rendimiento';

  @override
  String get market_insights => 'Información del Mercado';

  @override
  String get trending_up_label => 'Tendencia al alza';

  @override
  String get strong_demand_label => 'Forte demanda';

  @override
  String get large_margin_label => 'Gran margen';

  @override
  String monthly_sales_est(String count) {
    return '${count}K+ ventas mensuales estimadas';
  }

  @override
  String profit_margin_est(String percent) {
    return '$percent% de margen de beneficio';
  }

  @override
  String get supplier_label => 'Proveedor';

  @override
  String reviews_count(String rating, String count) {
    return '$rating/5 • $count reseñas';
  }

  @override
  String get supplier_price => 'Precio del proveedor';

  @override
  String get email_verification => 'Verificación de Correo';

  @override
  String get verify_your_email => 'Verifique su correo electrónico';

  @override
  String get otp_description =>
      'Se ha enviado un código de verificación de 6 dígitos a';

  @override
  String get did_not_receive_code => '¿No recibió el código?';

  @override
  String get resend_btn => 'Reenviar';

  @override
  String get otp_expiry => 'El código caduca después de 10 minutos';

  @override
  String get go_to_search_btn => 'Ir a buscar...';

  @override
  String get sign_up_btn => 'Inscribirse';

  @override
  String get audio_tech_category => 'Audio y Tecnología';

  @override
  String get product_desc_fallback =>
      'Auriculares de audio Bluetooth de alta calidad con cancelación activa de ruido, 30 horas de duración de la batería y diseño ergonómico para una comodidad óptima.';

  @override
  String get product_view_details => 'Ver detalles del producto';

  @override
  String get product_title_fallback => 'Auriculares Inalámbricos Premium';

  @override
  String get score => 'Puntuación';

  @override
  String get my_favorites => 'Mis Favoritos';

  @override
  String saved_products_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos guardados',
      one: '1 producto guardado',
      zero: 'Sin productos guardados',
    );
    return '$_temp0';
  }

  @override
  String get empty_watchlist_title => 'Su lista de seguimiento está vacía';

  @override
  String get empty_watchlist_subtitle =>
      'Comience por encontrar productos ganadores para monitorearlos.';

  @override
  String get discover_trending_title => 'Descubra productos de tendencia';

  @override
  String get discover_trending_subtitle =>
      'Encuentre productos de alto potencial para comenzar su monitoreo personalizado.';

  @override
  String get start_search_btn => 'Iniciar búsqueda';

  @override
  String get advice_title => 'Consejo';

  @override
  String get advice_subtitle =>
      'Consulte sus favoritos regularmente para seguir la evolución de las tendencias y las puntuaciones';

  @override
  String get discover_more_products_btn => 'Descubrir más productos';

  @override
  String get unknown_product => 'Producto desconocido';

  @override
  String get recently_added => 'Recientemente';

  @override
  String get price_label => 'Precio';

  @override
  String get profit_label => 'Ganancia';

  @override
  String get tracked_products => 'Productos seguidos';

  @override
  String get active_trends => 'Tendencias activas';

  @override
  String get pro_plan => 'Plan Pro';

  @override
  String active_until(Object date) {
    return 'Activo hasta $date';
  }

  @override
  String get theme_color => 'Color de tema';

  @override
  String get choose_avatar => 'Elegir un avatar';

  @override
  String get verify_account_btn => 'Verificar cuenta';

  @override
  String get referral_rewards => 'Recompensas de recomendación';

  @override
  String get active_referrals => 'Referidos activos';

  @override
  String get points_earned => 'Puntos ganados';

  @override
  String get how_it_works => '¿Cómo funciona?';

  @override
  String get referral_step_1 => 'Comparte tu código único';

  @override
  String get referral_step_2 => 'Tus amigos se registran';

  @override
  String get referral_step_3 => 'Gana puntos de bonificación';

  @override
  String get your_referral_code => 'Tu código de referido';

  @override
  String get my_referrals => 'Mis referidos';

  @override
  String get share_code_btn => 'Compartir mi código';

  @override
  String get unlimited_alerts => 'Alertas ilimitadas';

  @override
  String get complete_analysis => 'Análisis completos';

  @override
  String get priority_support => 'Soporte prioritario';

  @override
  String get sales_volume_analysis => 'Análisis de volumen de ventas';

  @override
  String get data_export => 'Exportación de datos';

  @override
  String get benefits_included => 'Beneficios incluidos';

  @override
  String get manage_payment => 'Gestionar pago';

  @override
  String get upgrade_premium => 'Pasar a Premium';

  @override
  String get my_subscription => 'Mi suscripción';

  @override
  String get your_current_plan => 'Tu plan actual';

  @override
  String get premium_monthly => 'Premium Mensuel';

  @override
  String get free_plan => 'Plan gratuito';

  @override
  String get freemium_limit => 'Límite gratuito alcanzado';

  @override
  String get demand_label => 'Demanda';

  @override
  String get profitability_label => 'Rentabilidad';

  @override
  String get competition_label => 'Competencia';

  @override
  String get trend_label => 'Tendencia';

  @override
  String get preferences => 'Preferencias';

  @override
  String get support_section => 'Soporte';

  @override
  String get notifications_label => 'Notificaciones';

  @override
  String get privacy_label => 'Privacidad';

  @override
  String get help_center => 'Centro de ayuda';

  @override
  String get upgrade_to_pro => 'Pasar a Pro';

  @override
  String get data_security => 'Datos y seguridad';

  @override
  String get faq_tutorials => 'FAQ y tutoriales';

  @override
  String get unlock_all_features => 'Desbloquear todas las funciones';

  @override
  String get alerts_trends => 'Alertas y tendencias';

  @override
  String get verification_title => 'Verificación';

  @override
  String get verification_desc => 'Ingrese el código enviado a';

  @override
  String get profile_label => 'Perfil';

  @override
  String get verify_email_title => 'Consulte su buzón de correo';

  @override
  String get verification_sent_to =>
      'Hemos enviado un código de\nverificación a';

  @override
  String get verification_enter_code =>
      '. Por favor,\ningréselo a continuación para activar su cuenta.';

  @override
  String resend_code_timer(Object seconds) {
    return 'Reenviar código ${seconds}s';
  }

  @override
  String get terms_privacy_notice =>
      'Al continuar, acepta nuestros términos de uso y nuestra\npolítica de privacidad';

  @override
  String get login_title => 'Iniciar sesión';

  @override
  String get login_welcome =>
      '¡Bienvenido de nuevo! Inicie sesión para continuar';

  @override
  String get email_label => 'Correo electrónico';

  @override
  String get email_hint => 'usted@ejemplo.com';

  @override
  String get password_label => 'Contraseña';

  @override
  String get password_hint => '********';

  @override
  String get forgot_password_btn => '¿Olvidó su contraseña?';

  @override
  String get signin_btn => 'Iniciar sesión';

  @override
  String get dont_have_account => '¿Aún no tiene una cuenta?';

  @override
  String get create_account_btn => 'Crear una cuenta';

  @override
  String get register_title => 'Registrarse';

  @override
  String get register_welcome => '¡Bienvenido! Crea una cuenta para empezar';

  @override
  String get already_have_account => '¿Ya tienes una cuenta?';

  @override
  String get signup_btn => 'Registrarse';

  @override
  String get full_name_label => 'Nombre completo';

  @override
  String get full_name_hint => 'Nombre Apellido';

  @override
  String get continue_with => 'O continúa con';

  @override
  String get login_as_guest => 'Entrar como invitado';

  @override
  String get confirm_password_label => 'Confirmar contraseña';

  @override
  String get user_label => 'Usuario';

  @override
  String get forgot_password_desc =>
      'Ingrese la dirección de correo electrónico asociada a su cuenta y le enviaremos un enlace para restablecer su contraseña.';

  @override
  String get send_link_btn => 'Enviar enlace';

  @override
  String get reset_link_sent => '¡Enlace de restablecimiento enviado!';

  @override
  String get verify_btn => 'Verificar';

  @override
  String get referral_status_joined => 'Unido';

  @override
  String get referral_status_pending => 'Pendiente';

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
    return '¡Regístrate con mi código $code y obtén puntos de bonificación!';
  }

  @override
  String get guest => 'Invitado';
}
