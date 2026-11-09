import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';

/// Tema aplikasi, disusun sepenuhnya dari token.
///
/// Mengubah satu nilai token berlaku ke seluruh layar yang memakainya; tidak
/// ada layar yang menulis ulang nilai gaya sendiri.
abstract final class MealoraTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: MealoraColors.primary,
      onPrimary: MealoraColors.onPrimary,
      secondary: MealoraColors.accent,
      onSecondary: MealoraColors.ink,
      tertiary: MealoraColors.peach,
      onTertiary: MealoraColors.ink,
      error: MealoraColors.danger,
      onError: MealoraColors.onPrimary,
      surface: MealoraColors.surface,
      onSurface: MealoraColors.ink,
      surfaceContainerLowest: MealoraColors.surface,
      surfaceContainerLow: MealoraColors.background,
      surfaceContainer: MealoraColors.softGreen,
      onSurfaceVariant: MealoraColors.muted,
      outline: MealoraColors.line,
      outlineVariant: MealoraColors.track,
      shadow: MealoraColors.shadowGlass,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MealoraColors.background,
      fontFamily: MealoraTypography.fontFamily,
      textTheme: TextTheme(
        displayLarge: MealoraTypography.display,
        headlineLarge: MealoraTypography.title,
        headlineMedium: MealoraTypography.headline,
        titleLarge: MealoraTypography.sectionTitle,
        titleMedium: MealoraTypography.subtitle,
        bodyLarge: MealoraTypography.body,
        bodyMedium: MealoraTypography.bodySmall,
        labelLarge: MealoraTypography.button,
        labelMedium: MealoraTypography.label,
        labelSmall: MealoraTypography.caption,
      ),
      dividerTheme: const DividerThemeData(
        color: MealoraColors.line,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: MealoraColors.surface,
        elevation: MealoraElevation.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MealoraRadius.card),
          side: const BorderSide(color: MealoraColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MealoraColors.primary,
          foregroundColor: MealoraColors.onPrimary,
          textStyle: MealoraTypography.button,
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MealoraRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MealoraColors.primary,
          textStyle: MealoraTypography.label,
          minimumSize: const Size(
            MealoraTouch.minTarget,
            MealoraTouch.minTarget,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MealoraColors.surface,
        hintStyle: MealoraTypography.bodyMuted,
        labelStyle: MealoraTypography.label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MealoraSpacing.md,
          vertical: MealoraSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MealoraRadius.chip),
          borderSide: const BorderSide(color: MealoraColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MealoraRadius.chip),
          borderSide: const BorderSide(color: MealoraColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MealoraRadius.chip),
          borderSide: const BorderSide(color: MealoraColors.primary, width: 2),
        ),
      ),
    );
  }
}
