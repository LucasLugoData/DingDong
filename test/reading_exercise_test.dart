import 'dart:math';

import 'package:dingdong/data/reading_exercises.dart';
import 'package:dingdong/dynasty/reading_exercise_screen.dart';
import 'package:dingdong/dynasty/results_screen.dart';
import 'package:dingdong/main.dart' as app;
import 'package:dingdong/store.dart';
import 'package:dingdong/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstRandom implements Random {
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.store = await AppStore.load();
    app.store.player.lastBonusAt = DateTime.now();
  });

  testWidgets('completar lectura otorga XP y medalla a 375 px', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(theme: buildTheme(),
      home: ReadingExerciseScreen(random: FirstRandom())));

    await tester.tap(find.byKey(const ValueKey('reading-option-0')));
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    final exercise = readingExercises.first;
    final questions = analysisQuestions(exercise, FirstRandom());
    expect(questions.length, greaterThan(exercise.taggedSentences.length));
    for (var q = 0; q < questions.length; q++) {
      final question = questions[q];
      final words = exercise.taggedSentences[question.sentence];
      // Selecciona todas las palabras con esa función (puede haber varias).
      for (var i = 0; i < words.length; i++) {
        if (words[i].$2 == question.label) {
          await tester.ensureVisible(find.byKey(ValueKey('reading-word-${question.sentence}-$i')));
          await tester.tap(find.byKey(ValueKey('reading-word-${question.sentence}-$i')));
          await tester.pump();
        }
      }
      await tester.ensureVisible(find.byKey(const ValueKey('reading-check')));
      await tester.tap(find.byKey(const ValueKey('reading-check')));
      await tester.pump();
      expect(find.text('¡Correcto!'), findsOneWidget);
      final next = q + 1 == questions.length ? 'Terminar' : 'Siguiente';
      await tester.ensureVisible(find.text(next));
      await tester.tap(find.text(next));
      await tester.pumpAndSettle();
    }

    expect(find.byType(ResultsScreen), findsOneWidget);
    await tester.pumpAndSettle();
    expect(app.store.player.xp, greaterThan(0));
    expect(app.store.player.medals, contains('reading_perfect'));
    expect(tester.takeException(), isNull);
  });
}
