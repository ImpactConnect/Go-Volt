import 'package:flutter/material.dart';
import 'gv_colors.dart';
import 'gv_typography.dart';
import 'gv_border_radius.dart';

/// Go-Volts Material theme.
///
/// Apply via: `MaterialApp(theme: GVTheme.light, ...)`
abstract final class GVTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: GVColors.brandGreen,
        primary: GVColors.brandGreen,
        onPrimary: GVColors.white,
        secondary: GVColors.accentGreen,
        onSecondary: GVColors.nearBlack,
        error: GVColors.error,
        surface: GVColors.white,
        onSurface: GVColors.nearBlack,
        surfaceContainerHighest: GVColors.softBackground,
      ),
      scaffoldBackgroundColor: GVColors.softBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: GVColors.deepGreen,
        foregroundColor: GVColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GVTypography.h3.copyWith(color: GVColors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GVColors.brandGreen,
          foregroundColor: GVColors.nearBlack,
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: GVBorderRadius.buttonRadius,
          ),
          textStyle: GVTypography.buttonLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GVColors.brandGreen,
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: GVBorderRadius.buttonRadius,
          ),
          side: const BorderSide(color: GVColors.brandGreen, width: 1.5),
          textStyle: GVTypography.buttonLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GVColors.brandGreen,
          textStyle: GVTypography.buttonMedium,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: GVColors.brandGreen,
        selectionColor: Color(0x4000C853),
        selectionHandleColor: GVColors.brandGreen,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GVColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: const OutlineInputBorder(
          borderRadius: GVBorderRadius.fieldRadius,
          borderSide: BorderSide(color: GVColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: GVBorderRadius.fieldRadius,
          borderSide: BorderSide(color: GVColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: GVBorderRadius.fieldRadius,
          borderSide:
              BorderSide(color: GVColors.brandGreen, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: GVBorderRadius.fieldRadius,
          borderSide: BorderSide(color: GVColors.error),
        ),
        labelStyle: GVTypography.bodySmall
            .copyWith(color: GVColors.textSecondary),
        hintStyle:
            GVTypography.body.copyWith(color: GVColors.textDisabled),
        errorStyle: GVTypography.caption.copyWith(color: GVColors.error),
      ),
      cardTheme: const CardThemeData(
        color: GVColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: GVBorderRadius.cardRadius,
          side: BorderSide(color: GVColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: GVBorderRadius.chipRadius,
        ),
        labelStyle: GVTypography.label,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: GVColors.white,
        selectedItemColor: GVColors.brandGreen,
        unselectedItemColor: GVColors.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: TextTheme(
        displayLarge: GVTypography.display,
        headlineLarge: GVTypography.h1,
        headlineMedium: GVTypography.h2,
        headlineSmall: GVTypography.h3,
        bodyLarge: GVTypography.body,
        bodyMedium: GVTypography.bodySmall,
        labelLarge: GVTypography.buttonLarge,
        labelMedium: GVTypography.label,
        labelSmall: GVTypography.caption,
      ),
      dividerTheme: const DividerThemeData(
        color: GVColors.divider,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GVColors.nearBlack,
        contentTextStyle:
            GVTypography.bodySmall.copyWith(color: GVColors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: GVBorderRadius.cardRadius,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get dark => darkTheme;

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: GVColors.darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GVColors.brandGreen,
        brightness: Brightness.dark,
        primary: GVColors.brandGreen,
        onPrimary: GVColors.nearBlack,
        secondary: GVColors.accentGreen,
        surface: const Color(0xFF1C2420),
        onSurface: Colors.white,
        surfaceContainerHighest: const Color(0xFF131A16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GVColors.darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GVTypography.h3.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GVColors.brandGreen,
          foregroundColor: GVColors.nearBlack,
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: GVBorderRadius.buttonRadius,
          ),
          textStyle: GVTypography.buttonLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GVColors.brandGreen,
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: GVBorderRadius.buttonRadius,
          ),
          side: const BorderSide(color: GVColors.brandGreen, width: 1.5),
          textStyle: GVTypography.buttonLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GVColors.brandGreen,
          textStyle: GVTypography.buttonMedium,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: GVColors.brandGreen,
        selectionColor: Color(0x4000C853),
        selectionHandleColor: GVColors.brandGreen,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C2420),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: const OutlineInputBorder(
          borderRadius: GVBorderRadius.fieldRadius,
          borderSide: BorderSide(color: Color(0xFF2E3D35)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: GVBorderRadius.fieldRadius,
          borderSide: BorderSide(color: Color(0xFF2E3D35)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: GVBorderRadius.fieldRadius,
          borderSide: BorderSide(color: GVColors.brandGreen, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: GVBorderRadius.fieldRadius,
          borderSide: BorderSide(color: GVColors.error),
        ),
        labelStyle: GVTypography.bodySmall.copyWith(color: GVColors.neutral400),
        hintStyle: GVTypography.body.copyWith(color: GVColors.neutral500),
        errorStyle: GVTypography.caption.copyWith(color: GVColors.error),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1C2420),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: GVBorderRadius.cardRadius,
          side: BorderSide(color: Color(0xFF2E3D35)),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: GVBorderRadius.chipRadius,
        ),
        labelStyle: GVTypography.label.copyWith(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F1512),
        selectedItemColor: GVColors.brandGreen,
        unselectedItemColor: GVColors.neutral400,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: TextTheme(
        displayLarge: GVTypography.display.copyWith(color: Colors.white),
        headlineLarge: GVTypography.h1.copyWith(color: Colors.white),
        headlineMedium: GVTypography.h2.copyWith(color: Colors.white),
        headlineSmall: GVTypography.h3.copyWith(color: Colors.white),
        bodyLarge: GVTypography.body.copyWith(color: Colors.white),
        bodyMedium: GVTypography.bodySmall.copyWith(color: GVColors.neutral300),
        labelLarge: GVTypography.buttonLarge.copyWith(color: Colors.white),
        labelMedium: GVTypography.label.copyWith(color: Colors.white),
        labelSmall: GVTypography.caption.copyWith(color: GVColors.neutral400),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2E3D35),
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1C2420),
        contentTextStyle: GVTypography.bodySmall.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: GVBorderRadius.cardRadius,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
