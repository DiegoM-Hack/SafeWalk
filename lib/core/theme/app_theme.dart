import 'package:flutter/material.dart';

/// Paleta central de SafeWalk.
/// Un solo lenguaje de color para modo claro y oscuro: mismo tono ("dusk blue"
/// + acento cálido "glow"), solo cambia la luminosidad de fondo/superficie.
class AppColors {
  AppColors._();

  // Acentos compartidos entre ambos modos
  static const primary = Color(0xFF2E6F95); // Azul dusk
  static const primaryLight = Color(
    0xFF5FA8D3,
  ); // Azul dusk, versión clara (dark mode)
  static const glow = Color(0xFFFFB84D); // "Luz de farol" - acento cálido
  static const danger = Color(0xFFE5484D); // Solo para SOS / errores críticos
  static const success = Color(0xFF3FAE6A);

  // Modo claro
  static const lightBg = Color(0xFFF5F8FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF1A2233);
  static const lightMuted = Color(0xFF5B6472);
  static const lightBorder = Color(0xFFE1E7EF);

  // Modo oscuro
  static const darkBg = Color(0xFF0D1524);
  static const darkSurface = Color(0xFF16213A);
  static const darkSurfaceAlt = Color(0xFF1D2C48);
  static const darkText = Color(0xFFEAF0F7);
  static const darkMuted = Color(0xFF93A0B4);
  static const darkBorder = Color(0xFF283C5E);
}

class AppTheme {
  AppTheme._();

  static const double radius = 18;

  static ThemeData get light => _build(
    brightness: Brightness.light,
    bg: AppColors.lightBg,
    surface: AppColors.lightSurface,
    text: AppColors.lightText,
    muted: AppColors.lightMuted,
    border: AppColors.lightBorder,
    primary: AppColors.primary,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    bg: AppColors.darkBg,
    surface: AppColors.darkSurface,
    text: AppColors.darkText,
    muted: AppColors.darkMuted,
    border: AppColors.darkBorder,
    primary: AppColors.primaryLight,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color muted,
    required Color border,
    required Color primary,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: brightness == Brightness.dark
          ? AppColors.darkBg
          : Colors.white,
      secondary: AppColors.glow,
      onSecondary: AppColors.darkBg,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme,
      dividerColor: border,

      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: text,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: text, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, color: muted, height: 1.4),
        labelLarge: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? AppColors.darkSurfaceAlt
            : const Color(0xFFF0F4F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: muted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.glow,
          foregroundColor: AppColors.darkBg,
          disabledBackgroundColor: muted.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? AppColors.darkSurfaceAlt
            : AppColors.lightText,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
