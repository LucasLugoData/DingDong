import 'dart:math';

import 'package:flutter/material.dart';

import '../data/reading_exercises.dart';
import '../main.dart';
import '../theme.dart';
import 'results_screen.dart';

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
  late final List<String> _labels = [
    for (final sentence in _exercise.taggedSentences)
      sentence[_random.nextInt(sentence.length)].$2,
  ];
  int _step = 0, _sentence = 0, _score = 0, _streak = 0, _mistakes = 0;
  int? _feedback;
  bool _finished = false;

  void _answerIdea(int index) {
    if (_feedback != null) return;
    final correct = index == _exercise.correctIndex;
    setState(() {
      _feedback = correct ? index : -index - 1;
      if (correct) {
        _score += (100 * (1 + _streak * .5)).round();
        _streak++;
      } else {
        _mistakes++;
        _streak = 0;
      }
    });
  }

  void _answerWord(int index) {
    if (_feedback != null) return;
    final tagged = _exercise.taggedSentences[_sentence][index];
    final correct = tagged.$2 == _labels[_sentence];
    for (final word in store.allWords.where((w) => w.hanzi == tagged.$1)) {
      store.recordAnswer(word.id, correct);
      break;
    }
    setState(() {
      _feedback = correct ? index : -index - 1;
      if (correct) {
        _score += (100 * (1 + _streak * .5)).round();
        _streak++;
      } else {
        _mistakes++;
        _streak = 0;
      }
    });
  }

  void _continue() {
    setState(() {
      _feedback = null;
      if (_step == 0) {
        _step = 1;
      } else if (_sentence + 1 < _exercise.taggedSentences.length) {
        _sentence++;
      } else {
        _finished = true;
      }
    });
    if (_finished) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => ResultsScreen(
          score: _score,
          gameMode: 'reading',
          passed: true,
          event: {'readingPerfect': _mistakes == 0},
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: ListView(padding: const EdgeInsets.all(20), children: [
        Text(_exercise.readingTitle, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        if (_step == 0) ...[
          Text(_exercise.ideaQuestion, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          for (var i = 0; i < _exercise.options.length; i++)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: OutlinedButton(
              key: ValueKey('reading-option-$i'),
              style: OutlinedButton.styleFrom(
                backgroundColor: _feedback == i ? AppColors.green.withValues(alpha: .25)
                  : _feedback == -i - 1 ? AppColors.red.withValues(alpha: .22) : null),
              onPressed: () => _answerIdea(i), child: Text(_exercise.options[i]))),
        ] else ...[
          Text('Pulsa el ${_labels[_sentence]}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var i = 0; i < _exercise.taggedSentences[_sentence].length; i++)
              ActionChip(
                key: ValueKey('reading-word-$_sentence-$i'),
                backgroundColor: _feedback == i ? AppColors.green.withValues(alpha: .25)
                  : _feedback == -i - 1 ? AppColors.orange.withValues(alpha: .25) : null,
                label: Text(_exercise.taggedSentences[_sentence][i].$1,
                  style: const TextStyle(fontSize: 22)),
                onPressed: () => _answerWord(i)),
          ]),
        ],
        if (_feedback != null) ...[
          const SizedBox(height: 16),
          Text(_step == 0
            ? (_feedback == _exercise.correctIndex ? '¡Correcto!' : 'No es esa; prueba la respuesta correcta.')
            : (_feedback! >= 0 ? '¡Correcto!' : 'No es esa palabra.'),
            style: TextStyle(color: _feedback! >= 0 ? AppColors.green : AppColors.orange,
              fontWeight: FontWeight.bold)),
          if (_step == 0 && _feedback != _exercise.correctIndex)
            FilledButton(onPressed: () => setState(() => _feedback = null),
              child: const Text('Intentar de nuevo')),
          if (_step != 0 || _feedback == _exercise.correctIndex)
            FilledButton(onPressed: _continue,
            child: Text(_step == 0 ? 'Continuar' :
              _sentence + 1 == _exercise.taggedSentences.length ? 'Terminar' : 'Siguiente frase')),
        ],
        const SizedBox(height: 12),
        Text('Puntos: $_score', textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.gold, fontSize: 18)),
      ]),
    ))),
  );
}
