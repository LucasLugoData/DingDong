import 'dart:math';

import 'package:flutter/material.dart';

import '../game/achievements.dart';
import '../game/xp.dart';
import '../main.dart';
import '../widgets/roulette.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.score, required this.gameMode,
    required this.passed, this.isSolitaire = false, this.random,
    this.event = const {}});

  final int score;
  final String gameMode;
  final bool passed;
  final bool isSolitaire;
  final Random? random;
  final Map<String, Object> event;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final _random = widget.random ?? Random();
  late final int _initialXp;
  late final bool _bonus;
  late final bool _offerRoulette;
  bool _rouletteOpen = false;
  bool? _rouletteWon;
  int? _earned;

  @override
  void initState() {
    super.initState();
    _initialXp = store.player.xp;
    _bonus = store.bonusMode == widget.gameMode;
    _offerRoulette = widget.passed && widget.isSolitaire && _random.nextInt(4) == 0;
    if (!_offerRoulette) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _redeem();
      });
    }
  }

  void _redeem() {
    if (_earned != null || (_rouletteOpen && _rouletteWon == null)) return;
    final multiplier = _rouletteWon == null ? 1 : _rouletteWon! ? 2 : .75;
    final baseXp = widget.passed ? (xpFromScore(widget.score) * multiplier).round() : 0;
    final earned = store.grantXp(widget.gameMode, baseXp);
    for (final id in evaluate(store.player, store.wordIdsByDeck, event: {
      ...widget.event,
      if (widget.isSolitaire) ...{
        'solitaireWin': widget.passed,
        'solitaireScore': widget.score,
      },
      if (_rouletteWon == true) 'rouletteWin': true,
    })) {
      store.unlockMedal(id);
    }
    setState(() => _earned = earned);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _earned != null,
    child: Scaffold(body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Text(widget.passed ? 'Demostración superada' : 'Has perdido la experiencia',
          style: const TextStyle(fontSize: 26), textAlign: TextAlign.center),
        Text('Puntuación: ${widget.score}'),
        if (_bonus && widget.passed) const Text('Bonificación x2'),
        if (_earned == null) ...[
          if (!_rouletteOpen && _offerRoulette)
            FilledButton(onPressed: () => setState(() => _rouletteOpen = true),
              child: const Text('Tentar a la suerte')),
          if (_rouletteOpen) Roulette(random: _random,
            onFinished: (won) => setState(() => _rouletteWon = won)),
          FilledButton(
            onPressed: _rouletteOpen && _rouletteWon == null ? null : _redeem,
            child: const Text('Canjear XP')),
        ] else ...[
          Text('+$_earned XP', key: const ValueKey('earned-xp'),
            style: const TextStyle(fontSize: 32)),
          if (_rouletteWon != null) Text(_rouletteWon! ? 'Ruleta ×2' : 'Ruleta ×0.75'),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: _initialXp.toDouble(), end: (_initialXp + _earned!).toDouble()),
            duration: const Duration(milliseconds: 1400),
            builder: (context, xp, _) {
              final progress = progressOf(xp.round());
              return Column(children: [
                Text('Nivel ${progress.level}'),
                LinearProgressIndicator(value: progress.xpEnNivel / progress.xpNecesaria),
                Text('${progress.xpEnNivel} / ${progress.xpNecesaria} XP'),
              ]);
            },
          ),
          if (progressOf(_initialXp + _earned!).level > progressOf(_initialXp).level)
            Text('¡Subida de nivel! Nivel ${progressOf(_initialXp + _earned!).level}'),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
        ],
      ]),
    ))),
  );
}
