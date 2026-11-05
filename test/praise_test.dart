import 'package:dingdong/game/praise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('praise is selected at the specified streak milestones', () {
    expect(praiseFor(3), const Praise(hanzi: '好', text: '¡Bien!', tier: 1));
    expect(praiseFor(5), const Praise(hanzi: '很好', text: '¡Muy bien!', tier: 2));
    expect(praiseFor(10), const Praise(hanzi: '太棒了', text: '¡Genial!', tier: 3));
    expect(praiseFor(15), const Praise(hanzi: '无敌', text: '¡Imparable!', tier: 4));
    expect(praiseFor(20), const Praise(hanzi: '天子', text: '¡Imperial!', tier: 5));
    expect(praiseFor(30), const Praise(hanzi: '天子', text: '¡Imperial!', tier: 5));
    expect(praiseFor(4), isNull);
    expect(praiseFor(0), isNull);
  });
}
