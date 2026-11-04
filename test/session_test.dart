import 'dart:math';

import 'package:dingdong/models.dart';
import 'package:dingdong/session.dart';
import 'package:flutter_test/flutter_test.dart';

Word word(int i) => Word(
  id: '$i',
  hanzi: '字$i',
  pinyin: 'a${String.fromCharCode(97 + i)}',
  meaning: '$i',
  deck: 'hsk1',
);

void main() {
  final words = [for (var i = 0; i < 10; i++) word(i)];

  test('sin tracking vuelve al ancla tras avanzar en aleatorio', () {
    final session = StudySession(
      words: words,
      tracking: false,
      shuffled: false,
      random: Random(1),
    );
    session.next();
    session.next();
    final anchor = session.current;

    session.toggleShuffle();
    for (var i = 0; i < 5; i++) {
      session.next();
    }
    session.toggleShuffle();

    expect(session.current, anchor);

    session.next();
    final nextAnchor = session.current;
    session.toggleShuffle();
    session.next();
    session.toggleShuffle();
    expect(session.current, nextAnchor);
  });

  test('con tracking vuelve a primera pendiente desde el ancla en pinyin', () {
    final session = StudySession(
      words: words,
      tracking: true,
      shuffled: false,
      random: Random(1),
    );
    session.next();
    session.next();
    final anchor = session.current!;
    final anchorKey = anchor.sortKey;
    final initialPending = session.queue.skip(session.index).toList();

    session.toggleShuffle();
    final answered = <Word>[];
    for (var i = 0; i < 3; i++) {
      answered.add(session.current!);
      session.answer(true);
    }
    session.toggleShuffle();

    final pending = session.queue.skip(session.index).toList();
    final pendingIds = pending.map((w) => w.id).toSet();
    expect(pendingIds.length, pending.length);
    final expected = initialPending.where((w) => !answered.contains(w)).toList()
      ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
    expect(pending.length, initialPending.length - answered.length);
    final expectedStart = expected.indexWhere(
      (w) => w.sortKey.compareTo(anchorKey) >= 0,
    );
    if (expectedStart > 0) {
      final rotated = [
        ...expected.sublist(expectedStart),
        ...expected.sublist(0, expectedStart),
      ];
      expected
        ..clear()
        ..addAll(rotated);
    }
    expect(pending.map((w) => w.id), orderedEquals(expected.map((w) => w.id)));
    expect(session.current!.sortKey.compareTo(anchorKey), greaterThanOrEqualTo(0));
    expect(session.current, pending.first);
  });

  test('si comienza aleatorio conserva comportamiento actual al volver', () {
    final session = StudySession(
      words: words,
      tracking: false,
      shuffled: true,
      random: Random(1),
    );
    session.next();
    final current = session.current;
    session.toggleShuffle();

    expect(session.current, current);
  });

  test('con tracking y sin respuestas conserva el ancla y pendientes', () {
    final session = StudySession(
      words: words,
      tracking: true,
      shuffled: false,
      random: Random(1),
    );
    session.answer(true);
    final anchor = session.current;
    final pending = session.queue.skip(session.index).toList();

    session.toggleShuffle();
    session.toggleShuffle();

    expect(session.current, anchor);
    expect(session.queue.skip(session.index), orderedEquals(pending));
  });

  test('con tracking un ancla fallada sigue pendiente sin duplicarse', () {
    final session = StudySession(
      words: words,
      tracking: true,
      shuffled: false,
      random: Random(1),
    );
    session.answer(true);
    final anchor = session.current;
    session.toggleShuffle();
    session.answer(false);
    final answered = session.current;
    session.answer(true);
    session.toggleShuffle();

    final expected = words.skip(1).where((w) => w != answered).toList();
    final pending = session.queue.skip(session.index).toList();
    expect(session.current, anchor);
    expect(pending, orderedEquals(expected));
    expect(pending.toSet().length, pending.length);
  });

  test('con tracking iniciado en aleatorio conserva la actual sin ancla', () {
    final session = StudySession(
      words: words,
      tracking: true,
      shuffled: true,
      random: Random(1),
    );
    session.answer(true);
    final current = session.current;
    final rest = session.queue.skip(session.index + 1).toList()
      ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
    session.toggleShuffle();

    expect(session.current, current);
    expect(session.queue.skip(session.index), orderedEquals([current, ...rest]));
  });
}
