import 'dart:math';

import 'package:dingdong/game/solitaire.dart';
import 'package:dingdong/models.dart';
import 'package:flutter_test/flutter_test.dart';

List<Word> words(int count) => [
  for (var i = 0; i < count; i++)
    Word(id: '$i', hanzi: '$i', pinyin: 'ma', meaning: '$i', deck: 'hsk1'),
];

SolitaireRun run({int count = 10, List<PassiveHooks> passives = const []}) =>
    SolitaireRun(words(count), passives, Random(1));

void complete(SolitaireRun game) {
  while (!game.isDone) {
    game.answer(true);
  }
}

class TestPassive extends PassiveHooks {
  TestPassive({this.price = 5, this.discount = 0, this.boost = false});

  @override
  final int price;
  final int discount;
  final bool boost;
  int shops = 0;
  int wrongs = 0;

  @override
  void onCorrect(SolitaireRun run) {
    if (boost) {
      run.chips = 20;
      run.multMult = 1.5;
      run.coinsPerCorrect = 2;
    }
  }

  @override
  void onWrong(SolitaireRun run) {
    expect(run.mult, 1);
    wrongs++;
  }

  @override
  void onShop(SolitaireRun run) => shops++;

  @override
  int priceModifier(int price) => price - discount;
}

void main() {
  test('100 cards repeat shuffled batches without changing the input', () {
    final source = words(7);
    final game = SolitaireRun(source, [], Random(1));
    expect(game.queue, hasLength(100));
    expect(source.map((word) => word.id), List.generate(7, (i) => '$i'));
    for (var offset = 0; offset < 98; offset += 7) {
      expect(game.queue.skip(offset).take(7), unorderedEquals(source));
    }
    expect(game.queue.take(7).map((word) => word.id),
        isNot(orderedEquals(source.map((word) => word.id))));
    expect(game.queue, orderedEquals(SolitaireRun(source, [], Random(1)).queue));
  });

  test('larger pools provide 100 distinct cards; empty pools are rejected', () {
    final game = run(count: 130);
    expect(game.queue, hasLength(100));
    expect(game.queue.map((word) => word.id).toSet(), hasLength(100));
    expect(() => run(count: 0), throwsArgumentError);
  });

  test('successive answers score 10 + 20 + 30 and award coins', () {
    final game = run();
    expect(game.multMult, 1.0);
    game.answer(true);
    expect(game.score, 10);
    game.answer(true);
    expect(game.score, 30);
    game.answer(true);
    expect(game.score, 60);
    expect(game.mult, 4);
    expect(game.coins, 3);
  });

  test('wrong answer resets streak without points or coins', () {
    final passive = TestPassive();
    final game = run(passives: [passive]);
    game.answer(true);
    game.answer(true);
    game.answer(false);
    expect(game.mult, 1);
    expect(game.score, 30);
    expect(game.coins, 2);
    expect(passive.wrongs, 1);
    game.answer(true);
    expect(game.score, 40);
  });

  test('shops occur only after cards 20, 40, 60 and 80', () {
    final passive = TestPassive();
    final game = run(passives: [passive]);
    final stops = <int>[];
    expect(game.isShopTime, isFalse);
    for (var i = 1; i <= 100; i++) {
      game.answer(true);
      if (game.isShopTime) stops.add(i);
    }
    expect(stops, [20, 40, 60, 80]);
    expect(passive.shops, 4);
    expect(game.current, isNull);
    final score = game.score;
    game.answer(true);
    expect(game.index, 100);
    expect(game.score, score);
  });

  test('passive hooks modify chips, multiplier and coin income', () {
    final game = run(passives: [TestPassive(boost: true)]);
    game.answer(true);
    expect(game.score, 30);
    expect(game.coins, 2);
    expect(game.mult, 2);
  });

  test('buy requires shop, funds and a free slot; prices use owned hooks', () {
    final discount = TestPassive(discount: 2);
    final initial = <PassiveHooks>[discount];
    final game = SolitaireRun(words(10), initial, Random(1));
    initial.clear();
    expect(game.passives, hasLength(1));
    expect(game.buy(TestPassive()), isFalse);
    for (var i = 0; i < 20; i++) {
      game.answer(true);
    }
    expect(game.buy(TestPassive(price: 30)), isFalse);
    expect(game.coins, 20);
    expect(game.buy(TestPassive(price: 10)), isTrue);
    expect(game.coins, 12);
    for (var i = 0; i < 3; i++) {
      expect(game.buy(TestPassive(price: 0)), isTrue);
    }
    expect(game.coins, 12);
    expect(game.passives, hasLength(5));
    expect(game.buy(TestPassive(price: 0)), isFalse);
    expect(() => run(passives: List.generate(6, (_) => TestPassive())),
        throwsArgumentError);
  });

  test('demo samples at most ten distinct correct ids, excluding misses', () {
    final game = run(count: 100);
    final missed = game.current!.id;
    game.answer(false);
    final correct = <String>{};
    for (var i = 0; i < 15; i++) {
      correct.add(game.current!.id);
      game.answer(true);
    }
    expect(game.knownThisRun, correct);
    final demo = game.demoWords(Random(1));
    expect(demo, hasLength(10));
    expect(demo.map((word) => word.id).toSet(), hasLength(10));
    expect(demo.every((word) => correct.contains(word.id)), isTrue);
    expect(demo.any((word) => word.id == missed), isFalse);
  });

  test('demo uses all known words when fewer than ten, without duplicates', () {
    final game = run(count: 4);
    complete(game);
    expect(game.knownThisRun, hasLength(4));
    expect(game.demoWords(Random(1)).map((word) => word.id).toSet(),
        game.knownThisRun);
    expect(game.demoWords(Random(1)), hasLength(4));
  });

  test('failed demo yields zero and cannot be retried to restore score', () {
    final game = run();
    expect(game.finalScore, isNull);
    expect(() => game.finishDemo(true), throwsStateError);
    complete(game);
    expect(game.score, greaterThan(0));
    game.finishDemo(false);
    expect(game.finalScore, 0);
    game.finishDemo(true);
    expect(game.finalScore, 0);
  });

  test('fewer than three known ids fail even when allCorrect is true', () {
    for (var count = 1; count <= 2; count++) {
      final game = run(count: count);
      complete(game);
      expect(game.demoWords(Random(1)), hasLength(count));
      game.finishDemo(true);
      expect(game.finalScore, 0);
    }
    final game = run();
    while (!game.isDone) {
      game.answer(false);
    }
    expect(game.demoWords(Random(1)), isEmpty);
    game.finishDemo(true);
    expect(game.finalScore, 0);
  });

  test('successful demo preserves score with at least three known ids', () {
    final game = run(count: 3);
    complete(game);
    game.finishDemo(true);
    expect(game.finalScore, game.score);
  });
}
