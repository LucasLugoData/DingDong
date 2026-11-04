import 'dart:math';

import 'package:dingdong/dynasty/cards_home.dart';
import 'package:dingdong/dynasty/shop_sheet.dart';
import 'package:dingdong/dynasty/solitaire_screen.dart';
import 'package:dingdong/game/xp.dart';
import 'package:dingdong/main.dart' as app;
import 'package:dingdong/store.dart';
import 'package:dingdong/theme.dart';
import 'package:dingdong/widgets/flash_card.dart';
import 'package:dingdong/widgets/passive_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.store = await AppStore.load();
    for (final word in app.store.allWords.take(3)) {
      app.store.markSeen(word.id);
    }
  });

  Future<void> open(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(theme: buildTheme(),
      home: SolitaireScreen(words: app.store.allWords.take(4).toList(), random: Random(14))));
    await tester.pumpAndSettle();
  }

  testWidgets('a 375 px: 20 respuestas abren tienda y comprar descuenta monedas', (tester) async {
    await open(tester);
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('0/100'), findsOneWidget);
    for (var i = 0; i < 20; i++) {
      await tester.tap(find.text('La sé'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(ShopSheet), findsOneWidget);
    expect(find.byType(PassiveCard), findsNWidgets(3));
    expect(find.text('20/100'), findsOneWidget);
    final shop = tester.widget<ShopSheet>(find.byType(ShopSheet));
    expect(shop.run.coins, 20);
    expect(shop.run.score, 2100);
    final card = tester.widgetList<PassiveCard>(find.byType(PassiveCard)).first;
    final price = int.parse(card.price!.split(' ').first);
    await tester.tap(find.byKey(card.key!));
    await tester.pumpAndSettle();
    expect(shop.run.coins, 20 - price);
    expect(find.text('${20 - price} monedas'), findsNWidgets(2));
    expect(shop.run.passives, hasLength(1));
    expect(find.text('Comprada'), findsOneWidget);
    await tester.tap(find.byKey(card.key!));
    await tester.pumpAndSettle();
    expect(shop.run.coins, 20 - price);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.byType(ShopSheet), findsNothing);
    expect(find.text('${card.hanzi} ${card.name}'), findsOneWidget);
    expect(app.store.player.wordStats.values.fold<int>(0, (sum, s) => sum + s.hits), 20);
    expect(app.store.player.wordStats.keys.every(app.store.player.seen.contains), isTrue);
    expect(app.store.player.wordStats.containsKey(app.store.allWords[3].id), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deslizar, girar, cuatro tiendas y demostración tras 100 respuestas', (tester) async {
    await open(tester);
    await tester.tap(find.byType(FlashCard));
    await tester.pumpAndSettle();
    expect(tester.widget<FlashCard>(find.byType(FlashCard)).flipped, isTrue);
    await tester.drag(find.byType(FlashCard), const Offset(-160, 0));
    await tester.pumpAndSettle();
    expect(find.text('1/100'), findsOneWidget);
    expect(tester.widget<FlashCard>(find.byType(FlashCard)).flipped, isFalse);
    expect(app.store.player.wordStats.values.fold<int>(0, (sum, s) => sum + s.misses), 1);
    for (var i = 2; i <= 100; i++) {
      if (i == 2) {
        await tester.drag(find.byType(FlashCard), const Offset(160, 0));
      } else {
        await tester.tap(find.text('La sé'));
      }
      await tester.pumpAndSettle();
      if (i % 20 == 0 && i < 100) {
        expect(find.byType(ShopSheet), findsOneWidget);
        expect(tester.widget<ShopSheet>(find.byType(ShopSheet)).run.index, i);
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();
      } else {
        expect(find.byType(ShopSheet), findsNothing);
      }
    }
    expect(find.text('Demostración'), findsOneWidget);
    expect(find.text('Puntuación: 49500'), findsOneWidget);
    expect(app.store.player.wordStats.values.fold<int>(0, (sum, s) => sum + s.hits + s.misses), 100);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin monedas no permite comprar', (tester) async {
    await open(tester);
    for (var i = 0; i < 20; i++) {
      await tester.tap(find.text('No la sé'));
      await tester.pumpAndSettle();
    }
    final shop = tester.widget<ShopSheet>(find.byType(ShopSheet));
    expect(tester.widgetList<PassiveCard>(find.byType(PassiveCard))
      .every((card) => card.onTap == null), isTrue);
    expect(shop.run.coins, 0);
    expect(shop.run.passives, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CardsHome abre Solitario como ruta completa', (tester) async {
    app.store.player.xp = unlockXp('hsk2', {
      for (final entry in app.store.wordIdsByDeck.entries) entry.key: entry.value.length,
    });
    await tester.pumpWidget(MaterialApp(theme: buildTheme(),
      home: const Scaffold(body: CardsHome())));
    await tester.tap(find.text('HSK 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solitario'));
    await tester.pumpAndSettle();
    expect(find.byType(SolitaireScreen), findsOneWidget);
    expect(find.byType(FlashCard), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    Navigator.pop(tester.element(find.byType(SolitaireScreen)));
    await tester.pumpAndSettle();
    expect(find.byType(CardsHome), findsOneWidget);
  });
}
