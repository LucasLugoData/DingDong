import 'package:dingdong/dynasty/dynasty_shell.dart';
import 'package:dingdong/game/achievements.dart';
import 'package:dingdong/game/player.dart';
import 'package:dingdong/main.dart' as app;
import 'package:dingdong/store.dart';
import 'package:dingdong/widgets/achievement_medal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.store = await AppStore.load();
    app.store.setName('Ariel');
    app.store.setMode(AppMode.dynasty);
  });

  Future<void> openProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: DynastyShell()));
    await tester.tap(find.byKey(const ValueKey('dynasty-tab-2')));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el perfil y permite destacar una medalla', (tester) async {
    final medal = achievements.first;
    app.store.unlockMedal(medal.id);
    await openProfile(tester);

    expect(find.text('Ariel'), findsOneWidget);
    expect(find.textContaining('faltan '), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('profile-achievements')));
    await tester.pumpAndSettle();
    expect(find.text('Logros'), findsOneWidget);
    await tester.tap(find.text(medal.title));
    await tester.pumpAndSettle();
    expect(app.store.player.featuredMedal, medal.id);
    expect(find.text('装备'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('equip-${medal.id}')));
    await tester.pumpAndSettle();
    expect(app.store.player.featuredMedal, isNull);
    expect(find.text('装备'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vitrina de tres columnas recorre todos los logros a 375 px', (tester) async {
    for (final medal in achievements.take(4)) {
      app.store.unlockMedal(medal.id);
    }
    await openProfile(tester);
    final preview = find.descendant(
      of: find.byKey(const ValueKey('profile-achievements')),
      matching: find.byType(AchievementMedal),
    );
    expect(preview, findsNWidgets(3));
    expect(tester.widgetList<AchievementMedal>(preview).every((medal) => medal.size == 22), isTrue);
    await tester.tap(find.byKey(const ValueKey('profile-achievements')));
    await tester.pumpAndSettle();
    expect(find.text('4 / ${achievements.length}'), findsOneWidget);
    final grid = tester.widget<GridView>(find.byType(GridView));
    expect((grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 3);
    for (final medal in achievements) {
      await tester.scrollUntilVisible(find.text(medal.title), 100,
        scrollable: find.descendant(of: find.byType(GridView), matching: find.byType(Scrollable)));
      expect(find.text(medal.title), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    final locked = achievements.last;
    await tester.tap(find.text(locked.title));
    await tester.pumpAndSettle();
    expect(find.text(locked.description), findsOneWidget);
    expect(app.store.player.featuredMedal, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reiniciar cuenta exige confirmación', (tester) async {
    await openProfile(tester);
    await tester.tap(find.text('Reiniciar cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Se borrará tu progreso y volverás a la bienvenida. ¿Continuar?'), findsOneWidget);
    expect(app.store.player.mode, AppMode.dynasty);
  });
}
