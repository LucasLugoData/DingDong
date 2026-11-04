import 'package:dingdong/game/fusion.dart';
import 'package:dingdong/models.dart';
import 'package:flutter_test/flutter_test.dart';

Word word(String hanzi, String pinyin, String meaning) => Word(
  id: hanzi,
  hanzi: hanzi,
  pinyin: pinyin,
  meaning: meaning,
  deck: 'test',
);

void main() {
  final vocab = [
    word('大', 'dà', 'grande'),
    word('学', 'xué', 'estudiar'),
    word('小', 'xiǎo', 'pequeño'),
    word('大学', 'dàxué', 'universidad'),
    word('大小', 'dàxiǎo', 'tamaño'),
    word('学生', 'xuéshēng', 'estudiante'),
    word('生', 'shēng', 'nacer'),
    word('你好', 'nǐhǎo', 'hola'),
  ];

  test('encuentra fusiones solo cuando ambas partes están en vocabulario', () {
    final result = fusions(vocab);
    expect(result.map((fusion) => fusion.word.hanzi), ['大学', '大小', '学生']);
    expect(result.first.parts.map((part) => part.hanzi), ['大', '学']);
  });

  test('fusionsOf filtra por carácter básico', () {
    expect(fusionsOf('大', vocab).map((fusion) => fusion.word.hanzi), ['大学', '大小']);
    expect(fusionsOf('生', vocab).map((fusion) => fusion.word.hanzi), ['学生']);
    expect(fusionsOf('你', vocab), isEmpty);
    expect(fusionsOf('大学', vocab), isEmpty);
  });

  test('excluye palabras con menos de dos componentes conocidos', () {
    final withoutSmall = vocab.where((entry) => entry.hanzi != '小').toList();
    expect(fusions(withoutSmall).map((fusion) => fusion.word.hanzi), [
      '大学', '学生',
    ]);
    expect(fusions([]), isEmpty);
    expect(fusions([vocab.first]), isEmpty);
  });

  test('conserva el orden y las repeticiones en palabras largas', () {
    final result = fusions([
      ...vocab,
      word('大学生', 'dàxuéshēng', 'estudiante universitario'),
      word('大大小小', 'dàdàxiǎoxiǎo', 'de todos los tamaños'),
      word('大学校', 'dàxuéxiào', 'gran escuela'),
    ]);
    expect(result[result.length - 3].parts, [vocab[0], vocab[1], vocab[6]]);
    expect(result[result.length - 2].parts.map((part) => part.hanzi), [
      '大', '大', '小', '小',
    ]);
    expect(result.last.parts.map((part) => part.hanzi), ['大', '学']);
  });

  test('cuenta caracteres Unicode completos y conserva sus datos', () {
    final basic = word('𠮷', 'jí', 'buena fortuna');
    final compound = word('𠮷大', 'jídà', 'ejemplo');
    final result = fusions([basic, vocab.first, compound]);
    expect(result.single.word, same(compound));
    expect(result.single.parts, [basic, vocab.first]);
    expect(fusionsOf('𠮷', [basic, vocab.first, compound]).single.word,
        same(compound));
  });
}
