import 'dart:math';

import 'package:flutter/material.dart';

import '../game/passives.dart';
import '../game/solitaire.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/flash_card.dart';
import '../widgets/score_burst.dart';
import 'demo_screen.dart';
import 'shop_sheet.dart';

class SolitaireScreen extends StatefulWidget {
  const SolitaireScreen({super.key, required this.words, this.random});

  final List<Word> words;
  final Random? random;

  @override
  State<SolitaireScreen> createState() => _SolitaireScreenState();
}

class _SolitaireScreenState extends State<SolitaireScreen>
    with SingleTickerProviderStateMixin {
  late final _random = widget.random ?? Random();
  SolitaireRun? _run;
  bool _flipped = false;
  bool _shopping = false;
  double _drag = 0;
  late final _pulse = AnimationController(vsync: this,
    duration: const Duration(milliseconds: 1100));
  double _scoreFrom = 0;
  bool _chipsChanged = false;
  bool _multChanged = false;
  bool _coinsIncreased = false;

  double get _scoreTime => (_pulse.value * 1100 / 600).clamp(0.0, 1.0);
  double get _displayScore => Tween<double>(begin: _scoreFrom, end: _run?.score ?? 0)
      .transform(Curves.easeOutCubic.transform(_scoreTime));
  double get _pop => sin(pi * (_pulse.value * 3).clamp(0.0, 1.0));

  @override
  void initState() {
    super.initState();
    final seen = widget.words.where((word) => store.player.seen.contains(word.id)).toList();
    if (seen.isNotEmpty) _run = SolitaireRun(seen, [], _random);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _answer(bool correct) async {
    final run = _run;
    if (run == null || run.isDone || _shopping) return;
    final word = run.current!;
    _scoreFrom = _displayScore;
    final chips = run.chips;
    final mult = run.mult;
    final coins = run.coins;
    setState(() {
      run.answer(correct);
      _chipsChanged = chips != run.chips;
      _multChanged = mult != run.mult;
      _coinsIncreased = run.coins > coins;
      _flipped = false;
      _drag = 0;
      _shopping = run.isShopTime;
    });
    store.recordAnswer(word.id, correct);
    _pulse.forward(from: 0);
    if (run.isDone) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => DemoScreen(run: run, random: _random),
      ));
    } else if (_shopping) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => ShopSheet(run: run, random: _random,
          onPurchase: () { if (mounted) setState(() {}); }),
      );
      if (mounted) setState(() => _shopping = false);
    }
  }

  static String _number(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  Widget _scorePanel(SolitaireRun run) {
    final arrival = ((_pulse.value - 600 / 1100) / (260 / 1100)).clamp(0.0, 1.0);
    final pulse = sin(arrival * pi);
    final burning = run.lastEvent?.correct == true &&
        run.mult >= 10 && _pulse.value < 1;
    const style = TextStyle(fontSize: 46, height: 1.2, fontWeight: FontWeight.w900);
    final score = _number(_displayScore);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xff242027), Color(0xff08080c), Color(0xff191219)]),
        border: Border.all(color: AppColors.gold, width: 2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: 65, width: double.infinity,
          child: CustomPaint(
            key: const ValueKey('score-aura'),
            painter: _ScoreFlames(burning ? _pulse.value : 1),
            child: Center(child: Transform.scale(
              scale: 1 + .12 * pulse,
              child: FittedBox(fit: BoxFit.scaleDown, child: Stack(children: [
                ExcludeSemantics(child: Text(score, style: style.copyWith(
                  foreground: Paint()..style = PaintingStyle.stroke
                    ..strokeWidth = 3..color = const Color(0xff9a5d16)))),
                Text(score, key: const ValueKey('score'),
                  style: style.copyWith(color: AppColors.gold,
                    shadows: const [Shadow(color: Color(0xffcf831e), blurRadius: 12)])),
              ])),
            )),
          ),
        ),
        FittedBox(fit: BoxFit.scaleDown, child: Row(children: [
          _casinoChip('+${run.chips} Fichas', AppColors.blue, _chipsChanged),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 9),
            child: Text('×', style: TextStyle(color: AppColors.gold, fontSize: 24))),
          _casinoChip('+${run.mult} Mult', AppColors.red, _multChanged),
          if (run.multMult != 1) Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Transform.rotate(angle: -.12, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(color: AppColors.red,
                border: Border.all(color: AppColors.gold), borderRadius: BorderRadius.circular(4)),
              child: Text('X${_number(run.multMult)} Mult',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            )),
          ),
        ])),
      ]),
    );
  }

  Widget _casinoChip(String label, Color color, bool changed) => Transform.scale(
    scale: 1 + (changed ? .16 * _pop : 0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: color,
        border: Border.all(color: AppColors.gold), borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 3))]),
      child: Text(label, style: const TextStyle(color: Colors.white,
        fontSize: 18, fontWeight: FontWeight.w900)),
    ),
  );

  Widget _passiveThumbnail(Passive passive, int index, ScoreEvent? event) {
    final active = event?.triggered.contains(index) == true && _pulse.value < 1;
    final jump = active ? _pop : 0.0;
    final label = switch (passive.id) {
      'brush' => '+5', 'abacus' => '+1 💰', 'seal' => '×1.5',
      'dragon' => '×2', 'tea' => '+20', 'bamboo' => '+2',
      'jade' => '+0.1', 'spring_autumn' => '+8', 'confucius' => '+15',
      'phoenix' => '+3 💰', 'copper_coin' => '+Mult',
      _ => '${event?.mult ?? 0} Mult',
    };
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4),
      child: Tooltip(message: passive.description,
        child: SizedBox(width: 90, child: Stack(alignment: Alignment.topCenter, children: [
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Transform.translate(offset: Offset(0, -10 * jump),
              child: Transform.rotate(angle: .22 * jump,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2)),
                  child: ClipOval(child: Image.asset('assets/passives/${passive.id}.png',
                    width: 42, height: 42, fit: BoxFit.cover)),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('${passive.hanzi} ${passive.name}', textAlign: TextAlign.center,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppColors.gold)),
          ]),
          if (active) IgnorePointer(child: Opacity(
            opacity: 1 - _pulse.value,
            child: Transform.translate(offset: Offset(0, -8 * _pulse.value),
              child: Text(label, style: const TextStyle(color: AppColors.gold,
                fontSize: 14, fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)]))),
          )),
        ])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final run = _run;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final event = run?.lastEvent;
          final shake = event == null ? 0.0 : shakeFor(event) *
              sin(_pulse.value * pi * 18) * pow(1 - _pulse.value, 3);
          return Transform.translate(
            key: const ValueKey('screen-shake'),
            offset: Offset(shake, shake * .35),
            child: Stack(fit: StackFit.expand, children: [
              SafeArea(
                child: run == null ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Primero descubre tarjetas en Progreso.'),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
                  ],
                )) : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Transform.scale(
                        scale: 1 + (_coinsIncreased ? .22 * _pop : 0),
                        child: Text('${run.coins} monedas', key: const ValueKey('run-coins'),
                          style: const TextStyle(color: AppColors.gold))),
                      Text('${run.index}/100'),
                    ]),
                    _scorePanel(run),
                    SizedBox(
                      height: 88,
                      child: run.passives.isEmpty
                        ? const Center(child: Text('Sin pasivas', style: TextStyle(color: AppColors.muted)))
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            children: [for (var i = 0; i < run.passives.length; i++)
                              if (run.passives[i] case final Passive passive)
                                _passiveThumbnail(passive, i, run.lastEvent),
                            ],
                          ),
                    ),
                    Expanded(child: GestureDetector(
                      onHorizontalDragUpdate: _shopping ? null : (details) =>
                        setState(() => _drag += details.delta.dx),
                      onHorizontalDragCancel: () => setState(() => _drag = 0),
                      onHorizontalDragEnd: _shopping ? null : (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (_drag.abs() > 80 || velocity.abs() > 600) {
                          _answer((_drag + velocity / 10) > 0);
                        } else {
                          setState(() => _drag = 0);
                        }
                      },
                      child: Transform.translate(offset: Offset(_drag, 0),
                        child: run.current == null ? const SizedBox.shrink() : FlashCard(
                          key: ValueKey(run.index), word: run.current!, flipped: _flipped,
                          onFlip: () => setState(() => _flipped = !_flipped),
                        )),
                    )),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      TextButton.icon(onPressed: _shopping ? null : () => _answer(false),
                        icon: const Icon(Icons.arrow_back), label: const Text('No la sé'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.red)),
                      TextButton.icon(onPressed: _shopping ? null : () => _answer(true),
                        icon: const Icon(Icons.arrow_forward), label: const Text('La sé'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.blue)),
                    ]),
                  ]),
                ),
              ),
              ScoreBurst(event: event, eventId: run?.index ?? 0),
            ]),
          );
        },
      ),
    );
  }
}

class _ScoreFlames extends CustomPainter {
  const _ScoreFlames(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    final fade = sin(pi * t);
    final center = Offset(size.width / 2, size.height * .7);
    final bounds = Rect.fromCenter(center: center, width: size.width, height: size.height * 2);
    final glow = Paint()..shader = RadialGradient(colors: [
      Colors.orange.withValues(alpha: .6 * fade),
      Colors.deepOrange.withValues(alpha: 0),
    ]).createShader(bounds);
    canvas.drawOval(bounds, glow);
    for (var i = 0; i < 13; i++) {
      final x = size.width * (i + .5) / 13;
      final height = (20 + 20 * sin(i * 2 + t * pi * 8)) * fade;
      final path = Path()..moveTo(x - 9, size.height)
        ..quadraticBezierTo(x - 13, size.height - height, x + 5 * sin(t * 20 + i), size.height - height - 12)
        ..quadraticBezierTo(x + 4, size.height - height / 2, x + 9, size.height)..close();
      canvas.drawPath(path, Paint()..color = (i.isEven ? Colors.orange : Colors.deepOrange)
        .withValues(alpha: .65 * fade));
    }
  }

  @override
  bool shouldRepaint(_ScoreFlames oldDelegate) => t != oldDelegate.t;
}
