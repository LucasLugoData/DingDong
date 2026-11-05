import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/praise.dart';
import '../game/solitaire.dart';

const _gold = Color(0xffffd56a);
const _ink = Color(0xff180f12);
const _red = Color(0xffc63227);

/// Displacement for the host screen; failed answers never shake it.
double shakeFor(ScoreEvent e) {
  if (!e.correct) return 0;
  final tier = praiseFor(e.streak)?.tier ?? 0;
  return (math.log(1 + math.max(0, e.gain)) * 1.15 + tier * .8)
      .clamp(0.0, 12.0);
}

class ScoreBurst extends StatefulWidget {
  const ScoreBurst({
    super.key,
    required this.event,
    required this.eventId,
    this.duration = const Duration(milliseconds: 1100),
  });

  final ScoreEvent? event;
  final int eventId;
  final Duration duration;

  @override
  State<ScoreBurst> createState() => _ScoreBurstState();
}

class _ScoreBurstState extends State<ScoreBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ScoreEvent? _event;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _start();
  }

  @override
  void didUpdateWidget(ScoreBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (oldWidget.eventId != widget.eventId) _start();
  }

  void _start() {
    _event = widget.event;
    _controller.stop();
    if (_event == null) {
      _controller.value = 1;
      return;
    }
    final event = _event!;
    final tier = event.correct ? praiseFor(event.streak)?.tier ?? 0 : 0;
    if (!event.correct) {
      HapticFeedback.lightImpact();
    } else if (tier == 5) {
      HapticFeedback.heavyImpact();
    } else if (tier >= 3) {
      HapticFeedback.mediumImpact();
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final event = _event;
          if (event == null || _controller.isCompleted) {
            return const SizedBox.expand();
          }
          final t = _controller.value;
          if (!event.correct) {
            return Stack(fit: StackFit.expand, children: [
              CustomPaint(painter: _FailurePainter(t)),
            ]);
          }
          final praise = praiseFor(event.streak);
          final tier = praise?.tier ?? 0;
          final arrival = Curves.elasticOut.transform(_phase(t, 0, .31));
          final gainTime = _phase(t, .318, .727);
          final pop = gainTime < .22
              ? 1.4 * Curves.easeOutBack.transform(gainTime / .22)
              : 1.4 - .4 * Curves.easeOut.transform(
                  _phase(gainTime, .22, .43));
          return Stack(fit: StackFit.expand, children: [
            CustomPaint(painter: _CelebrationPainter(t, event.gain, tier)),
            if (t < .45)
              Align(
                alignment: const Alignment(0, -.30),
                child: Opacity(
                  opacity: 1 - _phase(t, .318, .45),
                  child: Transform.translate(
                    offset: Offset(
                      math.sin(t * 150) * 4 * _phase(t, .18, .28),
                      -340 * (1 - arrival),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Transform.translate(
                        offset: Offset(-65 * (1 - arrival), 0),
                        child: _plate(_number(event.chips), const Color(0xff164b86)),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('×', style: TextStyle(
                          fontSize: 36, color: _gold, fontWeight: FontWeight.w900)),
                      ),
                      Transform.translate(
                        offset: Offset(65 * (1 - arrival), 0),
                        child: _plate(_number(event.mult), _red),
                      ),
                    ]),
                  ),
                ),
              ),
            if (t >= .318 && t < .727)
              Align(
                alignment: const Alignment(0, -.16),
                child: Opacity(
                  opacity: 1 - _phase(gainTime, .55, 1),
                  child: Transform.translate(
                    offset: Offset(0, -85 * gainTime),
                    child: Transform.scale(
                      scale: pop,
                      child: SizedBox(
                        width: 250,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _outlined('+${_number(event.gain)}', 76),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (event.multMult != 1 && t >= .318)
              Align(
                alignment: const Alignment(.66, .04),
                child: Opacity(
                  opacity: 1 - _phase(t, .75, 1),
                  child: Transform.rotate(
                    angle: -.2 + (1 - _phase(t, .318, .48)) * 2,
                    child: Transform.scale(
                      scale: 1 + (1 - _phase(t, .318, .48)),
                      child: _plate('X${_number(event.multMult)}', _red),
                    ),
                  ),
                ),
              ),
            if (praise != null && t >= .318)
              Align(
                alignment: const Alignment(0, .28),
                child: Opacity(
                  opacity: 1 - _phase(t, .78, 1),
                  child: Transform.rotate(
                    angle: -.07,
                    child: Transform.scale(
                      scale: Curves.elasticOut.transform(_phase(t, .318, .65)),
                      child: SizedBox(
                        width: 310,
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _outlined(praise.hanzi, 46 + tier * 7.0,
                                imperial: tier == 5),
                          ),
                          _outlined(praise.text, 22 + tier * 1.0),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
          ]);
        },
      ),
    );
  }
}

double _phase(double t, double start, double end) =>
    ((t - start) / (end - start)).clamp(0.0, 1.0);

String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();

Widget _plate(String text, Color color) => Container(
  constraints: const BoxConstraints(maxWidth: 115),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: color,
    border: Border.all(color: _gold, width: 2),
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [BoxShadow(color: _ink, offset: Offset(0, 5), blurRadius: 2)],
  ),
  child: FittedBox(fit: BoxFit.scaleDown, child: Text(text,
    style: const TextStyle(color: Colors.white, fontSize: 28,
      fontWeight: FontWeight.w900))),
);

Widget _outlined(String text, double size, {bool imperial = false}) {
  final style = TextStyle(fontSize: size, fontWeight: FontWeight.w900, height: 1.2);
  return Stack(children: [
    ExcludeSemantics(child: Text(text, style: style.copyWith(
      foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 6..color = _ink,
    ))),
    ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: imperial
            ? [_gold, const Color(0xffef847a), _gold, const Color(0xff56b99b), _gold]
            : [const Color(0xfffff5bd), _gold, const Color(0xffed8b24)],
      ).createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    ),
  ]);
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter(this.t, this.gain, this.tier);
  final double t;
  final double gain;
  final int tier;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .42);
    final fade = 1 - _phase(t, .72, 1);
    final paint = Paint();
    if (t >= .24 && t < .38) {
      final flash = _phase(t, .24, .38);
      paint.shader = RadialGradient(colors: [
        Colors.white.withValues(alpha: 1 - flash),
        _gold.withValues(alpha: .7 * (1 - flash)),
        _gold.withValues(alpha: 0),
      ]).createShader(Rect.fromCircle(center: center, radius: 110));
      canvas.drawCircle(center, 110, paint);
      paint.shader = null;
    }
    if (t < .26) return;
    final flight = _phase(t, .26, 1);
    final count = (6 + math.log(1 + math.max(0, gain)) * 1.6).round().clamp(6, 20);
    for (var i = 0; i < count; i++) {
      final angle = -math.pi + .18 + i / (count - 1) * (math.pi - .36);
      final speed = 150 + (i % 4) * 35.0;
      final point = center + Offset(
        math.cos(angle) * speed * flight,
        math.sin(angle) * speed * flight + 290 * flight * flight,
      );
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(i + flight * 8);
      final coin = Path()..fillType = PathFillType.evenOdd
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: 8))
        ..addRect(const Rect.fromLTWH(-2.5, -2.5, 5, 5));
      paint.color = _gold.withValues(alpha: fade);
      canvas.drawPath(coin, paint);
      paint..style = PaintingStyle.stroke..strokeWidth = 1
        ..color = const Color(0xffa96b16).withValues(alpha: fade);
      canvas.drawPath(coin, paint);
      paint.style = PaintingStyle.fill;
      canvas.restore();
    }
    if (tier == 0 || t < .318) return;
    final origin = Offset(size.width / 2, size.height * .62);
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(t * 1.8);
    for (var i = 0; i < 8 + tier * 4; i++) {
      canvas.rotate(2 * math.pi / (8 + tier * 4));
      paint.color = (tier == 5
          ? HSVColor.fromAHSV(1, i * 37.0 % 360, .5, 1).toColor()
          : _gold).withValues(alpha: .16 * fade);
      canvas.drawPath(Path()..moveTo(0, 0)..lineTo(-10, 135 + tier * 8.0)
        ..lineTo(10, 135 + tier * 8.0)..close(), paint);
      paint.color = (i.isEven ? _gold : const Color(0xff48ad87))
          .withValues(alpha: fade);
      canvas.drawCircle(Offset(20 * math.sin(i.toDouble()),
          (50 + 100 * flight) * (1 + i % 3 * .2)), 2 + tier * .3, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CelebrationPainter oldDelegate) =>
      t != oldDelegate.t || gain != oldDelegate.gain || tier != oldDelegate.tier;
}

class _FailurePainter extends CustomPainter {
  const _FailurePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .43);
    final burst = _phase(t, .22, 1);
    final paint = Paint()
      ..color = _red.withValues(alpha: 1 - burst)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.square;
    // Each arm of the cross breaks away independently from its center.
    for (var i = 0; i < 4; i++) {
      final angle = math.pi / 4 + i * math.pi / 2;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final offset = center + direction * (burst * 65) +
          Offset(math.sin(t * 70) * 3 * (1 - burst), 65 * burst * burst);
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(burst * (i.isEven ? 1 : -1));
      canvas.drawLine(direction * 2, direction * 27, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FailurePainter oldDelegate) => t != oldDelegate.t;
}
