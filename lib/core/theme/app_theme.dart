import 'package:flutter/material.dart';

/// Константи теми додатка BondDays
/// Темна тема з неоновими акцентами та Glassmorphism стилем

class AppColors {
  // Основні кольори темної теми
  static const Color darkBg = Color(0xFF0B0C10);      // Глибокий темний фон
  static const Color darkBg2 = Color(0xFF1F2833);     // Трохи світліший фон для карток
  static const Color darkBg3 = Color(0xFF2D3561);     // Для контрастних елементів
  
  // Текст
  static const Color textPrimary = Color(0xFFE0E0E0); // Основний текст
  static const Color textSecondary = Color(0xFF9E9E9E); // Допоміжний текст
  
  // Неонові кольори
  static const Color neonBlue = Color(0xFF00D4FF);    // Неон блакитний
  static const Color neonPink = Color(0xFFFF006E);    // Неон рожевий
  static const Color neonPurple = Color(0xFF8E44AD);  // Неон фіолетовий
  static const Color neonGreen = Color(0xFF00D084);   // Неон зелений
  
  // Спеціальні кольори
  static const Color heartRed = Color(0xFF8B0000);    // Темно-червоне серце
  static const Color success = Color(0xFF4CAF50);     // Успіх
  static const Color error = Color(0xFFE53935);       // Помилка
  static const Color warning = Color(0xFFFFA726);     // Попередження
  
  // Glassmorphism
  static const Color glassLight = Color(0x1AFFFFFF);  // Білий напівпрозорий
  static const Color glassDark = Color(0x0AFFFFFF);   // Темніший напівпрозорий
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}

class AppShadow {
  static final glassLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final glassDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Тема додатка для MaterialApp
ThemeData createAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.dark(
      primary: AppColors.neonBlue,
      secondary: AppColors.neonPink,
      surface: AppColors.darkBg2,
      error: AppColors.error,
      background: AppColors.darkBg,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.neonBlue,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkBg2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(color: AppColors.textSecondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(
          color: AppColors.textSecondary,
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(
          color: AppColors.neonBlue,
          width: 2,
        ),
      ),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      labelStyle: const TextStyle(color: AppColors.textPrimary),
    ),
  );
}
