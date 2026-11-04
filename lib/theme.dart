import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0A0B2A);
  static const surface = Color(0xFF161A3F);
  static const card = Color(0xFF2B3357);
  static const cardBack = Color(0xFF262D50);
  static const line = Color(0xFF3A4270);
  static const accent = Color(0xFF5B6CFF);
  static const accentSoft = Color(0xFFA9B2FF);
  static const red = Color(0xFFFF4D4D);
  static const orange = Color(0xFFFF8A3D);
  static const blue = Color(0xFF2E9BFF);
  static const green = Color(0xFF3CD3A3);
  static const gold = Color(0xFFFFCD1F);
  static const lilac = Color(0xFFB57BFF);
  static const bronze = Color(0xFFCD7F32);
  static const silver = Color(0xFFC0C8D8);
  static const paper = Color(0xFFE9DCC0);
  static const ink = Color(0xFF2A1E14);
  static const seal = Color(0xFFB3261E);
  static const text = Color(0xFFF4F5FB);
  static const muted = Color(0xFF9CA3C8);
}

/// Fuentes CJK por plataforma para que los caracteres se vean nítidos.
const cjkFallback = [
  'Noto Sans SC',
  'Noto Sans CJK SC',
  'Microsoft YaHei',
  'PingFang SC',
  'Source Han Sans SC',
];

TextStyle hanziStyle(double size) => TextStyle(
  fontSize: size,
  color: AppColors.text,
  fontWeight: FontWeight.w400,
  fontFamilyFallback: cjkFallback,
  height: 1.15,
);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.dark,
    surface: AppColors.surface,
    primary: AppColors.accent,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamilyFallback: cjkFallback,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withValues(alpha: .25),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      showDragHandle: true,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: AppColors.muted),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.line,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}
