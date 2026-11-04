import 'dart:math';

import 'package:flutter/material.dart';

import '../game/passives.dart';
import '../game/solitaire.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/flash_card.dart';
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
    duration: const Duration(milliseconds: 260));

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
    setState(() {
      run.answer(correct);
      _flipped = false;
      _drag = 0;
      _shopping = run.isShopTime;
    });
    store.recordAnswer(word.id, correct);
    if (correct) _pulse.forward(from: 0);
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

  @override
  Widget build(BuildContext context) {
    final run = _run;
    return Scaffold(
      body: SafeArea(
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
              Text('${run.coins} monedas', key: const ValueKey('run-coins'),
                style: const TextStyle(color: AppColors.gold)),
              Text('${run.index}/100'),
            ]),
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) => Transform.scale(
                scale: 1 + .08 * sin(_pulse.value * pi), child: child),
              child: Text(_number(run.score), key: const ValueKey('score'),
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900,
                  color: AppColors.text)),
            ),
            FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('+${run.chips}', style: const TextStyle(color: AppColors.blue,
                fontSize: 22, fontWeight: FontWeight.w800)),
              const Text(' Fichas', style: TextStyle(color: AppColors.text)),
              const SizedBox(width: 20),
              Text('+${run.mult}', style: const TextStyle(color: AppColors.red,
                fontSize: 22, fontWeight: FontWeight.w800)),
              const Text(' Mult', style: TextStyle(color: AppColors.gold)),
            ])),
            if (run.multMult != 1) Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.red,
                borderRadius: BorderRadius.circular(20)),
              child: Text('X${_number(run.multMult)} Mult',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 52,
              child: run.passives.isEmpty
                ? const Center(child: Text('Sin pasivas', style: TextStyle(color: AppColors.muted)))
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: [for (final passive in run.passives.whereType<Passive>())
                      Padding(padding: const EdgeInsets.only(right: 8),
                        child: Tooltip(message: passive.description,
                          child: Chip(label: Text('${passive.hanzi} ${passive.name}')))),
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
    );
  }
}
