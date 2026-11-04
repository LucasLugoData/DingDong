import '../models.dart';

class Fusion {
  const Fusion({required this.word, required this.parts});

  final Word word;
  final List<Word> parts;
}

List<Fusion> fusions(List<Word> words) {
  final basics = <String, Word>{
    for (final word in words)
      if (word.hanzi.runes.length == 1) word.hanzi: word,
  };
  final result = <Fusion>[];
  for (final word in words) {
    final runes = word.hanzi.runes;
    if (runes.length < 2) continue;
    final parts = [
      for (final rune in runes)
        if (basics.containsKey(String.fromCharCode(rune))) basics[String.fromCharCode(rune)]!,
    ];
    if (parts.length >= 2) result.add(Fusion(word: word, parts: parts));
  }
  return result;
}

List<Fusion> fusionsOf(String char, List<Word> words) =>
    fusions(words).where((fusion) => fusion.parts.any((part) => part.hanzi == char)).toList();
