import 'dart:math';

import '../models.dart';

/// Contrato para el catálogo de pasivas. Los hooks modifican el estado del run.
abstract class PassiveHooks {
  const PassiveHooks();

  int get price;

  /// Se ejecuta antes de sumar puntos y monedas y de incrementar la racha.
  void onCorrect(SolitaireRun run) {}

  /// Se ejecuta después de restablecer la racha a uno.
  void onWrong(SolitaireRun run) {}

  void onShop(SolitaireRun run) {}

  int priceModifier(int price) => price;
}

class ScoreEvent {
  const ScoreEvent({
    required this.correct,
    required this.chips,
    required this.mult,
    required this.multMult,
    required this.gain,
    required this.streak,
    required this.triggered,
  });

  final bool correct;
  final int chips;
  final int mult;
  final double multMult;
  final double gain;
  final int streak;
  final List<int> triggered;
}

/// Pasivas que se pueden tener a la vez en una partida.
const maxPassives = 10;

class SolitaireRun {
  /// [words] contiene únicamente las palabras vistas por el jugador.
  SolitaireRun(
    List<Word> words,
    List<PassiveHooks> passives,
    Random random,
  ) : _passives = List.of(passives) {
    if (words.isEmpty) {
      throw ArgumentError.value(words, 'words', 'Debe haber palabras vistas');
    }
    if (passives.length > maxPassives) {
      throw ArgumentError.value(passives, 'passives', 'Máximo $maxPassives pasivas');
    }
    final cards = <Word>[];
    while (cards.length < 100) {
      final batch = List.of(words)..shuffle(random);
      cards.addAll(batch.take(100 - cards.length));
    }
    queue = List.unmodifiable(cards);
  }

  late final List<Word> queue;
  final List<PassiveHooks> _passives;
  final Set<String> _knownThisRun = {};
  int _index = 0;
  double? _finalScore;
  int _streak = 0;
  ScoreEvent? lastEvent;

  int chips = 10;
  int mult = 1;
  double multMult = 1.0;
  double score = 0;
  int coins = 0;
  int coinsPerCorrect = 1;

  int get index => _index;
  bool get isDone => _index == queue.length;
  Word? get current => isDone ? null : queue[_index];
  bool get isShopTime => !isDone && _index > 0 && _index % 20 == 0;
  List<PassiveHooks> get passives => List.unmodifiable(_passives);
  Set<String> get knownThisRun => Set.unmodifiable(_knownThisRun);
  double? get finalScore => _finalScore;

  void answer(bool correct) {
    final word = current;
    if (word == null) return;
    final triggered = <int>[];
    if (correct) {
      _knownThisRun.add(word.id);
      for (var i = 0; i < _passives.length; i++) {
        final passive = _passives[i];
        final before = (chips, mult, multMult, coins, coinsPerCorrect);
        passive.onCorrect(this);
        if (before != (chips, mult, multMult, coins, coinsPerCorrect)) {
          triggered.add(i);
        }
      }
      final eventChips = chips;
      final eventMult = mult;
      final eventMultMult = multMult;
      final gain = eventChips * eventMult * eventMultMult;
      score += gain;
      coins += coinsPerCorrect;
      mult++;
      _streak++;
      lastEvent = ScoreEvent(correct: true, chips: eventChips, mult: eventMult,
          multMult: eventMultMult, gain: gain, streak: _streak,
          triggered: List.unmodifiable(triggered));
    } else {
      mult = 1;
      for (var i = 0; i < _passives.length; i++) {
        final passive = _passives[i];
        final before = (chips, mult, multMult, coins, coinsPerCorrect);
        passive.onWrong(this);
        if (before != (chips, mult, multMult, coins, coinsPerCorrect)) {
          triggered.add(i);
        }
      }
      _streak = 0;
      lastEvent = ScoreEvent(correct: false, chips: chips, mult: mult,
          multMult: multMult, gain: 0, streak: 0,
          triggered: List.unmodifiable(triggered));
    }
    _index++;
    if (isShopTime) {
      for (final passive in _passives) {
        passive.onShop(this);
      }
    }
  }

  int priceOf(PassiveHooks passive) {
    var price = passive.price;
    for (final owned in _passives) {
      price = owned.priceModifier(price);
    }
    return max(0, price);
  }

  bool buy(PassiveHooks passive) {
    if (!isShopTime || _passives.length >= maxPassives) return false;
    final price = priceOf(passive);
    if (coins < price) return false;
    coins -= price;
    _passives.add(passive);
    return true;
  }

  List<Word> demoWords(Random random) {
    final byId = <String, Word>{
      for (final word in queue)
        if (_knownThisRun.contains(word.id)) word.id: word,
    };
    final words = byId.values.toList()..shuffle(random);
    return words.take(10).toList();
  }

  void finishDemo(bool allCorrect) {
    if (!isDone) throw StateError('La partida aún no ha terminado');
    _finalScore ??= allCorrect && _knownThisRun.length >= 3 ? score : 0.0;
  }
}
