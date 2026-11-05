import 'package:dingdong/game/achievements.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('block medals share an image for each rank across decks', () {
    for (final deck in ['hsk1', 'hsk2', 'hsk3', 'hsk4']) {
      expect(blockMedals(deck).map((medal) => medal.imageAsset), [
        'assets/achievements/block_bronze.png',
        'assets/achievements/block_silver.png',
        'assets/achievements/block_gold.png',
      ]);
    }
    for (final medal in achievements.where((medal) => !medal.id.startsWith('hsk'))) {
      expect(medal.imageAsset, 'assets/achievements/${medal.id}.png');
    }
    expect(achievements.map((medal) => medal.imageAsset).toSet(), hasLength(18));
  });

  for (final medal in achievements) {
    test('${medal.id} bundles a square 384px PNG within 150 KB', () async {
      final data = await rootBundle.load(medal.imageAsset);
      expect(data.lengthInBytes, lessThanOrEqualTo(150 * 1024));
      expect(data.lengthInBytes, greaterThanOrEqualTo(24));
      expect(data.buffer.asUint8List(data.offsetInBytes, 8),
          [137, 80, 78, 71, 13, 10, 26, 10]);
      expect(data.getUint32(16), 384);
      expect(data.getUint32(20), 384);
    });
  }
}
