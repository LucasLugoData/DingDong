import 'package:dingdong/dynasty/cards_home.dart';
import 'package:dingdong/game/xp.dart';
import 'package:dingdong/main.dart' as app;
import 'package:dingdong/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.store = await AppStore.load();
  });

  testWidgets('HSK2 se bloquea con cero XP y muestra elección al desbloquear', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CardsHome())));

    expect(find.text('Desbloquea con ${unlockXp('hsk2', {
      for (final entry in app.store.wordIdsByDeck.entries) entry.key: entry.value.length,
    })} XP'), findsNWidgets(2)); // Solitario + HSK2
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(4)); // Solitario + HSK2-4

    app.store.player.xp = unlockXp('hsk2', {
      for (final entry in app.store.wordIdsByDeck.entries) entry.key: entry.value.length,
    });
    app.store.notifyListeners();
    await tester.pumpAndSettle();
    expect(find.text('SOLITARIO'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(2)); // HSK3-4
    await tester.scrollUntilVisible(find.text('Todo'), 200);
    expect(tester.getTopLeft(find.text('Todo')).dy,
      greaterThan(tester.getTopLeft(find.text('Favoritas', skipOffstage: false)).dy)); // Todo al final
  });
}
