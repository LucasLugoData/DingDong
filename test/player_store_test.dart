import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dingdong/game/player.dart';
import 'package:dingdong/store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('legacy preferences survive loading without a player', () async {
    SharedPreferences.setMockInitialValues({
      'progress': jsonEncode({}),
      'notes': jsonEncode({'word': 'nota'}),
      'favorites': ['word'],
      'custom': jsonEncode([
        {'id': 'mine', 'hanzi': '字', 'pinyin': 'zì', 'meaning': 'letra', 'deck': 'custom'},
      ]),
      'reviewKnown': false,
    });
    final store = await AppStore.load();
    expect(store.player.mode, isNull);
    expect(store.noteOf('word'), 'nota');
    expect(store.isFavorite('word'), isTrue);
    expect(store.allWords.any((word) => word.id == 'mine'), isTrue);
    expect(store.reviewKnown, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('progress'), isNotNull);
    expect(prefs.getString('notes'), isNotNull);
    expect(prefs.getStringList('favorites'), ['word']);
    expect(prefs.getString('custom'), isNotNull);
    expect(prefs.getBool('reviewKnown'), false);
  });

  test('player mutations persist and reload', () async {
    SharedPreferences.setMockInitialValues({});
    var store = await AppStore.load();
    store.recordAnswer('a', true, see: true);
    store.recordAnswer('a', false);
    store.recordAnswer('c', true);
    store.markSeen('b');
    store.setName('Ariel');
    store.setMode(AppMode.dynasty);
    store.unlockMedal('first');
    store.setFeaturedMedal('first');
    store.grantXp('cards', 15);
    store = await AppStore.load();
    expect(store.player.name, 'Ariel');
    expect(store.player.mode, AppMode.dynasty);
    expect(store.player.xp, 15);
    expect(store.player.gamesPlayed['cards'], 1);
    expect(store.player.seen, containsAll(['a', 'b']));
    expect(store.player.seen, isNot(contains('c')));
    expect(store.player.wordStats['a'], (hits: 1, misses: 1));
    expect(store.player.medals, contains('first'));
    expect(store.player.featuredMedal, 'first');
  });

  test('reset account removes player and progress only', () async {
    SharedPreferences.setMockInitialValues({
      'progress': jsonEncode({'x': {'s': 1, 'd': null, 'l': 0}}),
      'notes': jsonEncode({'x': 'keep'}),
      'favorites': ['x'],
      'custom': jsonEncode([
        {'id': 'mine', 'hanzi': '字', 'pinyin': 'zì', 'meaning': 'letra', 'deck': 'custom'},
      ]),
    });
    final store = await AppStore.load();
    store.setName('Ariel');
    store.resetAccount();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('player'), isNull);
    expect(prefs.getString('progress'), isNull);
    expect(store.noteOf('x'), 'keep');
    expect(store.isFavorite('x'), isTrue);
    expect(store.allWords.any((word) => word.id == 'mine'), isTrue);
  });

  test('player JSON tolerates missing fields', () {
    final player = Player.fromJson({'xp': 12});
    expect(player.xp, 12);
    expect(player.mode, isNull);
    expect(player.seen, isEmpty);
    expect(player.gamesPlayed, isEmpty);
  });
}
