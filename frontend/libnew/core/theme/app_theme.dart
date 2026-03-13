import 'package:flutter/material.dart';


class AppTheme {
  // Colors
  static const Color secondaryOrange = Color(0xFFFE8235);
  static const Color primaryOrange = Color(0xFFFF7A00);
  static const Color lightOrange = Color(0xFFFFE4D2);
  static const Color backgroundColor = Color(0xFFF9F9F9);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color lightGray = Color(0xFFF2F2F2);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFEEEEEE);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color shadowColor = Color(0x1A000000);

  // Gradients
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [secondaryOrange, primaryOrange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [cardBackground, Color(0xFFFCFCFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: shadowColor,
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: secondaryOrange.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: shadowColor,
      blurRadius: 4,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusCircle = 50.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Padding
  static const EdgeInsetsGeometry screenPadding = EdgeInsets.all(spacingM);
  static const EdgeInsetsGeometry cardPadding = EdgeInsets.all(spacingL);
  static const EdgeInsetsGeometry buttonPadding = EdgeInsets.symmetric(
    horizontal: spacingXL,
    vertical: spacingM,
  );
  static const EdgeInsetsGeometry inputPadding = EdgeInsets.symmetric(
    horizontal: spacingM,
    vertical: spacingM,
  );

  // Typography
  static TextStyle displayLarge = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle displayMedium = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle displaySmall = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle headlineMedium = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle headlineSmall = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle titleLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle titleMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle labelLarge = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle labelMedium = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle labelSmall = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  // App Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryOrange,
        secondary: secondaryOrange,
        surface: cardBackground,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        error: errorRed,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cardBackground,
        foregroundColor: textPrimary,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: headlineMedium.copyWith(color: textPrimary),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: mediumGray,
          disabledForegroundColor: textTertiary,
          elevation: 0,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: labelLarge,
          shadowColor: Colors.transparent,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryOrange,
          padding: inputPadding,
          textStyle: labelLarge.copyWith(color: secondaryOrange),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryOrange,
          side: const BorderSide(color: secondaryOrange),
          padding: buttonPadding,
          textStyle: labelLarge.copyWith(color: secondaryOrange),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGray,
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        labelStyle: titleMedium.copyWith(color: textSecondary),
        floatingLabelStyle: titleMedium.copyWith(color: secondaryOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
          gapPadding: 0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: secondaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: inputPadding,
      ),
      textTheme: TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightGray,
        disabledColor: mediumGray,
        selectedColor: secondaryOrange,
        secondarySelectedColor: secondaryOrange,
        padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingXS),
        labelStyle: labelMedium,
        secondaryLabelStyle: labelMedium.copyWith(color: Colors.white),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusCircle),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        elevation: 2,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: secondaryOrange,
        unselectedItemColor: textTertiary,
        elevation: 4,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: labelSmall,
        unselectedLabelStyle: labelSmall,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        elevation: 6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: secondaryOrange,
        linearTrackColor: lightGray,
        circularTrackColor: lightGray,
      ),
    );
  }

  // Dark theme (optional - if you want to support dark mode)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Add dark theme configuration if needed
    );
  }
}