import 'package:flutter/material.dart';

/// Paleta "Navy + Teal" de SafeWalk.
/// Navy profundo para headers/paneles jerárquicos, teal como color de acción
/// (botones, links, estados activos). Mismo lenguaje en claro y oscuro.
class AppColors {
  AppColors._();

  // Navy - usado en paneles hero, headers, y como base del modo oscuro
  static const navyDark = Color(0xFF0F1830);
  static const navy = Color(0xFF16233F);
  static const navyLight = Color(0xFF24345C);

  // Teal - color de acción, presente en ambos modos
  static const teal = Color(0xFF3FBFB6);
  static const tealDark = Color(0xFF2E9891);

  // Acento "periwinkle" usado solo en las formas orgánicas del hero de auth
  static const blobAccent = Color(0xFF6C86D8);
  static const blobAccentSoft = Color(0xFF98AEEA);

  static const danger = Color(0xFFE5484D); // Solo SOS / errores críticos
  static const success = Color(0xFF3FAE6A);

  // Modo claro
  static const lightBg = Color(0xFFF4F6FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF0F3F8);
  static const lightText = Color(0xFF16233F);
  static const lightMuted = Color(0xFF6B7686);
  static const lightBorder = Color(0xFFE4E8F0);

  // Modo oscuro
  static const darkBg = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF16233F);
  static const darkSurfaceAlt = Color(0xFF1E2C4E);
  static const darkText = Color(0xFFEDF1F8);
  static const darkMuted = Color(0xFF98A3B8);
  static const darkBorder = Color(0xFF2A3A5F);
}

class AppTheme {
  AppTheme._();

  static const double radius = 18;
  static const double pillRadius = 30;

  static ThemeData get light => _build(
    brightness: Brightness.light,
    bg: AppColors.lightBg,
    surface: AppColors.lightSurface,
    surfaceAlt: AppColors.lightSurfaceAlt,
    text: AppColors.lightText,
    muted: AppColors.lightMuted,
    border: AppColors.lightBorder,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    bg: AppColors.darkBg,
    surface: AppColors.darkSurface,
    surfaceAlt: AppColors.darkSurfaceAlt,
    text: AppColors.darkText,
    muted: AppColors.darkMuted,
    border: AppColors.darkBorder,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceAlt,
    required Color text,
    required Color muted,
    required Color border,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.teal,
      onPrimary: Colors.white,
      secondary: AppColors.navy,
      onSecondary: Colors.white,
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
          fontSize: 27,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
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

      // Inputs tipo "pill" (bien redondeados), como en la referencia.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: muted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(pillRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(pillRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(pillRadius),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(pillRadius),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
      ),

      // Botón principal en teal, como "Search Flights" de la referencia.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: muted.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 17),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pillRadius),
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 17),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pillRadius),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
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
