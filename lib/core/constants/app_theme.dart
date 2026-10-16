import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App-wide [ThemeData] for LifeTrack (light + dark), built from the v2
/// design tokens. Font: Plus Jakarta Sans (bundled in assets/fonts).
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'PlusJakartaSans';

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final lt = isDark ? LTColors.dark : LTColors.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.pink,
      onSecondary: Colors.white,
      surface: lt.surface,
      onSurface: lt.text,
      error: AppColors.red,
      outline: lt.border,
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1.5]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: lt.bg,
      extensions: <ThemeExtension<dynamic>>[lt],
      splashFactory: InkRipple.splashFactory,
      cardTheme: CardThemeData(
        color: lt.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lt.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: lt.text,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: lt.text2,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lt.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: lt.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lt.surface2,
        hintStyle: TextStyle(
          color: lt.text3,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: inputBorder(lt.border),
        enabledBorder: inputBorder(lt.border),
        focusedBorder: inputBorder(AppColors.primary),
        errorBorder: inputBorder(AppColors.red),
        focusedErrorBorder: inputBorder(AppColors.red),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionHandleColor: AppColors.primary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      dividerTheme: DividerThemeData(
        color: lt.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
