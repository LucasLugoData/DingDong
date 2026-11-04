import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

enum RouletteColor { lilac, yellow }

class Roulette extends StatefulWidget {
  const Roulette({super.key, required this.onFinished, this.random});

  final ValueChanged<bool> onFinished;
  final Random? random;

  @override
  State<Roulette> createState() => _RouletteState();
}

class _RouletteState extends State<Roulette> with SingleTickerProviderStateMixin {
  late final _random = widget.random ?? Random();
  late final _spin = AnimationController(vsync: this,
    duration: const Duration(milliseconds: 1600));
  RouletteColor? _choice;
  RouletteColor? _outcome;
  bool _finished = false;

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_choice == null || _outcome != null) return;
    setState(() => _outcome = _random.nextBool() ? RouletteColor.lilac : RouletteColor.yellow);
    await _spin.forward();
    if (!mounted) return;
    setState(() => _finished = true);
    widget.onFinished(_choice == _outcome);
  }

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.arrow_drop_down, size: 36),
    AnimatedBuilder(animation: _spin, builder: (context, _) => Transform.rotate(
      angle: Curves.easeOutCubic.transform(_spin.value) *
        (8 * pi + (_outcome == RouletteColor.yellow ? pi : 0)),
      child: CustomPaint(size: const Size(180, 180), painter: _WheelPainter()),
    )),
    Wrap(spacing: 12, children: [
      for (final color in RouletteColor.values)
        ChoiceChip(
          label: Text(color == RouletteColor.lilac ? 'Lila' : 'Amarillo'),
          selectedColor: color == RouletteColor.lilac ? AppColors.lilac : AppColors.gold,
          selected: _choice == color,
          onSelected: _outcome != null ? null : (_) => setState(() => _choice = color),
        ),
    ]),
    FilledButton(onPressed: _choice == null || _outcome != null ? null : _start,
      child: const Text('Girar')),
    if (_finished) Text(_choice == _outcome ? 'Acierto ×2' : 'Fallo ×0.75'),
  ]);
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawArc(rect, -pi, pi, true, Paint()..color = AppColors.lilac);
    canvas.drawArc(rect, 0, pi, true, Paint()..color = AppColors.gold);
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) => false;
}
