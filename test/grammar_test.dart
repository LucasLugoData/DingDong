import 'dart:math';

import 'package:dingdong/data/grammar_roles.dart';
import 'package:dingdong/game/grammar.dart';
import 'package:dingdong/game/mastery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final roles = <String, Set<Role>>{
    ...grammarRoles,
    '慢慢': {Role.manner},
  };

  void correct(List<String> tokens) {
    expect(checkSentence(tokens, roles), List.filled(tokens.length, true),
        reason: tokens.join());
  }

  test('ordena sujeto, tiempo, lugar, verbo, objeto y aspecto', () {
    correct(['我', '今天', '在', '家', '吃', '饭', '了']);
    correct(['今天', '我', '吃', '了', '饭']);
    correct(['我', '不', '会', '慢慢', '吃', '饭']);
    correct(['吃', '饭']);
    correct(['我', '吃']);
    correct(['我', '吃', '了']);
  });

  test('marca los tokens fuera de sitio sin perder los bien colocados', () {
    expect(checkSentence(['吃', '我', '饭'], roles), contains(false));
    expect(checkSentence(['我', '吃', '今天', '饭'], roles),
        [true, true, false, true]);
    expect(checkSentence(['我', '吃', 'desconocida', '饭'], roles),
        [true, true, false, true]);
    expect(checkSentence(['我', '吃', '了', '了'], roles), contains(false));
    expect(checkSentence([], roles), isEmpty);
  });

  test('comparación y predicados adjetivales', () {
    correct(['他', '比', '我', '高']);
    correct(['他', '很', '高']);
    correct(['他', '又', '高', '又', '累']);
    for (final tokens in [
      ['比', '他', '我', '高'],
      ['他', '高', '很'],
      ['他', '又', '高'],
      ['他', '又', '高', '累', '又'],
    ]) {
      expect(checkSentence(tokens, roles), contains(false));
    }
  });

  test('número y clasificador, 的 y 吗', () {
    correct(['我', '吃', '三', '个', '苹果']);
    correct(['我', '吃', '你', '的', '苹果', '吗']);
    correct(['你', '的', '苹果', '是', '我', '的', '苹果']);
    correct(['我', '吃', '那个', '苹果']);
    correct(['我', '在', '哪儿', '吃', '饭']);
    for (final tokens in [
      ['我', '吃', '个', '三', '苹果'],
      ['我', '吃', '三', '苹果'],
      ['我', '吗', '吃', '饭'],
      ['我', '吃', '苹果', '的'],
    ]) {
      expect(checkSentence(tokens, roles), contains(false));
    }
  });

  test('validez exige dos bolas distintas y una estructura completa', () {
    expect(isValidSentence(['我', '吃', '饭'], ['吃', '饭'], roles), isTrue);
    expect(isValidSentence(['吃', '饭'], ['吃', '饭'], roles), isTrue);
    expect(isValidSentence(['我', '吃'], ['吃', '饭'], roles), isFalse);
    expect(isValidSentence(['饭', '饭'], ['饭', '吃'], roles), isFalse);
    expect(isValidSentence(['今天', '饭'], ['今天', '饭'], roles), isFalse);
    expect(isValidSentence(['吃', '我', '饭'], ['吃', '饭'], roles), isFalse);
    expect(isValidSentence(['他', '比', '我', '高'], ['比', '高'], roles), isTrue);
  });

  test('puntuación aplica dominio, racha y excluye auxiliares', () {
    final tokens = ['我', '今天', '在', '家', '吃', '饭', '了'];
    final balls = ['今天', '吃', '饭', '我', '了', '吃'];
    final mastery = {'今天': Mastery.red, '吃': Mastery.blue, '饭': Mastery.gold};
    expect(scoreSentence(tokens, balls, roles, mastery), 47.5);
    expect(scoreSentence(tokens, balls, roles, mastery,
        previousValidSentences: 2), 71.25);
    expect(scoreSentence(['吃', '我', '饭'], balls, roles, mastery), 0);
    expect(scoreSentence(['我', '吃'], balls, roles, mastery), 15);
    expect(scoreSentence(['我', '吃'], ['吃'], roles, mastery), 0);
    expect(scoreSentence(['吃', '饭'], ['吃', '饭'], roles, {}), 40);
    expect(() => scoreSentence(tokens, balls, roles, mastery,
        previousValidSentences: -1), throwsArgumentError);
    expect(auxiliaryTokens, ['我', '你', '他', '是', '的', '在', '很', '不', '吗', '了']);
  });

  test('bombo reproducible, sin repetición y solo con palabras vistas', () {
    final seen = ['今天', '家', '慢慢', '吃', '饭', '三', '个', '比', '高'];
    expect(drawBalls(seen, roles, Random(19)), drawBalls(seen, roles, Random(19)));
    for (var seed = 0; seed < 80; seed++) {
      final balls = drawBalls(seen, roles, Random(seed),
          extra: seed % 4, harder: seed.isEven, rarer: seed.isOdd);
      expect(balls.length, inInclusiveRange(2, 5));
      expect(balls.toSet().length, balls.length);
      expect(balls.every(seen.contains), isTrue);
      expect(balls, contains('吃'));
    }
    expect(drawBalls(['吃', '饭'], roles, Random(1), extra: 20), hasLength(2));
    expect(drawBalls(seen, roles, Random(1), extra: 20), hasLength(5));
    expect(() => drawBalls(['饭', '家'], roles, Random(1)), throwsArgumentError);
    expect(() => drawBalls(['吃'], roles, Random(1)), throwsArgumentError);
  });

  test('bombo reserva aproximadamente el 20 % a roles poco frecuentes', () {
    final seen = ['吃', '饭', '家', '今天', '慢慢', '高', '三', '个', '比'];
    double frequency(bool rarer) {
      var rare = 0, sampled = 0;
      final random = Random(190);
      for (var i = 0; i < 1000; i++) {
        final balls = drawBalls(seen, roles, random, rarer: rarer);
        rare += balls.where({'三', '个', '比'}.contains).length;
        sampled += balls.length - 1; // El verbo garantizado no es una extracción ponderada.
      }
      return rare / sampled;
    }
    expect(frequency(false), inInclusiveRange(0.16, 0.24));
    expect(frequency(true), greaterThan(0.30));
  });
}
