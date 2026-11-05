import 'dart:math';

import 'package:dingdong/dynasty/demo_screen.dart';
import 'package:dingdong/dynasty/results_screen.dart';
import 'package:dingdong/game/solitaire.dart';
import 'package:dingdong/game/xp.dart';
import 'package:dingdong/main.dart' as app;
import 'package:dingdong/store.dart';
import 'package:dingdong/theme.dart';
import 'package:dingdong/widgets/roulette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FixedRandom implements Random {
  FixedRandom({this.offer = true, this.lilac = true});
  final bool offer;
  final bool lilac;

  @override
  int nextInt(int max) => offer ? 0 : max ~/ 2;
  @override
  bool nextBool() => lilac;
  @override
  double nextDouble() => 0;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.store = await AppStore.load();
    app.store.player.lastBonusAt = DateTime.now();
  });

  Future<void> open(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: screen));
    await tester.pumpAndSettle();
  }

  SolitaireRun runWith(int count, {bool correct = true}) {
    final run = SolitaireRun(app.store.allWords.take(count).toList(), [], Random(5));
    while (!run.isDone) {
      run.answer(correct);
    }
    return run;
  }

  Future<void> tapTile(WidgetTester tester, String side, int index) async {
    final tile = find.byKey(ValueKey('demo-$side-$index'));
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  testWidgets('diez parejas correctas canjean XP una vez y conceden victoria', (tester) async {
    final run = runWith(10);
    await open(tester, DemoScreen(run: run, random: FixedRandom(offer: false)));
    final rights = tester.widgetList<OutlinedButton>(find.byType(OutlinedButton))
      .where((button) => (button.key! as ValueKey<String>).value.startsWith('demo-right'))
      .map((button) => (button.key! as ValueKey<String>).value).toList();
    expect(rights, hasLength(10));
    expect(rights, isNot(List.generate(10, (i) => 'demo-right-$i')));
    for (var i = 0; i < 10; i++) {
      await tapTile(tester, 'left', i);
      await tapTile(tester, 'right', i);
    }
    expect(find.byType(ResultsScreen), findsOneWidget);
    expect(app.store.player.xp, solitaireXpFromScore(run.score.round()));
    expect(app.store.player.xp, greaterThan(0));
    expect(run.finalScore, run.score);
    expect(app.store.player.gamesPlayed['cards'], 1);
    expect(app.store.player.medals, contains('solitaire_win'));
    expect(find.textContaining('¡Subida de nivel!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(app.store.player.gamesPlayed['cards'], 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('un error marca ambas fichas en rojo, bloquea la demo y da cero XP', (tester) async {
    final run = runWith(10);
    await open(tester, DemoScreen(run: run, random: FixedRandom()));
    await tapTile(tester, 'right', 1);
    await tapTile(tester, 'left', 0);
    for (final key in ['demo-left-0', 'demo-right-1']) {
      final button = tester.widget<OutlinedButton>(find.byKey(ValueKey(key)));
      expect(button.onPressed, isNull);
      expect(button.style!.backgroundColor!.resolve({}), AppColors.red);
    }
    await tester.tap(find.text('Ver resultados'));
    await tester.pumpAndSettle();
    expect(find.text('Has perdido la experiencia'), findsOneWidget);
    expect(find.text('+0 XP'), findsOneWidget);
    expect(find.text('Tentar a la suerte'), findsNothing);
    expect(app.store.player.xp, 0);
    expect(app.store.player.gamesPlayed['cards'], 1);
    expect(app.store.player.medals, isNot(contains('solitaire_win')));
    expect(run.finalScore, 0);
  });

  for (final win in [true, false]) {
    testWidgets('ruleta fija aplica ${win ? '×2' : '×0.75'} antes de canjear', (tester) async {
      await open(tester, ResultsScreen(score: 100000, gameMode: 'cards',
        passed: true, isSolitaire: true, random: FixedRandom(lilac: win)));
      expect(app.store.player.gamesPlayed, isEmpty);
      await tester.tap(find.text('Tentar a la suerte'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lila'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Girar'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(app.store.player.xp, 0);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Canjear XP')).onPressed, isNull);
      await tester.pumpAndSettle();
      expect(find.text(win ? 'Acierto ×2' : 'Fallo ×0.75'), findsOneWidget);
      await tester.tap(find.text('Canjear XP'));
      await tester.pumpAndSettle();
      expect(app.store.player.xp, (solitaireXpFromScore(100000) * (win ? 2 : .75)).round());
      expect(app.store.player.gamesPlayed['cards'], 1);
      expect(app.store.player.medals.contains('roulette_win'), win);
      expect(app.store.player.medals, containsAll(['solitaire_win', 'solitaire_100k', 'level_2']));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('rechazar la ruleta conserva XP y muestra el bono x2 y la animación', (tester) async {
    app.store.player.lastBonusAt = null;
    app.store.player.bonusMode = 'cards';
    await open(tester, ResultsScreen(score: 100, gameMode: 'cards',
      passed: true, isSolitaire: true, random: FixedRandom()));
    expect(find.text('Bonificación x2'), findsOneWidget);
    await tester.tap(find.text('Canjear XP'));
    await tester.pump();
    final initial = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value!;
    await tester.pump(const Duration(milliseconds: 700));
    final middle = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value!;
    expect(middle, greaterThan(initial));
    await tester.pumpAndSettle();
    expect(app.store.player.xp, solitaireXpFromScore(100) * 2);
    expect(find.byType(Roulette), findsNothing);
  });

  for (final mode in ['grammar', 'reading']) {
    testWidgets('$mode reutiliza resultados sin ruleta ni logros de solitario', (tester) async {
      await open(tester, ResultsScreen(score: 100, gameMode: mode,
        passed: true, random: FixedRandom()));
      expect(app.store.player.xp, xpFromScore(100));
      expect(app.store.player.gamesPlayed[mode], 1);
      expect(find.text('Tentar a la suerte'), findsNothing);
      expect(app.store.player.medals, isNot(contains('solitaire_win')));
    });
  }

  testWidgets('tres conocidas completan diez fichas; menos de tres falla', (tester) async {
    await open(tester, DemoScreen(run: runWith(3), random: FixedRandom(offer: false)));
    expect(find.byType(OutlinedButton), findsNWidgets(20));
    await tester.pumpWidget(const SizedBox());
    await open(tester, DemoScreen(run: runWith(2), random: FixedRandom()));
    expect(find.text('Has perdido la experiencia'), findsOneWidget);
    expect(app.store.player.xp, 0);
    expect(app.store.player.gamesPlayed['cards'], 1);
  });
}
