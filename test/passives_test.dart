import 'dart:math';

import 'package:dingdong/game/passives.dart';
import 'package:dingdong/game/solitaire.dart';
import 'package:dingdong/models.dart';
import 'package:flutter_test/flutter_test.dart';

Word word({String id = 'w', String hanzi = '你', String deck = 'hsk1'}) =>
    Word(id: id, hanzi: hanzi, pinyin: 'ni', meaning: 'tú', deck: deck);

SolitaireRun game(Passive passive, {String hanzi = '你', String deck = 'hsk1'}) =>
    SolitaireRun([word(hanzi: hanzi, deck: deck)], [passive], Random(1));

void main() {
  test('Pincel añade cinco fichas al acertar', () {
    final run = game(passiveCatalog[0]);
    run.answer(true);
    expect(run.chips, 15);
  });
  test('Ábaco da una moneda extra por acierto', () {
    final run = game(passiveCatalog[1]);
    run.answer(true);
    expect(run.coins, 2);
  });
  test('Sello imperial multiplica multMult', () {
    final run = game(passiveCatalog[2]);
    run.answer(true);
    expect(run.multMult, 1.5);
  });
  test('Dragón duplica multMult desde racha diez', () {
    final run = game(passiveCatalog[3]);
    for (var i = 0; i < 10; i++) {
      run.answer(true);
    }
    expect(run.multMult, 2);
  });
  test('Muralla reduce mult a la mitad al fallar', () {
    final run = game(passiveCatalog[4]);
    for (var i = 0; i < 4; i++) {
      run.answer(true);
    }
    run.answer(false);
    expect(run.mult, 3);
  });
  test('Farol conserva la racha en el primer fallo tras tienda', () {
    final run = game(passiveCatalog[5]);
    run.answer(true);
    run.answer(true);
    (run.passives.single as Passive).onShop(run);
    run.answer(false);
    expect(run.mult, 3);
  });
  test('Té da veinte fichas en el quinto acierto consecutivo', () {
    final run = game(passiveCatalog[6]);
    for (var i = 0; i < 5; i++) {
      run.answer(true);
    }
    expect(run.chips, 30);
  });
  test('Moneda de cobre añade mult a partir de cinco monedas guardadas', () {
    final run = game(passiveCatalog[7]);
    run.coins = 10;
    run.answer(true);
    expect(run.mult, 4);
  });
  test('Tablilla añade dos mult al llegar a racha cinco', () {
    final run = game(passiveCatalog[8]);
    for (var i = 0; i < 5; i++) {
      run.answer(true);
    }
    expect(run.mult, 8);
  });
  test('Jade conserva aumento de multMult por racha de diez', () {
    final run = game(passiveCatalog[9]);
    for (var i = 0; i < 10; i++) {
      run.answer(true);
    }
    expect(run.multMult, 1.1);
  });
  test('Anales añade fichas en HSK3', () {
    final run = game(passiveCatalog[10], deck: 'hsk3');
    run.answer(true);
    expect(run.chips, 18);
  });
  test('Mercader rebaja el precio de tienda', () {
    final run = SolitaireRun([word()], [passiveCatalog[11]], Random(1));
    expect(run.priceOf(passiveCatalog.first), 3);
  });
  test('Confucio añade fichas con dos caracteres', () {
    final run = game(passiveCatalog[12], hanzi: '你好');
    run.answer(true);
    expect(run.chips, 25);
  });
  test('Fénix da monedas al romper racha cinco', () {
    final run = game(passiveCatalog[13]);
    for (var i = 0; i < 5; i++) {
      run.answer(true);
    }
    run.answer(false);
    expect(run.coins, 8);
  });
  test('tienda pondera rareza, excluye posesiones y no repite', () {
    final offered = rollShop(Random(3), [passiveCatalog.first]);
    expect(offered, hasLength(3));
    expect(offered.map((p) => p.id).toSet(), hasLength(3));
    expect(offered.any((p) => p.id == 'brush'), isFalse);
  });
  test('opciones de gramática son dos combinaciones válidas', () {
    final choices = rollGrammarChoice(Random(3));
    expect(choices, hasLength(2));
    expect(choices.every((c) => GrammarPerk.positives.contains(c.positive)), isTrue);
    expect(choices.every((c) => GrammarPerk.negatives.contains(c.negative)), isTrue);
  });
}
