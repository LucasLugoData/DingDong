import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dingdong/widgets/passive_card.dart';
import 'package:dingdong/game/passives.dart';

void main() {
  testWidgets('ilustración, tamaño fijo y textos largos a 375 px', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final asset in <String?>['assets/passives/abacus.png', null]) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Center(child: PassiveCard(
          hanzi: '算盘',
          name: 'Un nombre de pasiva imperial extraordinariamente largo',
          description: 'Una descripción muy larga que ocupa más de tres líneas '
              'y debe truncarse dentro del papel sin desbordar la carta imperial.',
          price: 'Un precio extraordinariamente largo',
          imageAsset: asset,
          selected: true,
        ))),
      ));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(PassiveCard)), const Size(150, 220));
      if (asset == null) {
        expect(find.byType(Image), findsNothing);
        expect(find.text('算盘'), findsOneWidget);
      } else {
        expect(tester.widget<Image>(find.byType(Image)).image, AssetImage(asset));
        expect(find.text('算\n盘'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('imagen fallida muestra aguada y hanzi', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: PassiveCard(
        hanzi: '印', name: 'Sello', description: 'Multiplica puntos.',
        imageAsset: 'assets/passives/missing.png',
      ))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('印'), findsOneWidget);
    expect(tester.getSize(find.byType(PassiveCard)), const Size(150, 220));
    expect(tester.takeException(), isNull);
  });

  testWidgets('filete de rareza distingue legendary de common', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Row(children: [
        PassiveCard(hanzi: '印', name: 'Común', description: ''),
        PassiveCard(hanzi: '山', name: 'Legendaria', description: '',
          rarity: PassiveRarity.legendary),
      ])),
    ));
    final frames = tester.widgetList<Container>(
      find.byKey(const Key('passive-rarity-frame')),
    ).map((frame) => (frame.decoration! as BoxDecoration).border! as Border).toList();
    expect(frames, hasLength(2));
    expect(frames.first.top.color, isNot(frames.last.top.color));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renderiza tres cartas a 375 px sin overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PassiveCard(hanzi: '印', name: 'Sello imperial', description: 'Multiplica puntos.', price: '8 monedas', seed: 1),
                PassiveCard(hanzi: '山', name: 'Montañas', description: 'Guarda la calma.', seed: 2),
                PassiveCard(hanzi: '竹', name: 'Bambú', description: 'Crece con cada ronda.', seed: 3),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(PassiveCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(PassiveCard).first), const Size(150, 220));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(-150, 0));
    await tester.pumpAndSettle();
    expect(find.text('Bambú').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ejecuta onTap al pulsar la carta', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PassiveCard(
            hanzi: '印',
            name: 'Sello imperial',
            description: 'Multiplica puntos.',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PassiveCard));
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
