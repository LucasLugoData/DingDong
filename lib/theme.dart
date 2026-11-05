import 'package:flutter/material.dart';

/// Paleta papiro: papel envejecido, tinta china, sello rojo y oro viejo.
class AppColors {
  static const bg = Color(0xFFF1E3C4);
  static const surface = Color(0xFFE8D5AD);
  static const card = Color(0xFFF8EFDA);
  static const cardBack = Color(0xFFEFDFBC);
  static const line = Color(0xFFC9B088);
  static const accent = Color(0xFFA8322A);
  static const accentSoft = Color(0xFF9A4A1C);
  static const red = Color(0xFFC0392B);
  static const orange = Color(0xFFD2691E);
  static const blue = Color(0xFF1F6FA8);
  static const green = Color(0xFF2E8B57);
  static const gold = Color(0xFFC08A12);
  static const lilac = Color(0xFF7E4FA8);
  static const bronze = Color(0xFFA0602A);
  static const silver = Color(0xFF8C939E);
  static const paper = Color(0xFFF6EAD0);
  static const ink = Color(0xFF2A1E14);
  static const seal = Color(0xFFB3261E);
  static const text = Color(0xFF2A1E14);
  static const muted = Color(0xFF7A6448);
}

/// Fondo de papiro plano con bordes tostados (viñeta) y motas de fibra.
class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: const _PaperPainter(),
    child: child,
  );
}

class _PaperPainter extends CustomPainter {
  const _PaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = AppColors.bg);
    canvas.drawRect(rect, Paint()..shader = RadialGradient(
      radius: 0.95,
      colors: [const Color(0x00FFFFFF), const Color(0x00C8A060), const Color(0x66B07A3A)],
      stops: const [0, .62, 1],
    ).createShader(rect));
    // Fibras del papel: motas deterministas para que no parpadeen.
    var seed = 7;
    int next() => seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    final dot = Paint();
    for (var i = 0; i < 260; i++) {
      final x = next() % 10000 / 10000 * size.width;
      final y = next() % 10000 / 10000 * size.height;
      dot.color = Color.fromARGB(10 + next() % 18, 120, 80, 40);
      canvas.drawCircle(Offset(x, y), .6 + next() % 10 / 8, dot);
    }
  }

  @override
  bool shouldRepaint(_PaperPainter oldDelegate) => false;
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
    brightness: Brightness.light,
    surface: AppColors.surface,
    primary: AppColors.accent,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamilyFallback: cjkFallback,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
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
    cardTheme: const CardThemeData(color: AppColors.card, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.line))),
    snackBarTheme: const SnackBarThemeData(backgroundColor: AppColors.ink),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.bg,
      showDragHandle: true,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.bg),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
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
