import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Carta de pasiva con acabado de papel antiguo y un boceto a tinta.
class PassiveCard extends StatelessWidget {
  const PassiveCard({
    super.key,
    required this.hanzi,
    required this.name,
    required this.description,
    this.price,
    this.selected = false,
    this.onTap,
    this.seed = 0,
  });

  final String hanzi;
  final String name;
  final String description;
  final String? price;
  final bool selected;
  final VoidCallback? onTap;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 220,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: CustomPaint(
            painter: _PaperPainter(seed: seed, selected: selected),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 72,
                    child: Center(
                      child: Text(
                        hanzi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: hanzi.length > 1 ? 38 : 48,
                          height: 1,
                          fontFamilyFallback: cjkFallback,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.ink.withValues(alpha: .82),
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  if (price != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 82),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.seal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          price!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.paper,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  _PaperPainter({required this.seed, required this.selected});

  final int seed;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final shape = Path();
    const steps = 12;
    for (var i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = i == 0 || i == steps ? 1.5 : 1.5 + random.nextDouble() * 2.5;
      if (i == 0) { shape.moveTo(x, y); } else { shape.lineTo(x, y); }
    }
    for (var i = 0; i <= steps; i++) {
      final y = size.height * i / steps;
      final x = i == 0 || i == steps ? size.width - 1.5 : size.width - 1.5 - random.nextDouble() * 2.5;
      shape.lineTo(x, y);
    }
    for (var i = steps; i >= 0; i--) {
      final x = size.width * i / steps;
      final y = i == 0 || i == steps ? size.height - 1.5 : size.height - 1.5 - random.nextDouble() * 2.5;
      shape.lineTo(x, y);
    }
    for (var i = steps; i >= 0; i--) {
      final y = size.height * i / steps;
      final x = i == 0 || i == steps ? 1.5 : 1.5 + random.nextDouble() * 2.5;
      shape.lineTo(x, y);
    }
    shape.close();

    canvas.drawPath(shape, Paint()..color = AppColors.paper);
    canvas.save();
    canvas.clipPath(shape);

    final fiberPaint = Paint()
      ..color = AppColors.ink.withValues(alpha: .09)
      ..strokeWidth = .45;
    for (var i = 0; i < 42; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 2 + random.nextDouble() * 9;
      canvas.drawLine(Offset(x, y), Offset(x + length, y + random.nextDouble() * 1.5), fiberPaint);
    }
    _drawSketch(canvas, size, random);
    canvas.restore();

    final border = Paint()
      ..color = AppColors.ink.withValues(alpha: selected ? .9 : .72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 2.4 : 1.6;
    canvas.drawPath(shape, border);
    final inner = Path()..addRect(Rect.fromLTWH(5, 5, size.width - 10, size.height - 10));
    canvas.drawPath(inner, Paint()
      ..color = AppColors.ink.withValues(alpha: .22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .55);
  }

  void _drawSketch(Canvas canvas, Size size, math.Random random) {
    final paint = Paint()
      ..color = AppColors.ink.withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..strokeCap = StrokeCap.round;
    final area = Rect.fromLTWH(12, 14, size.width - 24, 48);
    switch (random.nextInt(3)) {
      case 0: // Montañas a tinta
        for (var i = 0; i < 3; i++) {
          final x = area.left + i * area.width / 3;
          final path = Path()
            ..moveTo(x, area.bottom)
            ..quadraticBezierTo(x + 11, area.top + random.nextDouble() * 8, x + 24, area.bottom)
            ..moveTo(x + 8, area.bottom - 5)
            ..quadraticBezierTo(x + 22, area.top + 8, x + 35, area.bottom - 3);
          canvas.drawPath(path, paint);
        }
      case 1: // Muro agrietado
        canvas.drawRect(area.deflate(5), paint);
        for (var i = 0; i < 4; i++) {
          final x = area.left + 12 + i * 27;
          canvas.drawLine(Offset(x, area.top), Offset(x - 3 + random.nextDouble() * 6, area.bottom), paint);
        }
        final crack = Path()
          ..moveTo(area.center.dx, area.top + 4)
          ..lineTo(area.center.dx - 5, area.center.dy)
          ..lineTo(area.center.dx + 2, area.center.dy + 4)
          ..lineTo(area.center.dx - 3, area.bottom - 3);
        canvas.drawPath(crack, paint);
      case 2: // Rollo de bambú
        for (var i = 0; i < 5; i++) {
          final x = area.left + 7 + i * 25;
          canvas.drawLine(Offset(x, area.top + 4), Offset(x, area.bottom - 4), paint);
          canvas.drawOval(Rect.fromCenter(center: Offset(x, area.top + 4), width: 5, height: 4), paint);
          canvas.drawOval(Rect.fromCenter(center: Offset(x, area.bottom - 4), width: 5, height: 4), paint);
        }
        canvas.drawLine(Offset(area.left + 5, area.top + 12), Offset(area.right - 5, area.top + 12), paint);
        canvas.drawLine(Offset(area.left + 5, area.bottom - 12), Offset(area.right - 5, area.bottom - 12), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.selected != selected;
}
