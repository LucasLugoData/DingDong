import 'package:dingdong/game/achievements.dart';
import 'package:dingdong/widgets/achievement_medal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ilustración circular y tamaño configurable', (tester) async {
    final medal = achievements.first;
    for (final size in [72.0, 22.0]) {
      await tester.pumpWidget(MaterialApp(home: Center(
        child: AchievementMedal(medal: medal, unlocked: true, size: size),
      )));
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, AssetImage(medal.imageAsset));
      expect(find.ancestor(of: find.byType(Image), matching: find.byType(ClipOval)), findsOneWidget);
      expect(find.byType(ColorFiltered), findsNothing);
      expect(find.byIcon(Icons.lock), findsNothing);
      expect(tester.getSize(find.byType(AchievementMedal)), Size(size, size * 1.18));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('bloqueado atenúa la ilustración en gris y muestra candado', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Center(
      child: AchievementMedal(medal: achievements.first, unlocked: false),
    )));
    await tester.pumpAndSettle();
    expect(find.ancestor(of: find.byType(Image), matching: find.byType(ColorFiltered)), findsOneWidget);
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, lessThan(1));
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('asset ausente usa la aguada y el icono del logro', (tester) async {
    const medal = Achievement('missing_medal', 'Prueba', 'Descripción', Colors.red, Icons.star);
    await tester.pumpWidget(const MaterialApp(home: Center(
      child: AchievementMedal(medal: medal, unlocked: true),
    )));
    await tester.pumpAndSettle();
    expect(find.byIcon(medal.icon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
