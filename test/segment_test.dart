import 'package:flutter_test/flutter_test.dart';
import 'package:dingdong/game/segment.dart';
import 'package:dingdong/models.dart';

Word word(String hanzi) => Word(
  id: hanzi,
  hanzi: hanzi,
  pinyin: 'pinyin',
  meaning: hanzi,
  deck: 'hsk1',
);

void main() {
  test('matches the longest vocabulary words first', () {
    final byHanzi = {for (final hanzi in ['我', '今天', '去', '学校']) hanzi: word(hanzi)};
    expect(segment('我今天去学校', byHanzi).map((part) => part.text), ['我', '今天', '去', '学校']);
  });

  test('keeps punctuation separate and unknown characters single', () {
    final known = word('我');
    final result = segment('我呀！', {'我': known});
    expect(result.map((part) => part.text), ['我', '呀', '！']);
    expect(result.first.word, same(known));
    expect(result[1].word, isNull);
    expect(result[1].isPunctuation, isFalse);
    expect(result.last.isPunctuation, isTrue);
  });

  test('prefers overlapping four-character words and ignores longer matches', () {
    final vocabulary = {
      for (final hanzi in ['一', '一二', '一二三', '一二三四', '一二三四五'])
        hanzi: word(hanzi),
    };
    final result = segment('一二三四五', vocabulary);
    expect(result.map((part) => part.text), ['一二三四', '五']);
    expect(result.first.word, same(vocabulary['一二三四']));
    expect(result.last.word, isNull);
  });

  test('never joins words across punctuation or whitespace', () {
    final vocabulary = {
      for (final hanzi in ['我', '你', '我，你', '我 你', '，你', '，'])
        hanzi: word(hanzi),
    };
    final result = segment('我，你 我 你', vocabulary);
    expect(result.map((part) => part.text), ['我', '，', '你', ' ', '我', ' ', '你']);
    expect(result[1].isPunctuation, isTrue);
    expect(result[1].word, isNull);
  });

  test('keeps supplementary characters intact', () {
    final known = word('𠮷野');
    final result = segment('𠮷野🙂𠀀', {'𠮷野': known});
    expect(result.map((part) => part.text), ['𠮷野', '🙂', '𠀀']);
    expect(result.first.word, same(known));
    expect(result.skip(1).every((part) => part.word == null), isTrue);
  });

  test('returns no segments for empty text', () {
    expect(segment('', {}), isEmpty);
  });
}
