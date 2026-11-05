import 'package:flutter_test/flutter_test.dart';
import 'package:dingdong/game/achievements.dart';
import 'package:dingdong/game/player.dart';
import 'package:dingdong/game/xp.dart';

void main() {
  test('block medals are ordered bronze, silver, gold', () {
    expect(blockMedals('hsk1').map((m) => m.id), ['hsk1_bronze', 'hsk1_silver', 'hsk1_gold']);
  });

  test('block seen thresholds and gold mastery', () {
    final ids = List.generate(6, (i) => 'w$i');
    final player = Player(seen: {'w0', 'w1'});
    expect(evaluate(player, {'hsk1': ids}), ['hsk1_bronze']);
    player.seen.addAll(ids);
    expect(evaluate(player, {'hsk1': ids}), ['hsk1_bronze', 'hsk1_silver']);
    player.wordStats.addAll({
      for (final id in ids) id: (hits: 10, misses: 0),
    });
    expect(evaluate(player, {'hsk1': ids}), ['hsk1_bronze', 'hsk1_silver', 'hsk1_gold']);
  });

  test('block gold requires every word green or gold', () {
    final player = Player(seen: {'a', 'b'}, wordStats: {
      'a': (hits: 10, misses: 0),
      'b': (hits: 5, misses: 0),
    });
    expect(evaluate(player, {'hsk2': ['a', 'b']}), ['hsk2_bronze', 'hsk2_silver']);
  });

  test('level medals follow player XP level', () {
    expect(evaluate(Player(xp: 0), {}), isEmpty);
    expect(evaluate(Player(xp: 400 + 566 + 693 + 800), {}), contains('level_5'));
  });

  test('solitaire achievements require win and score from a single event', () {
    expect(evaluate(Player(), {}, event: {'solitaireWin': true}), ['solitaire_win']);
    expect(evaluate(Player(), {}, event: {'solitaireScore': 99999}), isEmpty);
    expect(evaluate(Player(), {}, event: {'solitaireScore': 100000}), ['solitaire_100k']);
  });

  test('grammar streak requires ten valid phrases', () {
    expect(evaluate(Player(), {}, event: {'grammarValidStreak': 9}), isEmpty);
    expect(evaluate(Player(), {}, event: {'grammarValidStreak': 10}), ['grammar_10']);
  });

  test('perfect reading and roulette win events', () {
    expect(evaluate(Player(), {}, event: {'readingPerfect': true}), ['reading_perfect']);
    expect(evaluate(Player(), {}, event: {'rouletteWin': true}), ['roulette_win']);
  });

  test('evaluation does not repeat medals already obtained', () {
    final player = Player(medals: {'roulette_win'});
    expect(evaluate(player, {}, event: {'rouletteWin': true}), isEmpty);
  });

  test('catalog contains unique medals with presentation metadata', () {
    expect(achievements, hasLength(27));
    expect(achievements.map((medal) => medal.id).toSet(), hasLength(27));
    for (final medal in achievements) {
      expect(medal.title, isNotEmpty);
      expect(medal.description, isNotEmpty);
      expect(medal.color.a, greaterThan(0));
      expect(medal.icon.codePoint, greaterThan(0));
    }
  });

  for (final deck in ['hsk1', 'hsk2', 'hsk3', 'hsk4']) {
    test('$deck medals and exact seen thresholds', () {
      expect(blockMedals(deck).map((medal) => medal.id), [
        '${deck}_bronze', '${deck}_silver', '${deck}_gold',
      ]);
      final ids = List.generate(100, (i) => 'w$i');
      final player = Player(seen: ids.take(32).toSet());
      expect(evaluate(player, {deck: ids}), isEmpty);
      player.seen.add(ids[32]);
      expect(evaluate(player, {deck: ids}), ['${deck}_bronze']);
      player.seen.addAll(ids.take(99));
      expect(evaluate(player, {deck: ids}), ['${deck}_bronze']);
      player.seen.add(ids.last);
      expect(evaluate(player, {deck: ids}), [
        '${deck}_bronze', '${deck}_silver',
      ]);
    });

    test('$deck gold requires every word green or gold', () {
      final player = Player(wordStats: {'a': (hits: 10, misses: 0)});
      final decks = {deck: ['a', 'b']};
      expect(evaluate(player, decks), isEmpty);
      for (final hits in [0, 1, 5]) {
        player.wordStats['b'] = (hits: hits, misses: 0);
        expect(evaluate(player, decks), isEmpty);
      }
      player.wordStats['b'] = (hits: 6, misses: 0);
      expect(evaluate(player, decks), ['${deck}_gold']);
      player.wordStats['b'] = (hits: 10, misses: 0);
      expect(evaluate(player, decks), ['${deck}_gold']);
      player.wordStats['b'] = (hits: 10, misses: 5);
      expect(evaluate(player, decks), isEmpty);
    });
  }

  test('small blocks round seen thresholds up to whole words', () {
    final player = Player(seen: {'a'});
    final decks = {'hsk1': ['a', 'b', 'c', 'd']};
    expect(evaluate(player, decks), isEmpty);
    player.seen.add('b');
    expect(evaluate(player, decks), ['hsk1_bronze']);
  });

  test('empty, missing and unsupported blocks grant no medals', () {
    expect(evaluate(Player(), {}), isEmpty);
    expect(evaluate(Player(seen: {'a'}), {
      'hsk1': [], 'hsk5': ['a'],
    }), isEmpty);
  });

  test('only words belonging to each block count', () {
    final player = Player(seen: {'outside'}, wordStats: {
      'outside': (hits: 10, misses: 0),
    });
    expect(evaluate(player, {'hsk1': ['a']}), isEmpty);
    player.seen.add('a');
    expect(evaluate(player, {'hsk1': ['a'], 'hsk2': ['b']}), [
      'hsk1_bronze', 'hsk1_silver',
    ]);
  });

  for (final level in [5, 10, 20]) {
    test('level $level starts at its exact XP threshold', () {
      var threshold = 0;
      for (var previous = 1; previous < level; previous++) {
        threshold += xpToNext(previous);
      }
      final medal = 'level_$level';
      expect(evaluate(Player(xp: threshold - 1), {}), isNot(contains(medal)));
      expect(evaluate(Player(xp: threshold), {}), contains(medal));
      expect(evaluate(Player(xp: threshold + 1), {}), contains(medal));
    });
  }

  test('events require successful conditions and do not accumulate', () {
    final player = Player();
    expect(evaluate(player, {}, event: {'solitaireWin': false}), isEmpty);
    expect(evaluate(player, {}, event: {'solitaireScore': 100001}), ['solitaire_100k']);
    expect(evaluate(player, {}, event: {'solitaireScore': 60000}), isEmpty);
    expect(evaluate(player, {}, event: {'solitaireScore': 60000}), isEmpty);
    expect(evaluate(player, {}, event: {'grammarValidStreak': 11}), ['grammar_10']);
    expect(evaluate(player, {}, event: {'grammarValidStreak': 5}), isEmpty);
    expect(evaluate(player, {}, event: {'grammarValidStreak': 5}), isEmpty);
    expect(evaluate(player, {}, event: {'readingPerfect': false}), isEmpty);
    expect(evaluate(player, {}, event: {'rouletteWin': false}), isEmpty);
  });

  test('incorrectly typed events grant no medals', () {
    expect(evaluate(Player(), {}, event: {
      'solitaireWin': 'true', 'solitaireScore': '100000',
      'grammarValidStreak': '10', 'readingPerfect': 1, 'rouletteWin': 'true',
    }), isEmpty);
  });

  test('evaluation is pure and excludes all previously obtained medals', () {
    var xp = 0;
    for (var level = 1; level < 50; level++) {
      xp += xpToNext(level);
    }
    final player = Player(xp: xp, seen: {'a'}, wordStats: {
      'a': (hits: 10, misses: 0),
    });
    final decks = {
      for (final deck in ['hsk1', 'hsk2', 'hsk3', 'hsk4']) deck: ['a'],
    };
    final event = <String, Object>{
      'solitaireWin': true, 'solitaireScore': 100000,
      'grammarValidStreak': 10, 'readingPerfect': true, 'rouletteWin': true,
    };
    final before = player.toJson();
    final earned = evaluate(player, decks, event: event);
    expect(earned.toSet(), achievements.map((medal) => medal.id).toSet());
    expect(player.toJson(), before);
    expect(decks.values, everyElement(['a']));
    expect(event, {
      'solitaireWin': true, 'solitaireScore': 100000,
      'grammarValidStreak': 10, 'readingPerfect': true, 'rouletteWin': true,
    });
    expect(evaluate(player, decks, event: event), earned);
    player.medals.add('hsk1_bronze');
    expect(evaluate(player, decks, event: event),
        earned.where((id) => id != 'hsk1_bronze').toList());
    player.medals.addAll(earned);
    expect(evaluate(player, decks, event: event), isEmpty);
  });
}
