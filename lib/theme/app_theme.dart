import 'package:flutter/material.dart';

class AppColors {
  // Base Canvas & Surfaces
  static const Color surface = Color(0xFFFFF8F6);
  static const Color surfaceDim = Color(0xFFE0D8D6);
  static const Color surfaceBright = Color(0xFFFFF8F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFBF2F0);
  static const Color surfaceContainer = Color(0xFFF5ECEA);
  static const Color surfaceContainerHigh = Color(0xFFEFE6E4);
  static const Color surfaceContainerHighest = Color(0xFFE9E1DF);

  // Text & Editorial Hierarchy
  static const Color onSurface = Color(0xFF1E1B1A);
  static const Color onSurfaceVariant = Color(0xFF4F4441);
  static const Color inverseSurface = Color(0xFF342F2E);
  static const Color inverseOnSurface = Color(0xFFF8EFED);
  static const Color outline = Color(0xFF817471);
  static const Color outlineVariant = Color(0xFFD3C3BF);

  // Cocoa & Warm Brand Tones
  static const Color primary = Color(0xFF634B44);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF7D635B);
  static const Color onPrimaryContainer = Color(0xFFFFE3DB);
  static const Color primaryFixed = Color(0xFFFDDBD1);
  static const Color onPrimaryFixed = Color(0xFF291711);
  static const Color onPrimaryFixedVariant = Color(0xFF58413A);

  // Secondary & Accents
  static const Color secondary = Color(0xFF685D4A);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFEDDEC5);
  static const Color onSecondaryContainer = Color(0xFF6C614E);
  static const Color secondaryFixed = Color(0xFFF0E0C8);
  static const Color onSecondaryFixed = Color(0xFF221B0B);

  // Tertiary
  static const Color tertiary = Color(0xFF5F4C4F);
  static const Color tertiaryFixed = Color(0xFFF6DCDF);

  // Status Categorical Accents
  static const Color visitedBg = Color(0xFFE3EFE8);
  static const Color visitedText = Color(0xFF2C573F);

  static const Color wishlistBg = Color(0xFFFCEBD9);
  static const Color wishlistText = Color(0xFF8A5229);

  // Must Order box
  static const Color mustOrderBg = Color(0xFFFBF4EB);

  // Ambient Gradients
  static const LinearGradient signaturePastelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7E7CE), Color(0xFFFCEEE7), Color(0xFFF3D9DC)],
  );

  static const LinearGradient warmBannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEDDEC5), Color(0xFFFBF2F0), Color(0xFFF6DCDF)],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEFEAE4), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        hintStyle: const TextStyle(
          color: AppColors.outline,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEFEAE4), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEFEAE4), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryContainer,
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          shape: const StadiumBorder(),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      fontFamily: 'Plus Jakarta Sans',
    );
  }
}
