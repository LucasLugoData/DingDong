import 'package:flutter/material.dart';

/// Negro, moderno y minimalista. El papiro queda solo para las tarjetas.
class AppColors {
  static const bg = Color(0xFF000000);
  static const surface = Color(0xFF141414);
  static const line = Color(0xFF262626);
  static const accent = Color(0xFFF2F2F2);
  static const accentSoft = Color(0xFFE3C58A);
  static const red = Color(0xFFFF5A5F);
  static const orange = Color(0xFFFF9F43);
  static const blue = Color(0xFF4DA3FF);
  static const green = Color(0xFF3DDC97);
  static const gold = Color(0xFFFFC83D);
  static const lilac = Color(0xFFB57BFF);
  static const bronze = Color(0xFFCD7F32);
  static const silver = Color(0xFFC0C8D8);
  static const text = Color(0xFFF5F5F5);
  static const muted = Color(0xFF8C8C8C);

  // Papiro (tarjetas)
  static const paper = Color(0xFFF1E2C2);
  static const paperBack = Color(0xFFE8D4AC);
  static const card = paper;
  static const cardBack = paperBack;
  static const ink = Color(0xFF2A1E14);
  static const inkMuted = Color(0xFF6E5A40);
  static const seal = Color(0xFFB3261E);
}

/// Papiro plano con bordes tostados (viñeta) y motas de fibra.
class PapyrusPainter extends CustomPainter {
  const PapyrusPainter({this.color = AppColors.paper, this.radius = 28});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(
      radius: 0.9,
      colors: [Color(0x00FFFFFF), Color(0x00C8A060), Color(0x80A8702F)],
      stops: [0, .6, 1],
    ).createShader(rect));
    var seed = 7;
    int next() => seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    final dot = Paint();
    for (var i = 0; i < 160; i++) {
      final x = next() % 10000 / 10000 * size.width;
      final y = next() % 10000 / 10000 * size.height;
      dot.color = Color.fromARGB(12 + next() % 20, 120, 80, 40);
      canvas.drawCircle(Offset(x, y), .6 + next() % 10 / 8, dot);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PapyrusPainter old) => old.color != color || old.radius != radius;
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
    onPrimary: AppColors.bg,
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
    cardTheme: const CardThemeData(color: AppColors.surface, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.line))),
    snackBarTheme: const SnackBarThemeData(backgroundColor: AppColors.surface),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      showDragHandle: true,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: AppColors.muted),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.bg : AppColors.muted),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.line,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}
