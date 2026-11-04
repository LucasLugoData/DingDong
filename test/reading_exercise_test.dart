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
    for (var sentence = 0; sentence < exercise.taggedSentences.length; sentence++) {
      final instruction = tester.widget<Text>(find.textContaining('Pulsa el ')).data!;
      final label = instruction.substring('Pulsa el '.length);
      final tokenIndex = exercise.taggedSentences[sentence]
          .indexWhere((token) => token.$2 == label);
      await tester.tap(find.byKey(ValueKey('reading-word-$sentence-$tokenIndex')));
      await tester.pump();
      final next = sentence + 1 == exercise.taggedSentences.length ? 'Terminar' : 'Siguiente frase';
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
