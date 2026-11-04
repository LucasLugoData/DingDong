import 'dart:math';

import 'package:dingdong/dynasty/dynasty_shell.dart';
import 'package:dingdong/dynasty/grammar_screen.dart';
import 'package:dingdong/main.dart' as app;
import 'package:dingdong/store.dart';
import 'package:dingdong/theme.dart';
import 'package:dingdong/widgets/bingo_drum.dart';
import 'package:dingdong/widgets/passive_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.store = await AppStore.load();
    for (final hanzi in ['吃', '饭']) {
      app.store.markSeen(app.store.allWords.firstWhere((w) => w.hanzi == hanzi).id);
    }
  });

  Future<void> open(WidgetTester tester, {bool shell = false}) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(theme: buildTheme(),
      home: shell ? const DynastyShell() :
        Scaffold(body: GrammarScreen(random: Random(14)))));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> draw(WidgetTester tester) async {
    await tap(tester, find.byKey(const ValueKey('grammar-drum')));
    await tester.pump(const Duration(milliseconds: 450));
    expect(tester.widget<BingoDrum>(find.byType(BingoDrum)).spinning, isTrue);
    expect(find.byKey(const ValueKey('ball-吃')), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ball-吃')), findsOneWidget);
    expect(find.byKey(const ValueKey('ball-饭')), findsOneWidget);
  }

  Future<void> add(WidgetTester tester, String key) =>
    tap(tester, find.byKey(ValueKey(key)));

  Color border(WidgetTester tester, int index) {
    final tile = tester.widget<Container>(find.byKey(ValueKey('sentence-$index')));
    return ((tile.decoration! as BoxDecoration).border! as Border).top.color;
  }

  Future<void> submit(WidgetTester tester, int count) async {
    await tap(tester, find.text('Entregar'));
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 350));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('375 px: tirar, SVO, corrección gradual, puntos y otra tirada', (tester) async {
    await open(tester);
    await draw(tester);
    final ball = tester.widget<Container>(find.byKey(const ValueKey('ball-吃')));
    expect(((ball.decoration! as BoxDecoration).border! as Border).top.color,
      AppColors.red);
    expect(find.text('chī'), findsOneWidget);
    await add(tester, 'aux-我');
    await add(tester, 'ball-吃');
    await add(tester, 'ball-饭');
    await tap(tester, find.text('Entregar'));
    expect(border(tester, 0), AppColors.accentSoft);
    await tester.pump(const Duration(milliseconds: 350));
    expect(border(tester, 0), AppColors.green);
    expect(border(tester, 1), AppColors.accentSoft);
    expect(find.byKey(const ValueKey('grammar-score')), findsNothing);
    await tester.pump(const Duration(milliseconds: 350));
    expect(border(tester, 1), AppColors.green);
    expect(border(tester, 2), AppColors.accentSoft);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(border(tester, 2), AppColors.green);
    expect(find.text('Puntuación de la frase: 40'), findsOneWidget);
    expect(find.text('Total: 40'), findsOneWidget);
    for (final id in app.store.player.seen) {
      expect(app.store.player.wordStats[id], (hits: 1, misses: 0));
    }
    expect(app.store.player.wordStats.length, 2);
    await tap(tester, find.text('Otra tirada'));
    await tester.pumpAndSettle();
    expect(find.text('Total: 40'), findsOneWidget);
    expect(find.text('Multiplicador de frase: ×1.25'), findsOneWidget);
    expect(find.byKey(const ValueKey('sentence-0')), findsNothing);
    await add(tester, 'aux-我');
    await add(tester, 'ball-吃');
    await add(tester, 'ball-饭');
    await submit(tester, 3);
    expect(find.text('Puntuación de la frase: 37.5'), findsOneWidget);
    expect(find.text('Total: 77.5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('palabra fuera de orden naranja y registro por bola usada', (tester) async {
    await open(tester);
    await draw(tester);
    await add(tester, 'aux-我');
    await add(tester, 'ball-饭');
    await add(tester, 'ball-吃');
    await submit(tester, 3);
    expect(border(tester, 0), AppColors.green);
    expect(border(tester, 1), AppColors.orange);
    expect(border(tester, 2), AppColors.green);
    expect(find.text('Puntuación de la frase: 0'), findsOneWidget);
    expect(find.text('Total: 0'), findsOneWidget);
    final rice = app.store.allWords.firstWhere((w) => w.hanzi == '饭');
    expect(app.store.player.wordStats[rice.id], (hits: 0, misses: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cada dos frases ofrece pasivas y canjear concede XP', (tester) async {
    await open(tester);
    await draw(tester);
    Future<void> validSentence() async {
      await add(tester, 'aux-我');
      await add(tester, 'ball-吃');
      await add(tester, 'ball-饭');
      await submit(tester, 3);
    }

    await validSentence();
    expect(find.text('Canjear'), findsOneWidget);
    await tap(tester, find.text('Otra tirada'));
    await tester.pumpAndSettle();
    await validSentence();
    expect(find.text('Elige una pasiva para continuar'), findsOneWidget);
    final choice = find.byType(PassiveCard).first;
    await tap(tester, choice);
    expect(find.text('Elige una pasiva para continuar'), findsNothing);
    final before = app.store.player.xp;
    await tap(tester, find.text('Canjear'));
    await tester.pumpAndSettle();
    expect(app.store.player.xp, greaterThan(before));
    expect(find.text('Puntuación: 97'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quitar restaura bola, arrastrar reordena y no duplica bolas', (tester) async {
    await open(tester);
    await draw(tester);
    await add(tester, 'ball-吃');
    await add(tester, 'ball-吃');
    expect(find.byKey(const ValueKey('sentence-1')), findsNothing);
    await add(tester, 'sentence-0');
    expect(find.byKey(const ValueKey('sentence-0')), findsNothing);
    await add(tester, 'aux-我');
    await add(tester, 'ball-饭');
    await add(tester, 'ball-吃');
    await tester.ensureVisible(find.byKey(const ValueKey('sentence-1')));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('sentence-1'))));
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(12, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('sentence-1')),
      matching: find.text('吃')), findsOneWidget);
    await submit(tester, 3);
    expect(find.text('Puntuación de la frase: 40'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no usa palabras no vistas y explica un bombo insuficiente', (tester) async {
    app.store.player.seen.clear();
    await open(tester);
    await tap(tester, find.byKey(const ValueKey('grammar-drum')));
    expect(find.text('Descubre al menos dos palabras, incluido un verbo, en Tarjetas.'),
      findsOneWidget);
    expect(find.byKey(const ValueKey('ball-吃')), findsNothing);
    expect(app.store.player.wordStats, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pestaña Gramática enlaza la pantalla', (tester) async {
    await open(tester, shell: true);
    await tester.tap(find.byKey(const ValueKey('dynasty-tab-3')));
    await tester.pumpAndSettle();
    expect(find.byType(BingoDrum).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
