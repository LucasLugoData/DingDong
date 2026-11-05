import 'package:flutter/material.dart';
import 'package:dingdong/game/mastery.dart';
import 'package:dingdong/game/player.dart';
import 'package:dingdong/game/xp.dart';
import 'package:dingdong/theme.dart';

class Achievement {
  const Achievement(this.id, this.title, this.description, this.color, this.icon);

  final String id;
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  String get imageAsset {
    final block = RegExp(r'^hsk\d+_(bronze|silver|gold)$').firstMatch(id);
    final name = block == null ? id : 'block_${block.group(1)}';
    return 'assets/achievements/$name.png';
  }
}

Achievement _blockMedal(String deckId, String rank, String title, String description,
    Color color, IconData icon) =>
    Achievement('${deckId}_$rank', '$title $deckId', description, color, icon);

List<Achievement> blockMedals(String deckId) => [
  _blockMedal(deckId, 'bronze', 'Bronce', 'Has visto al menos el 33% del bloque.', AppColors.bronze, Icons.workspace_premium),
  _blockMedal(deckId, 'silver', 'Plata', 'Has visto todas las palabras del bloque.', AppColors.silver, Icons.workspace_premium),
  _blockMedal(deckId, 'gold', 'Oro', 'Has dominado todas las palabras del bloque.', AppColors.gold, Icons.workspace_premium),
];

Achievement _level(int level, String title, Color color) => Achievement(
  'level_$level', title, 'Alcanza el nivel $level.', color, Icons.trending_up);

final _levelAchievements = [
  _level(2, 'Primer trazo', AppColors.bronze),
  _level(3, 'Aprendiz de escriba', AppColors.bronze),
  _level(5, 'Nivel 5', AppColors.blue),
  _level(10, 'Nivel 10', AppColors.green),
  _level(15, 'Letrado', AppColors.silver),
  _level(20, 'Nivel 20', AppColors.gold),
  _level(25, 'Mandarín', AppColors.lilac),
  _level(30, 'Gran secretario', AppColors.orange),
  _level(40, 'Consejero imperial', AppColors.red),
  _level(50, 'Hijo del Cielo', AppColors.seal),
];

const _eventAchievements = [
  Achievement('solitaire_win', 'Victoria solitaria', 'Supera una demostración de solitario.', AppColors.lilac, Icons.emoji_events),
  Achievement('solitaire_100k', 'Centenario', 'Consigue 100000 puntos en una partida de solitario.', AppColors.gold, Icons.military_tech),
  Achievement('grammar_10', 'Frase tras frase', 'Valida 10 frases seguidas.', AppColors.blue, Icons.spellcheck),
  Achievement('reading_perfect', 'Lectura perfecta', 'Completa ejercicios de lectura sin fallos.', AppColors.green, Icons.menu_book),
  Achievement('roulette_win', 'Apuesta ganadora', 'Gana una partida de ruleta.', AppColors.orange, Icons.casino),
];

/// Presentation metadata for every available medal.
final List<Achievement> achievements = List.unmodifiable([
  for (final deckId in const ['hsk1', 'hsk2', 'hsk3', 'hsk4'])
    ...blockMedals(deckId),
  ..._levelAchievements,
  ..._eventAchievements,
]);

/// Returns achievement IDs earned now, excluding medals already recorded by [player].
/// Events describe a single game: solitaireWin, solitaireScore,
/// grammarValidStreak, readingPerfect and rouletteWin.
List<String> evaluate(
  Player player,
  Map<String, List<String>> deckWordIds, {
  Map<String, Object> event = const {},
}) {
  final earned = <String>[];
  for (final deckId in const ['hsk1', 'hsk2', 'hsk3', 'hsk4']) {
    final ids = deckWordIds[deckId] ?? const <String>[];
    if (ids.isEmpty) continue;
    final seenCount = ids.where(player.seen.contains).length;
    final masteredCount = ids.where((id) {
      final stats = player.wordStats[id];
      if (stats == null) return false;
      final mastery = masteryOf(stats.hits, stats.misses);
      return mastery == Mastery.green || mastery == Mastery.gold;
    }).length;
    if (seenCount * 100 >= ids.length * 33) earned.add('${deckId}_bronze');
    if (seenCount == ids.length) earned.add('${deckId}_silver');
    if (masteredCount == ids.length) earned.add('${deckId}_gold');
  }

  final level = progressOf(player.xp).level;
  for (final achievement in _levelAchievements) {
    final requiredLevel = int.parse(achievement.id.substring('level_'.length));
    if (level >= requiredLevel) earned.add(achievement.id);
  }
  if (event['solitaireWin'] == true) earned.add('solitaire_win');
  if (event['solitaireScore'] is num && (event['solitaireScore'] as num) >= 100000) {
    earned.add('solitaire_100k');
  }
  if (event['grammarValidStreak'] is num && (event['grammarValidStreak'] as num) >= 10) {
    earned.add('grammar_10');
  }
  if (event['readingPerfect'] == true) earned.add('reading_perfect');
  if (event['rouletteWin'] == true) earned.add('roulette_win');

  return earned.toSet().difference(player.medals).toList();
}
