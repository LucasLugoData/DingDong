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
  Word? _pinyinAnchor;

  bool get isDone => index >= queue.length;
  Word? get current => isDone ? null : queue[index];

  void _order(List<Word> list) {
    if (shuffled) {
      list.shuffle(_random);
    } else {
      list.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    }
  }

  /// Al volver a pinyin, retoma el ancla o la siguiente pendiente.
  void toggleShuffle() {
    if (!shuffled) {
      _pinyinAnchor = current;
    }
    shuffled = !shuffled;
    final cur = current;
    if (tracking) {
      final rest = queue.sublist(index);
      _order(rest);
      if (shuffled || _pinyinAnchor == null) {
        if (cur != null) {
          rest.remove(cur);
          rest.insert(0, cur);
        }
      } else {
        final anchorKey = _pinyinAnchor!.sortKey;
        final anchorIndex = rest.indexWhere(
          (word) => word.sortKey.compareTo(anchorKey) >= 0,
        );
        if (anchorIndex > 0) {
          final ordered = [
            ...rest.sublist(anchorIndex),
            ...rest.sublist(0, anchorIndex),
          ];
          rest
            ..clear()
            ..addAll(ordered);
        }
      }
      queue.replaceRange(index, queue.length, rest);
    } else {
      _order(queue);
      final target = shuffled ? cur : (_pinyinAnchor ?? cur);
      index = target == null ? 0 : queue.indexOf(target);
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
