import 'dart:math';

import 'package:dingdong/models.dart';
import 'package:dingdong/pinyin.dart';
import 'package:dingdong/session.dart';
import 'package:dingdong/srs.dart';
import 'package:flutter_test/flutter_test.dart';

Word w(String id, String hanzi, String pinyin) =>
    Word(id: id, hanzi: hanzi, pinyin: pinyin, meaning: id, deck: 'hsk1');

void main() {
  final now = DateTime(2026, 1, 1);

  group('pinyin', () {
    test('ordena por letras y luego por tono', () {
      final words = [w('3', '妈', 'mǎ'), w('1', '买', 'mǎi'), w('2', '妈', 'mā'), w('4', '绿', 'lǜ'), w('5', '路', 'lù')]
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
      expect(words.map((e) => e.pinyin), ['lù', 'lǜ', 'mā', 'mǎ', 'mǎi']);
    });

    test('busca sin tonos ni espacios', () {
      expect(pinyinSearchKey('běi fāng'), pinyinSearchKey('beifang'));
    });
  });

  group('srs', () {
    test('nueva acertada pasa a conocida y no sale hoy', () {
      final p = Srs.answer(CardProgress(), true, now);
      expect(p.isKnown, isTrue);
      expect(Srs.isDue(p, now), isFalse);
      expect(Srs.isDue(p, now.add(const Duration(days: 3))), isTrue);
    });

    test('fallada queda en progreso y pendiente ya', () {
      final p = Srs.answer(CardProgress(stage: 4), false, now);
      expect(p.isLearning, isTrue);
      expect(Srs.isDue(p, now), isTrue);
      expect(p.lapses, 1);
    });

    test('sin repaso de conocidas no vuelven nunca', () {
      final p = Srs.answer(CardProgress(), true, now);
      expect(Srs.isDue(p, now.add(const Duration(days: 999)), reviewKnown: false), isFalse);
    });
  });

  group('sesión', () {
    final words = [for (var i = 0; i < 10; i++) w('$i', '字$i', 'a${String.fromCharCode(97 + i)}')];

    test('fallada reaparece unas tarjetas después', () {
      final s = StudySession(words: words, tracking: true, shuffled: false);
      final first = s.current;
      s.answer(false);
      expect(s.queue.length, 11);
      expect(s.queue[1 + Srs.relearnGap], first);
    });

    test('aleatorio y vuelta al orden mantiene la tarjeta actual', () {
      final s = StudySession(words: words, tracking: false, shuffled: false, random: Random(1));
      s.next();
      s.next();
      final cur = s.current;
      s.toggleShuffle();
      expect(s.current, cur);
      s.toggleShuffle();
      expect(s.current, cur);
      expect(s.index, 2);
    });
  });
}
