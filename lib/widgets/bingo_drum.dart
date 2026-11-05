import 'dart:math';

import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

class BingoDrum extends StatefulWidget {
  const BingoDrum({super.key, required this.words, required this.colors,
    required this.spinning, required this.onTap, required this.onSpinEnd});

  final List<Word> words;
  final Map<String, Color> colors;
  final bool spinning;
  final VoidCallback? onTap;
  final VoidCallback onSpinEnd;

  @override
  State<BingoDrum> createState() => _BingoDrumState();
}

class _BingoDrumState extends State<BingoDrum>
    with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(vsync: this,
    duration: const Duration(milliseconds: 900))
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onSpinEnd();
    });

  @override
  void didUpdateWidget(BingoDrum oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning && !oldWidget.spinning) _spin.forward(from: 0);
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.spinning ? 'Bombo girando' : 'Tirar el bombo',
    button: true,
    child: InkWell(
      key: const ValueKey('grammar-drum'),
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(90),
      child: AnimatedBuilder(
        animation: _spin,
        builder: (context, _) => CustomPaint(
          size: const Size(270, 180),
          painter: _DrumPainter(widget.words, widget.colors,
            Curves.easeInOut.transform(_spin.value) * pi * 4),
        ),
      ),
    ),
  );
}

class _DrumPainter extends CustomPainter {
  _DrumPainter(this.words, this.colors, this.angle);
  final List<Word> words;
  final Map<String, Color> colors;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 78);
    final wire = Paint()..color = AppColors.accentSoft
      ..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawLine(center + const Offset(-40, 60),
      center + const Offset(-60, 94), wire);
    canvas.drawLine(center + const Offset(40, 60),
      center + const Offset(60, 94), wire);
    canvas.drawLine(center + const Offset(-65, 94),
      center + const Offset(65, 94), wire);
    canvas.drawCircle(center, 73, Paint()..color = AppColors.surface);
    // Un anillo de hasta 6 bolas y una en el centro: sin solaparse.
    final visible = words.take(7).toList();
    final ring = min(visible.length, 6);
    for (var i = 0; i < visible.length; i++) {
      final word = visible[i];
      final orbit = angle + i * 2 * pi / max(ring, 1);
      final position = i < 6
          ? center + Offset(cos(orbit) * 46, sin(orbit) * 46)
          : center;
      canvas.drawCircle(position, 18, Paint()
        ..color = colors[word.id] ?? AppColors.red);
      final text = TextPainter(
        text: TextSpan(style: const TextStyle(color: AppColors.bg,
          fontFamilyFallback: cjkFallback), children: [
          TextSpan(text: '${word.hanzi}\n', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          TextSpan(text: word.pinyin, style: const TextStyle(fontSize: 8)),
        ]),
        textAlign: TextAlign.center, textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: 34);
      text.paint(canvas, position - Offset(text.width / 2, text.height / 2));
    }
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawCircle(Offset.zero, 73, wire);
    for (final width in [35.0, 100.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset.zero,
        width: width, height: 146), wire);
    }
    canvas.drawLine(const Offset(-73, 0), const Offset(73, 0), wire);
    canvas.restore();
    canvas.drawLine(center + const Offset(73, 0),
      center + Offset(88, sin(angle) * 16), wire);
    canvas.drawCircle(center + Offset(88, sin(angle) * 16), 5,
      Paint()..color = AppColors.gold);
  }

  @override
  bool shouldRepaint(covariant _DrumPainter oldDelegate) => true;
}
