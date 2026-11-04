import 'dart:io';

import 'package:dingdong/dynasty/dynasty_shell.dart';
import 'package:dingdong/game/achievements.dart';
import 'package:dingdong/game/player.dart';
import 'package:dingdong/game/xp.dart';
import 'package:dingdong/main.dart' as app;
import 'package:dingdong/screens/home_screen.dart';
import 'package:dingdong/screens/reading_screen.dart';
import 'package:dingdong/screens/word_list_screen.dart';
import 'package:dingdong/store.dart';
import 'package:dingdong/theme.dart';
import 'package:dingdong/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final font = File.fromUri(
      artifacts.uri.resolve('material_fonts/roboto-regular.ttf'),
    );
    final loader = FontLoader('Roboto')
      ..addFont(font.readAsBytes().then(ByteData.sublistView));
    await loader.load();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.store = await AppStore.load();
    app.store.setName('Ariel');
    app.store.setMode(AppMode.dynasty);
  });

  Future<void> open(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  testWidgets('cinco destinos cambian la vista a 375 px sin overflow', (tester) async {
    await open(tester, const app.ZikaApp());
    expect(find.byType(DynastyShell), findsOneWidget);
    final destinations = ['Tarjetas', 'Hanziario', 'Perfil', 'Gramática', 'Lectura'];
    for (var i = 0; i < destinations.length; i++) {
      expect(find.byKey(ValueKey('dynasty-tab-$i')), findsOneWidget);
      expect(find.text(destinations[i]), findsOneWidget);
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Ariel'), findsOneWidget);
    expect(find.text('Nv 1'), findsOneWidget);

    final profileCircle = find.descendant(
      of: find.byKey(const ValueKey('dynasty-tab-2')),
      matching: find.byType(Container),
    );
    final cardCircle = find.descendant(
      of: find.byKey(const ValueKey('dynasty-tab-0')),
      matching: find.byType(Container),
    );
    expect(tester.getSize(profileCircle).width / tester.getSize(cardCircle).width, 1.3);
    expect((tester.widget<Container>(profileCircle).decoration as BoxDecoration).shape,
        BoxShape.circle);

    for (final index in [1, 2, 3, 4, 0]) {
      await tester.tap(find.byKey(ValueKey('dynasty-tab-$index')));
      await tester.pumpAndSettle();
      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, index);
      expect(find.byType(TopBar), index == 2 ? findsNothing : findsOneWidget);
      switch (index) {
        case 0:
          expect(find.byType(HomeScreen), findsOneWidget);
        case 1:
          expect(find.byType(WordListScreen), findsOneWidget);
        case 2:
        case 3:
          expect(find.text(destinations[index]), findsNWidgets(2));
        case 4:
          expect(find.byType(ReadingScreen), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('TopBar escucha nombre, nivel, XP y medalla del store', (tester) async {
    await open(tester, MaterialApp(theme: buildTheme(), home: const Scaffold(appBar: TopBar())));
    final medalFinder = find.byKey(const ValueKey('featured-medal'));
    BoxDecoration medalDecoration() =>
        tester.widget<Container>(medalFinder).decoration as BoxDecoration;
    expect(medalDecoration().shape, BoxShape.circle);
    expect(medalDecoration().color, Colors.grey);
    expect(find.descendant(of: medalFinder, matching: find.byType(Icon)), findsNothing);
    expect(tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value, 0);

    app.store.setName('abcdefghijklmnop');
    app.store.grantXp('cards', 450);
    final medal = achievements.first;
    app.store.unlockMedal(medal.id);
    app.store.setFeaturedMedal(medal.id);
    await tester.pumpAndSettle();

    final progress = progressOf(app.store.player.xp);
    expect(find.text('abcdefghijklmnop'), findsOneWidget);
    expect(progress.level, greaterThan(1));
    expect(find.text('Nv ${progress.level}'), findsOneWidget);
    expect(tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
        closeTo(progress.xpEnNivel / progress.xpNecesaria, .0001));
    expect(medalDecoration().color, medal.color);
    expect(find.byIcon(medal.icon), findsOneWidget);
    expect(tester.getCenter(medalFinder).dx, 187.5);
    expect(tester.takeException(), isNull);

    app.store.setFeaturedMedal(null);
    await tester.pumpAndSettle();
    expect(medalDecoration().color, Colors.grey);
    expect(find.descendant(of: medalFinder, matching: find.byType(Icon)), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
