import 'dart:math';

import 'models.dart';
import 'srs.dart';

/// Cola de tarjetas de una sesión de estudio.
///
/// Con [tracking] solo entran las pendientes y las falladas reaparecen pocas
/// tarjetas después; sin él se recorre el mazo entero libremente.
class StudySession {
  StudySession({
    required List<Word> words,
    required this.tracking,
    required this.shuffled,
    Random? random,
  }) : _random = random ?? Random(),
       queue = List.of(words) {
    _order(queue);
  }

  final bool tracking;
  final Random _random;
  final List<Word> queue;
  bool shuffled;
  int index = 0;
  int knownCount = 0;
  int learningCount = 0;

  bool get isDone => index >= queue.length;
  Word? get current => isDone ? null : queue[index];

  void _order(List<Word> list) {
    if (shuffled) {
      list.shuffle(_random);
    } else {
      list.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    }
  }

  /// Aleatorio ↔ orden alfabético, manteniendo la tarjeta actual a la vista.
  void toggleShuffle() {
    shuffled = !shuffled;
    final cur = current;
    if (tracking) {
      final rest = queue.sublist(index);
      _order(rest);
      if (cur != null) {
        rest.remove(cur);
        rest.insert(0, cur);
      }
      queue.replaceRange(index, queue.length, rest);
    } else {
      _order(queue);
      index = cur == null ? 0 : queue.indexOf(cur);
    }
  }

  void next() {
    if (index < queue.length - 1) index++;
  }

  void previous() {
    if (index > 0) index--;
  }

  /// Registra la respuesta en la cola (el progreso lo guarda el store).
  void answer(bool correct) {
    final w = current;
    if (w == null) return;
    if (correct) {
      knownCount++;
    } else {
      learningCount++;
      final at = min(index + 1 + Srs.relearnGap, queue.length);
      queue.insert(at, w);
    }
    index++;
  }
}
