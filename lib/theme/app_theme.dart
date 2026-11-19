import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand (sampled from the Figma file)
  static const green = Color(0xFF35B81F);
  static const greenBright = Color(0xFF4CDB3A);
  static const greenDeep = Color(0xFF1C7A17);
  static const lime = Color(0xFFC8F74A);
  static const navy = Color(0xFF234E7D);
  static const navyDeep = Color(0xFF16365C);

  // Surfaces
  static const bg = Color(0xFFF5F7F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSunken = Color(0xFFEDF1EA);
  static const ink = Color(0xFF0D1B16);
  static const inkSoft = Color(0xFF4A5A50);
  static const muted = Color(0xFF7D8B81);
  static const line = Color(0xFFE4EADF);

  // Dark screens (onboarding / hero cards)
  static const nightTop = Color(0xFF06110F);
  static const nightBottom = Color(0xFF0B241C);

  static const danger = Color(0xFFE5484D);
  static const amber = Color(0xFFF5A524);

  static const darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [nightTop, nightBottom],
  );

  static const greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [greenBright, green],
  );
}

class AppText {
  AppText._();

  static const _family = 'Poppins';

  static TextStyle _s(double size, FontWeight weight, {double? h, Color? c, double? ls}) =>
      TextStyle(
        fontFamily: _family,
        fontSize: size,
        fontWeight: weight,
        height: h,
        letterSpacing: ls,
        color: c ?? AppColors.ink,
      );

  static final display = _s(40, FontWeight.w800, h: 1.05, ls: -1.2);
  static final h1 = _s(30, FontWeight.w700, h: 1.12, ls: -0.6);
  static final h2 = _s(22, FontWeight.w700, h: 1.2, ls: -0.3);
  static final h3 = _s(18, FontWeight.w600, h: 1.25);
  static final body = _s(15, FontWeight.w400, h: 1.5, c: AppColors.inkSoft);
  static final bodyStrong = _s(15, FontWeight.w500, h: 1.45);
  static final small = _s(13, FontWeight.w400, h: 1.4, c: AppColors.muted);
  static final label = _s(12, FontWeight.w600, h: 1.2, ls: 0.8);
  static final tiny = _s(11, FontWeight.w500, h: 1.2, ls: 0.4, c: AppColors.muted);
  static final button = _s(15, FontWeight.w600, h: 1, ls: 0.2);
}

class AppRadius {
  AppRadius._();
  static const card = 22.0;
  static const pill = 999.0;
  static const field = 16.0;
}

class AppShadows {
  AppShadows._();
  static const soft = [
    BoxShadow(color: Color(0x0F12241C), blurRadius: 24, offset: Offset(0, 10)),
  ];
  static const float = [
    BoxShadow(color: Color(0x1F0E2419), blurRadius: 34, offset: Offset(0, 18)),
  ];
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.green,
    brightness: Brightness.light,
    primary: AppColors.green,
    secondary: AppColors.navy,
    surface: AppColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Poppins',
    splashFactory: InkSparkle.splashFactory,
    textTheme: TextTheme(
      displayLarge: AppText.display,
      headlineLarge: AppText.h1,
      headlineMedium: AppText.h2,
      titleMedium: AppText.h3,
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      labelLarge: AppText.button,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.ink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceSunken,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      hintStyle: AppText.body.copyWith(color: AppColors.muted),
      labelStyle: AppText.small,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.green, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: AppText.bodyStrong.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
  );
}
