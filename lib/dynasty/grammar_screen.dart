import 'dart:math';

import 'package:flutter/material.dart';

import '../data/grammar_roles.dart';
import '../game/grammar.dart';
import '../game/mastery.dart';
import '../game/passives.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/bingo_drum.dart';
import '../widgets/passive_card.dart';
import 'results_screen.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key, this.random});
  final Random? random;

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _Token {
  _Token(this.id, this.hanzi, this.pinyin, [this.word]);
  final int id;
  final String hanzi;
  final String pinyin;
  final Word? word;
}

class _GrammarScreenState extends State<GrammarScreen> {
  late final _random = widget.random ?? Random();
  List<Word> _balls = [], _pending = [];
  final _sentence = <_Token>[];
  List<bool> _correction = [];
  int _serial = 0, _revealed = 0, _validSentences = 0, _round = 0;
  double _score = 0, _total = 0;
  double _xpBonus = 0;
  int _extraBalls = 0;
  bool _harder = false, _rarer = false;
  List<GrammarPerk>? _choice;
  bool _spinning = false, _checking = false, _done = false;
  String? _message;

  static const _pinyin = ['wǒ', 'nǐ', 'tā', 'shì', 'de', 'zài',
    'hěn', 'bù', 'ma', 'le'];

  Mastery _mastery(Word word) {
    final stats = store.player.wordStats[word.id];
    return masteryOf(stats?.hits ?? 0, stats?.misses ?? 0);
  }

  List<Word> get _seen => store.allWords
    .where((word) => store.player.seen.contains(word.id)).toList();

  void _draw() {
    if (_spinning || _checking || (_balls.isNotEmpty && !_done)) return;
    final words = {for (final word in _seen) word.hanzi: word};
    try {
      final drawn = drawBalls(words.keys, grammarRoles, _random,
        extra: _extraBalls, harder: _harder, rarer: _rarer);
      setState(() {
        _pending = [for (final hanzi in drawn) words[hanzi]!];
        _balls = [];
        _sentence.clear();
        _correction = [];
        _revealed = 0;
        _round = _validSentences;
        _done = false;
        _message = null;
        _spinning = true;
      });
    } on ArgumentError {
      setState(() => _message =
        'Descubre al menos dos palabras, incluido un verbo, en Tarjetas.');
    }
  }

  void _add(String hanzi, String pinyin, [Word? word]) {
    if (_checking || _done) return;
    setState(() => _sentence.add(_Token(_serial++, hanzi, pinyin, word)));
  }

