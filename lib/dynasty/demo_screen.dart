import 'dart:math';

import 'package:flutter/material.dart';

import '../game/solitaire.dart';
import '../models.dart';
import '../theme.dart';
import 'results_screen.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key, required this.run, this.random});

  final SolitaireRun run;
  final Random? random;

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  late final _random = widget.random ?? Random();
  late final List<Word> _words;
  late final List<int> _right;
  final _matchedLeft = <int>{};
  final _matchedRight = <int>{};
  int? _leftSelection;
  int? _rightSelection;
  bool _ended = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final known = widget.run.demoWords(_random);
    _words = known.length < 3 ? [] : [
      for (var i = 0; i < 10; i++) known[i % known.length],
    ];
    _right = List.generate(_words.length, (i) => i)..shuffle(_random);
    if (_words.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _finish(false);
      });
    }
  }

  void _select(int index, bool left) {
    if (_ended) return;
    setState(() {
      if (left) {
        _leftSelection = index;
      } else {
        _rightSelection = index;
      }
      if (_leftSelection == null || _rightSelection == null) return;
      if (_words[_leftSelection!].id != _words[_rightSelection!].id) {
        _ended = true;
        _failed = true;
      } else {
        _matchedLeft.add(_leftSelection!);
        _matchedRight.add(_rightSelection!);
        _leftSelection = null;
        _rightSelection = null;
        _ended = _matchedLeft.length == _words.length;
      }
    });
    if (_ended && !_failed) _finish(true);
  }

  void _finish(bool passed) {
    widget.run.finishDemo(passed);
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => ResultsScreen(
        score: widget.run.score.round(),
        gameMode: 'cards',
        passed: passed,
        isSolitaire: true,
        random: _random,
      ),
    ));
  }

  Widget _tile(int index, bool left) {
    final word = _words[index];
    final matched = (left ? _matchedLeft : _matchedRight).contains(index);
    final selected = (left ? _leftSelection : _rightSelection) == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: OutlinedButton(
        key: ValueKey('demo-${left ? 'left' : 'right'}-$index'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          backgroundColor: selected && _failed ? AppColors.red
              : matched ? AppColors.green.withValues(alpha: .2)
              : selected ? AppColors.lilac.withValues(alpha: .3) : null,
          foregroundColor: AppColors.text,
        ),
        onPressed: _ended || matched ? null : () => _select(index, left),
        child: Text(left ? word.hanzi : '${word.pinyin} · ${word.meaning}',
          textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(body: SafeArea(child: Column(children: [
      const Text('Demostración', style: TextStyle(fontSize: 28)),
      Text('Puntuación: ${widget.run.score.round()}'),
      const Text('Toca un hanzi y su pinyin · significado.'),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(children: [
            for (var i = 0; i < _words.length; i++) _tile(i, true),
          ])),
          const SizedBox(width: 8),
          Expanded(child: Column(children: [for (final i in _right) _tile(i, false)])),
        ]),
      )),
      if (_failed) ...[
        const Text('Demostración fallada', style: TextStyle(color: AppColors.red)),
        FilledButton(onPressed: () => _finish(false), child: const Text('Ver resultados')),
      ],
    ]))),
  );
}
