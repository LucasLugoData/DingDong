import 'dart:math';

import 'package:flutter/material.dart';

import '../data/reading_exercises.dart';
import '../main.dart';
import '../theme.dart';
import 'results_screen.dart';

/// Preguntas de análisis: hasta [perSentence] funciones distintas por frase
/// (sin contar partículas), en orden de frase.
List<({int sentence, String label})> analysisQuestions(
    ReadingExercise exercise, Random random, {int perSentence = 2}) => [
  for (var i = 0; i < exercise.taggedSentences.length; i++)
    ...({for (final word in exercise.taggedSentences[i]) word.$2}
        .where((label) => label != 'partícula').toList()..shuffle(random))
        .take(perSentence)
        .map((label) => (sentence: i, label: label)),
];

class ReadingExerciseScreen extends StatefulWidget {
  const ReadingExerciseScreen({super.key, this.random, this.readingTitle});
  final Random? random;
  final String? readingTitle;

  @override
  State<ReadingExerciseScreen> createState() => _ReadingExerciseScreenState();
}

class _ReadingExerciseScreenState extends State<ReadingExerciseScreen> {
  late final Random _random = widget.random ?? Random();
  late final ReadingExercise _exercise = readingExercises
      .firstWhere((item) => item.readingTitle == widget.readingTitle,
        orElse: () => readingExercises[_random.nextInt(readingExercises.length)]);
  late final _questions = analysisQuestions(_exercise, _random);
  int _step = 0, _question = 0, _score = 0, _streak = 0, _mistakes = 0;
  int? _ideaFeedback;
  final Set<int> _selected = {};
  bool? _checked;

  void _answerIdea(int index) {
    if (_ideaFeedback != null) return;
    final correct = index == _exercise.correctIndex;
    setState(() {
      _ideaFeedback = correct ? index : -index - 1;
      _award(correct);
    });
  }

  void _award(bool correct) {
    if (correct) {
      _score += (100 * (1 + _streak * .5)).round();
      _streak++;
    } else {
      _mistakes++;
      _streak = 0;
    }
  }

  List<(String, String)> get _words => _exercise.taggedSentences[_questions[_question].sentence];

  Set<int> get _target => {
    for (var i = 0; i < _words.length; i++)
      if (_words[i].$2 == _questions[_question].label) i,
  };

  void _check() {
    final target = _target;
    final correct = _selected.length == target.length && _selected.containsAll(target);
    for (final i in target) {
      final word = store.allWords.where((w) => w.hanzi == _words[i].$1).firstOrNull;
      if (word != null) store.recordAnswer(word.id, _selected.contains(i));
    }
    setState(() {
      _checked = correct;
      _award(correct);
    });
  }

  void _continue() {
    if (_step == 0) {
      setState(() {
        _step = 1;
        _ideaFeedback = null;
      });
      return;
    }
    if (_question + 1 < _questions.length) {
      setState(() {
        _question++;
        _selected.clear();
        _checked = null;
      });
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => ResultsScreen(
        score: _score,
        gameMode: 'reading',
        passed: true,
        event: {'readingPerfect': _mistakes == 0},
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_exercise.readingTitle)),
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: ListView(padding: const EdgeInsets.all(20), children: [
        _ScoreBadge(score: _score, streak: _streak),
        const SizedBox(height: 20),
        if (_step == 0) ..._idea() else ..._analysis(),
      ]),
    ))),
  );

  List<Widget> _idea() => [
    Text(_exercise.ideaQuestion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
    const SizedBox(height: 12),
    for (var i = 0; i < _exercise.options.length; i++)
      Padding(padding: const EdgeInsets.only(bottom: 8), child: OutlinedButton(
        key: ValueKey('reading-option-$i'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(14),
          backgroundColor: _ideaFeedback == i ? AppColors.green.withValues(alpha: .25)
            : _ideaFeedback == -i - 1 ? AppColors.red.withValues(alpha: .22) : null),
        onPressed: () => _answerIdea(i), child: Text(_exercise.options[i]))),
    if (_ideaFeedback != null) ...[
      _Feedback(correct: _ideaFeedback == _exercise.correctIndex,
        wrongText: 'No es esa. Prueba otra vez.'),
      if (_ideaFeedback == _exercise.correctIndex)
        FilledButton(onPressed: _continue, child: const Text('Continuar'))
      else
        FilledButton(onPressed: () => setState(() => _ideaFeedback = null),
          child: const Text('Intentar de nuevo')),
    ],
  ];

  List<Widget> _analysis() {
    final question = _questions[_question];
    final target = _target;
    final last = _question + 1 == _questions.length;
    return [
      Text('Pregunta ${_question + 1} de ${_questions.length}',
        style: const TextStyle(color: AppColors.muted)),
      const SizedBox(height: 4),
      Text('Marca cada palabra que sea: ${question.label}',
        key: const ValueKey('reading-instruction'),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      const Text('Puede haber más de una. Pulsa «Comprobar» al terminar.',
        style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (var i = 0; i < _words.length; i++)
          FilterChip(
            key: ValueKey('reading-word-${question.sentence}-$i'),
            showCheckmark: false,
            selected: _selected.contains(i),
            selectedColor: AppColors.accent.withValues(alpha: .35),
            backgroundColor: _checked == null ? null
              : target.contains(i) ? AppColors.green.withValues(alpha: .3)
              : _selected.contains(i) ? AppColors.red.withValues(alpha: .3) : null,
            label: Text(_words[i].$1, style: hanziStyle(24)),
            onSelected: _checked != null ? null : (on) => setState(() {
              on ? _selected.add(i) : _selected.remove(i);
            }),
          ),
      ]),
      const SizedBox(height: 20),
      if (_checked == null)
        FilledButton(
          key: const ValueKey('reading-check'),
          onPressed: _selected.isEmpty ? null : _check,
          child: const Text('Comprobar'))
      else ...[
        _Feedback(correct: _checked!,
          wrongText: 'En verde están las correctas: ${[for (final i in target) _words[i].$1].join('、')}'),
        FilledButton(onPressed: _continue, child: Text(last ? 'Terminar' : 'Siguiente')),
      ],
    ];
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.correct, required this.wrongText});
  final bool correct;
  final String wrongText;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.green : AppColors.red;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Icon(correct ? Icons.check_circle : Icons.cancel, color: color, size: 30),
        const SizedBox(width: 12),
        Expanded(child: Text(correct ? '¡Correcto!' : wrongText,
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800))),
      ]),
    );
  }
}

/// Marcador de puntos estilo sello: puntos y racha.
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.streak});
  final int score;
  final int streak;

  @override
  Widget build(BuildContext context) => Center(
    child: FittedBox(fit: BoxFit.scaleDown, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('PUNTOS', style: TextStyle(color: AppColors.muted, fontSize: 12,
          letterSpacing: 2, fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        TweenAnimationBuilder<double>(
          tween: Tween(end: score.toDouble()),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, _) => Text('${value.round()}',
            key: const ValueKey('reading-score'),
            style: const TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w800)),
        ),
        if (streak > 1) ...[
          const SizedBox(width: 10),
          Text('racha ×$streak', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
        ],
      ]),
    )),
  );
}
