import 'dart:convert';
import 'dart:io';

import 'package:dingdong/game/player.dart';
import 'package:dingdong/main.dart' as app;
import 'package:dingdong/screens/onboarding_screen.dart';
import 'package:dingdong/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Usa las métricas de Android a 375 px en lugar de la fuente cuadrada Ahem.
    // flutter_tester está en cache/artifacts/engine/<plataforma>/.
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
  });

  Future<void> openApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const app.ZikaApp());
  }

  testWidgets('elige modo libre y muestra la navegación actual a 375 px', (tester) async {
    await openApp(tester);
    expect(find.byType(Card), findsNWidgets(2));
    await tester.tap(find.text('Modo libre'));
    await tester.pumpAndSettle();

    expect(app.store.player.mode, AppMode.free);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Tarjetas'), findsOneWidget);
    expect(find.text('Palabras'), findsOneWidget);
    expect(find.text('Lectura'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dinastía requiere nombre y guarda el modo con nombre', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Empezar Modo Dinastía'));
    await tester.pumpAndSettle();
    expect(app.store.player.mode, isNull);
    expect(find.text('Escribe tu nombre'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.ensureVisible(find.text('Empezar Modo Dinastía'));
    await tester.tap(find.text('Empezar Modo Dinastía'));
    await tester.pumpAndSettle();
    expect(app.store.player.mode, isNull);

    await tester.enterText(find.byType(TextFormField), '  Ariel  ');
    await tester.ensureVisible(find.text('Empezar Modo Dinastía'));
    await tester.tap(find.text('Empezar Modo Dinastía'));
    await tester.pumpAndSettle();

    expect(app.store.player.name, 'Ariel');
    expect(app.store.player.mode, AppMode.dynasty);
    expect(find.byType(app.DynastyShell), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString('player')!) as Map<String, dynamic>;
    expect(saved['name'], 'Ariel');
    expect(saved['mode'], 'dynasty');
  });

  testWidgets('limita el nombre a 16 caracteres', (tester) async {
    await openApp(tester);
    await tester.enterText(find.byType(TextFormField), 'abcdefghijklmnopq');
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller!.text, 'abcdefghijklmnop');
    await tester.ensureVisible(find.text('Empezar Modo Dinastía'));
    await tester.tap(find.text('Empezar Modo Dinastía'));
    await tester.pumpAndSettle();
    expect(app.store.player.name, 'abcdefghijklmnop');
    expect(app.store.player.mode, AppMode.dynasty);
  });

  testWidgets('el menú libre permite elegir Dinastía sin reiniciar', (tester) async {
    app.store.setMode(AppMode.free);
    await openApp(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.byTooltip('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cambiar a Modo Dinastía'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Ariel');
    await tester.ensureVisible(find.text('Empezar Modo Dinastía'));
    await tester.tap(find.text('Empezar Modo Dinastía'));
    await tester.pumpAndSettle();
    expect(find.byType(app.DynastyShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    app.store.setMode(AppMode.free);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
