import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/achievements.dart';
import '../theme.dart';

class AchievementMedal extends StatelessWidget {
  const AchievementMedal({
    super.key,
    required this.medal,
    required this.unlocked,
    this.size = 72,
  });

  final Achievement medal;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget illustration = ClipOval(
      child: Image.asset(
        medal.imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-.3, -.4),
              colors: [AppColors.paper, AppColors.seal, AppColors.paperBack],
            ),
          ),
          child: Center(child: Icon(medal.icon, size: size * .42, color: AppColors.ink)),
        ),
      ),
    );
    if (!unlocked) {
      illustration = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          .2126, .7152, .0722, 0, 0,
          .2126, .7152, .0722, 0, 0,
          .2126, .7152, .0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: Opacity(opacity: .38, child: illustration),
      );
    }
    return Semantics(
      label: '${medal.title}, ${unlocked ? 'desbloqueado' : 'bloqueado'}',
      image: true,
      child: SizedBox(
        width: size,
        height: size * 1.18,
        child: CustomPaint(
          painter: _MedalFramePainter(unlocked: unlocked, color: medal.color),
          child: Stack(children: [
            Positioned(
              left: size * .13, top: size * .13,
              width: size * .74, height: size * .74,
              child: illustration,
            ),
            if (!unlocked)
              Positioned(
                right: size * .04, top: size * .66,
                child: Container(
                  padding: EdgeInsets.all(size * .035),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.muted, width: .6),
                    borderRadius: BorderRadius.circular(size * .035),
                  ),
                  child: Icon(Icons.lock, size: size * .2, color: AppColors.paper),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _MedalFramePainter extends CustomPainter {
  const _MedalFramePainter({required this.unlocked, required this.color});

  final bool unlocked;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = size.width;
    canvas.save();
    canvas.scale(diameter / 72);
    final center = const Offset(36, 36);
    final ring = unlocked ? AppColors.gold : AppColors.line;
    if (unlocked) {
      canvas.drawCircle(center, 35, Paint()
        ..color = AppColors.gold.withValues(alpha: .25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
    for (final left in [true, false]) {
      canvas.save();
      if (!left) {
        canvas.translate(72, 0);
        canvas.scale(-1, 1);
      }
      final ribbon = Path()
        ..moveTo(23, 60)..lineTo(35, 65)..lineTo(30, 84)
        ..lineTo(24, 78)..lineTo(17, 80)..close();
      canvas.drawPath(ribbon, Paint()
        ..color = unlocked ? AppColors.seal : AppColors.line);
      canvas.drawLine(const Offset(26, 66), const Offset(23, 76), Paint()
        ..color = ring.withValues(alpha: .6)..strokeWidth = .7);
      canvas.restore();
    }
    canvas.drawCircle(center, 35, Paint()..color = const Color(0xFF101213));
    final stroke = Paint()..color = ring..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 34, stroke..strokeWidth = 1.5);
    canvas.drawCircle(center, 29, stroke..strokeWidth = .7);
    canvas.drawCircle(center, 27.5, Paint()
      ..color = unlocked ? color : AppColors.line
      ..style = PaintingStyle.stroke..strokeWidth = 1.6);
    for (var i = 0; i < 12; i++) {
      canvas.save();
      canvas.translate(36, 36);
      canvas.rotate(i * math.pi / 6);
      final fret = Path()
        ..moveTo(-4, -30)..lineTo(-4, -32)..lineTo(3, -32)
        ..lineTo(3, -30)..lineTo(0, -30)..lineTo(0, -31);
      canvas.drawPath(fret, stroke..strokeWidth = .65);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MedalFramePainter oldDelegate) =>
      oldDelegate.unlocked != unlocked || oldDelegate.color != color;
}
