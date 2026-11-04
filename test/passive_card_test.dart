import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dingdong/widgets/passive_card.dart';

void main() {
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
