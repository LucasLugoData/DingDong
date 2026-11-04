import 'package:flutter/material.dart';

import '../theme.dart';

class Mascot extends StatelessWidget {
  const Mascot({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _MascotPainter(),
    size: const Size(150, 190),
  );
}

class _MascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 150;
    canvas.save();
    canvas.scale(scale);
    final stroke = Paint()
      ..color = AppColors.accentSoft
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = AppColors.gold;
    canvas.drawCircle(const Offset(75, 42), 27, fill);
    canvas.drawCircle(const Offset(66, 38), 2.5, Paint()..color = AppColors.ink);
    canvas.drawCircle(const Offset(84, 38), 2.5, Paint()..color = AppColors.ink);
    canvas.drawArc(const Rect.fromLTWH(67, 41, 16, 12), .2, 2.7, false, stroke..strokeWidth = 2);
    canvas.drawLine(const Offset(75, 69), const Offset(75, 131), stroke);
    canvas.drawLine(const Offset(75, 82), const Offset(43, 106), stroke);
    canvas.drawLine(const Offset(75, 82), const Offset(107, 106), stroke);
    canvas.drawLine(const Offset(75, 131), const Offset(51, 170), stroke);
    canvas.drawLine(const Offset(75, 131), const Offset(99, 170), stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
