import 'dart:math';

// 20 streaks of four correct answers followed by one miss: 80/100 correct.
// Each streak scores 10 * (1 + 2 + 3 + 4), without passives.
const int typicalGameScore = 20 * 10 * (1 + 2 + 3 + 4);

int xpToNext(int level) {
  if (level < 1) throw ArgumentError.value(level, 'level');
  return (400 * sqrt(level)).round();
}

({int level, int xpEnNivel, int xpNecesaria}) progressOf(int totalXp) {
  var remaining = max(0, totalXp);
  var level = 1;
  while (remaining >= xpToNext(level)) {
    remaining -= xpToNext(level);
    level++;
  }
  return (level: level, xpEnNivel: remaining, xpNecesaria: xpToNext(level));
}

int xpFromScore(int score) => (sqrt(max(0, score)) * 12).round();

int xpPerProgressAnswer(bool correct) => correct ? 5 : 1;

int unlockXp(String deckId, Map<String, int> deckSizes) {
  final match = RegExp(r'^hsk(\d+)$').firstMatch(deckId);
  if (match == null) return 0;
  final level = int.parse(match.group(1)!);
  var total = 0;
  for (var previous = 1; previous < level; previous++) {
    total += ((deckSizes['hsk$previous'] ?? 0) / 3).ceil() * 5;
  }
  return total;
}

String leastUsedMode(Map<String, int> gamesPlayed, Random random) {
  const modes = ['cards', 'grammar', 'reading'];
  final minimum = modes.map((mode) => gamesPlayed[mode] ?? 0).reduce(min);
  final tied = modes.where((mode) => (gamesPlayed[mode] ?? 0) == minimum).toList();
  return tied[random.nextInt(tied.length)];
}
