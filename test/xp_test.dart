import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:dingdong/game/xp.dart';
import 'package:dingdong/game/player.dart';
import 'package:dingdong/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('XP thresholds grow and progress starts at level one', () {
    expect(xpToNext(2), greaterThan(xpToNext(1)));
    expect(progressOf(0), (level: 1, xpEnNivel: 0, xpNecesaria: xpToNext(1)));
    expect(progressOf(xpToNext(1)).level, 2);
    var total = 0;
    for (var level = 1; level <= 50; level++) {
      final needed = xpToNext(level);
      expect(progressOf(total),
          (level: level, xpEnNivel: 0, xpNecesaria: needed));
      expect(progressOf(total + needed - 1),
          (level: level, xpEnNivel: needed - 1, xpNecesaria: needed));
      expect(xpToNext(level + 1), greaterThan(needed));
      total += needed;
    }
    expect(xpToNext(50) - xpToNext(49),
        lessThan(xpToNext(2) - xpToNext(1)));
  });

  test('typical games meet the level pacing through level 50', () {
    expect(typicalGameScore, 2000);
    final gameXp = xpFromScore(typicalGameScore);
    for (var level = 1; level <= 50; level++) {
      final games = (xpToNext(level) / gameXp).ceil();
      expect(games, lessThanOrEqualTo(8), reason: 'level $level');
      if (level <= 4) expect(games, inInclusiveRange(1, 2));
      if (level >= 15) expect(games, inInclusiveRange(3, 8));
    }
  });

  test('score XP is sublinear', () {
    expect(xpFromScore(400), lessThan(xpFromScore(100) * 3));
    expect(xpFromScore(400), greaterThan(xpFromScore(100)));
    expect(xpFromScore(0), 0);
    expect(xpFromScore(-1), 0);
    expect(xpPerProgressAnswer(true), 5);
    expect(xpPerProgressAnswer(false), 1);
  });

  test('unlock thresholds sum one third of earlier decks', () {
    expect(unlockXp('hsk1', {'hsk1': 30}), 0);
    expect(unlockXp('hsk3', {'hsk1': 10, 'hsk2': 7}), 35);
    expect(unlockXp('hsk4', {'hsk1': 10, 'hsk2': 7, 'hsk3': 1}), 40);
  });

  test('least used mode randomly chooses among tied minimum', () {
    final random = Random(1);
    final reference = Random(1);
    final selected = <String>{};
    for (var i = 0; i < 50; i++) {
      final mode = leastUsedMode({'cards': 1}, random);
      expect(mode, ['grammar', 'reading'][reference.nextInt(2)]);
      selected.add(mode);
    }
    expect(selected, {'grammar', 'reading'});
    expect(leastUsedMode({'cards': 3, 'grammar': 2, 'reading': 1}, Random(1)),
        'reading');
    expect(leastUsedMode({}, Random(1)), anyOf('cards', 'grammar', 'reading'));
  });

  test('bonus fields tolerate missing JSON and round trip', () {
    final empty = Player.fromJson({});
    expect(empty.bonusMode, isNull);
    expect(empty.lastBonusAt, isNull);
    final date = DateTime.utc(2040);
    final restored = Player.fromJson(
        Player(bonusMode: 'reading', lastBonusAt: date).toJson());
    expect(restored.bonusMode, 'reading');
    expect(restored.lastBonusAt, date);
  });

  test('selection stays stable, persists and survives another mode', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    addTearDown(store.dispose);
    store.player.gamesPlayed.addAll({'cards': 3, 'grammar': 2, 'reading': 0});
    expect(store.bonusMode, 'reading');
    expect(store.bonusMode, 'reading');
    final restored = await AppStore.load();
    addTearDown(restored.dispose);
    expect(restored.bonusMode, 'reading');
    expect(store.grantXp('cards', 10), 10);
    expect(store.bonusMode, 'reading');
    expect(store.player.lastBonusAt, isNull);
  });

  test('x2 is consumed once and becomes available exactly two hours later', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    addTearDown(store.dispose);
    var date = DateTime.utc(2040);
    final firstUse = date;
    final mode = store.bonusMode!;
    expect(store.grantXp(mode, 10, now: () => date), 20);
    expect(store.player.lastBonusAt, firstUse);
    expect(store.player.bonusMode, isNull);
    expect(store.bonusMode, isNull);
    expect(store.grantXp(mode, 10), 10);
    expect(store.player.xp, 30);
    expect(store.player.gamesPlayed[mode], 2);
    expect(store.player.lastBonusAt, firstUse);

    final restored = await AppStore.load();
    addTearDown(restored.dispose);
    expect(restored.player.lastBonusAt, firstUse);
    expect(restored.player.bonusMode, isNull);
    expect(restored.bonusMode, isNull);

    date = firstUse.add(const Duration(hours: 2) - const Duration(microseconds: 1));
    expect(store.bonusMode, isNull);
    date = firstUse.add(const Duration(hours: 2));
    final nextMode = store.bonusMode!;
    expect(nextMode, isNot(mode));
    expect(store.bonusMode, nextMode);
    expect(store.grantXp(nextMode, 10), 20);
    expect(store.player.lastBonusAt, date);
    expect(store.bonusMode, isNull);
  });

  test('solitario convierte puntos en XP con rendimientos decrecientes', () {
    expect(solitaireXpFromScore(0), 0);
    expect(solitaireXpFromScore(5400000), lessThan(1000));
    expect(solitaireXpFromScore(2000), greaterThan(solitaireXpFromScore(100)));
  });
}
