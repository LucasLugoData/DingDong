import 'package:flutter/painting.dart';
import 'package:dingdong/theme.dart';

enum Mastery { red, orange, blue, green, gold }

extension MasteryPresentation on Mastery {
  Color get color => switch (this) {
    Mastery.red => AppColors.red,
    Mastery.orange => AppColors.orange,
    Mastery.blue => AppColors.blue,
    Mastery.green => AppColors.green,
    Mastery.gold => AppColors.gold,
  };

  String get label => switch (this) {
    Mastery.red => 'Sin dominar',
    Mastery.orange => 'Floja',
    Mastery.blue => 'En progreso',
    Mastery.green => 'Conocida',
    Mastery.gold => 'Consolidada',
  };
}

Mastery masteryOf(int hits, int misses) {
  final net = hits - misses;
  if (hits == 0 || net < 1) return Mastery.red;
  if (net <= 2) return Mastery.orange;
  if (net <= 5) return Mastery.blue;
  if (net <= 9) return Mastery.green;
  return hits * 100 >= (hits + misses) * 85
      ? Mastery.gold
      : Mastery.green;
}

/// Avance de 0 (sin dominar) a 1 (consolidada) para la barra del Hanziario.
double masteryProgress(int hits, int misses) {
  if (masteryOf(hits, misses) == Mastery.gold) return 1;
  final net = (hits - misses).clamp(0, 10);
  return hits == 0 ? 0 : (0.08 + net / 10 * 0.84).clamp(0.08, 0.92);
}

double difficultyMult(Mastery mastery) => switch (mastery) {
  Mastery.red => 2.0,
  Mastery.orange || Mastery.blue => 1.5,
  Mastery.green || Mastery.gold => 1.25,
};