  Future<void> _submit() async {
    if (_checking || _done || _sentence.isEmpty) return;
    final tokens = _sentence.map((token) => token.hanzi).toList();
    final balls = _balls.map((word) => word.hanzi).toList();
    final correction = checkSentence(tokens, grammarRoles);
    final score = scoreSentence(tokens, balls, grammarRoles,
      {for (final word in _balls) word.hanzi: _mastery(word)},
      previousValidSentences: _round);
    final valid = isValidSentence(tokens, balls, grammarRoles);
    setState(() {
      _checking = true;
      _correction = correction;
    });
    for (var i = 0; i < tokens.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() => _revealed = i + 1);
      final word = _sentence[i].word;
      if (word != null) store.recordAnswer(word.id, correction[i]);
    }
    if (!mounted) return;
    setState(() {
      _checking = false;
      _done = true;
      _score = score;
      _total += score;
      if (valid) _validSentences++;
      if (valid && _validSentences % 2 == 0) {
        _choice = rollGrammarChoice(_random);
      }
      _message = valid ? '¡Frase correcta!' :
        'Forma una frase correcta con al menos dos bolas.';
    });
  }

  String _number(double value) => value.toStringAsFixed(2)
    .replaceFirst(RegExp(r'\.?0+$'), '');

  void _choose(GrammarPerk perk) {
    final percent = int.parse(perk.positive.split('%').firstWhere(
      (part) => RegExp(r'^\+\d+$').hasMatch(part)).substring(1));
    setState(() {
      _xpBonus += percent / 100;
      if (perk.negative == GrammarPerk.negatives[0]) _extraBalls++;
      if (perk.negative == GrammarPerk.negatives[1]) _harder = true;
      if (perk.negative == GrammarPerk.negatives[2]) _rarer = true;
      _choice = null;
    });
  }

  void _redeem() {
    final score = (_total * (1 + _xpBonus)).round();
    final validStreak = _validSentences;
    setState(() {
      _total = 0;
      _score = 0;
      _validSentences = 0;
      _round = 0;
      _xpBonus = 0;
      _extraBalls = 0;
      _harder = false;
      _rarer = false;
      _choice = null;
      _balls = [];
      _sentence.clear();
      _done = false;
    });
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) =>
      ResultsScreen(score: score, gameMode: 'grammar', passed: true,
        event: {'grammarValidStreak': validStreak})));
  }

  Widget _tile({required String hanzi, required String pinyin,
    required Color color, required Key key, VoidCallback? onTap,
    String? status}) => Semantics(
      label: '$hanzi, $pinyin${status == null ? '' : ', $status'}',
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          key: key,
          width: 76,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(color: color.withValues(alpha: .22),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(24)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(hanzi, style: hanziStyle(23), textAlign: TextAlign.center),
            Text(pinyin, style: TextStyle(fontSize: 12, color: color),
              textAlign: TextAlign.center),
            if (status != null) Icon(status == 'Bien' ? Icons.check : Icons.close,
              size: 16, color: color),
          ]),
        ),
      ),
    );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: AnimatedBuilder(
      animation: store,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Gramática', style: TextStyle(fontSize: 24,
            fontWeight: FontWeight.bold)),
          Text('Total: ${_number(_total)}', key: const ValueKey('grammar-total'),
            style: const TextStyle(color: AppColors.gold, fontSize: 20)),
          Text('Multiplicador de frase: ×${_number(1 + .25 * _round)}'),
          if (_xpBonus > 0) Text('Bonus de XP: +${_number(_xpBonus * 100)}%'),
          if (_validSentences > 0)
            FilledButton(onPressed: _redeem, child: const Text('Canjear')),
          if (_choice != null) ...[
            const Text('Elige una pasiva para continuar'),
            Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
              for (var i = 0; i < _choice!.length; i++)
                PassiveCard(hanzi: ['文', '词'][i], name: _choice![i].positive,
                  description: _choice![i].negative,
                  selected: false, seed: i,
                  onTap: () => _choose(_choice![i])),
            ]),
          ],
          Center(child: BingoDrum(words: _seen,
            colors: {for (final word in _seen) word.id: _mastery(word).color},
            spinning: _spinning,
            onTap: _spinning || _checking || (_balls.isNotEmpty && !_done)
              ? null : _draw,
            onSpinEnd: () {
              if (mounted) {
                setState(() {
                _balls = _pending;
                _spinning = false;
              });
              }
            })),
          if (_balls.isEmpty) Text(_spinning ? 'Girando…' : 'Toca el bombo para tirar.',
            textAlign: TextAlign.center),
          if (_balls.isNotEmpty) ...[
            const Text('Bolas · toca para añadir'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final word in _balls)
                Opacity(opacity: _sentence.any((t) => t.word?.id == word.id) ? .35 : 1,
                  child: _tile(hanzi: word.hanzi, pinyin: word.pinyin,
                    color: _mastery(word).color, key: ValueKey('ball-${word.hanzi}'),
                    onTap: _checking || _done ||
                      _sentence.any((t) => t.word?.id == word.id) ? null :
                      () => _add(word.hanzi, word.pinyin, word))),
            ]),
            const SizedBox(height: 12),
            const Text('Tu frase · toca para quitar, arrastra para ordenar'),
            SizedBox(height: 110, child: _sentence.isEmpty
              ? const Center(child: Text('Añade bolas y auxiliares.'))
              : ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                itemCount: _sentence.length,
                onReorderItem: (oldIndex, newIndex) {
                  if (_checking || _done) return;
                  setState(() {
                    _sentence.insert(newIndex, _sentence.removeAt(oldIndex));
                  });
                },
                itemBuilder: (context, i) {
                  final token = _sentence[i];
                  final status = i < _revealed ?
                    (_correction[i] ? 'Bien' : 'Mal') : null;
                  return Padding(key: ValueKey(token.id),
                    padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: ReorderableDragStartListener(index: i,
                      enabled: !_checking && !_done,
                      child: _tile(hanzi: token.hanzi, pinyin: token.pinyin,
                        color: status == null ? AppColors.accentSoft :
                          status == 'Bien' ? AppColors.green : AppColors.orange,
                        status: status, key: ValueKey('sentence-$i'),
                        onTap: _checking || _done ? null :
                          () => setState(() => _sentence.removeAt(i)))));
                })),
            const Text('Auxiliares'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var i = 0; i < auxiliaryTokens.length; i++)
                _tile(hanzi: auxiliaryTokens[i], pinyin: _pinyin[i],
                  color: AppColors.muted, key: ValueKey('aux-${auxiliaryTokens[i]}'),
                  onTap: _checking || _done ? null :
                    () => _add(auxiliaryTokens[i], _pinyin[i])),
            ]),
            const SizedBox(height: 12),
            FilledButton(onPressed: _sentence.isEmpty || _checking || _done
              ? null : _submit, child: Text(_checking ? 'Corrigiendo…' : 'Entregar')),
          ],
          if (_message != null) Text(_message!, textAlign: TextAlign.center),
          if (_done) ...[
            Text('Puntuación de la frase: ${_number(_score)}',
              key: const ValueKey('grammar-score'),
              style: const TextStyle(color: AppColors.gold, fontSize: 20)),
            FilledButton(onPressed: _draw, child: const Text('Otra tirada')),
          ],
        ]),
      ),
    ),
  );
}
