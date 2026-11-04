import '../models.dart';

class TextSegment {
  const TextSegment(this.text, {this.word, this.isPunctuation = false});

  final String text;
  final Word? word;
  final bool isPunctuation;
}

/// Splits Chinese text using the longest vocabulary match (up to four chars).
List<TextSegment> segment(String text, Map<String, Word> byHanzi) {
  final result = <TextSegment>[];
  final characters = text.runes.map(String.fromCharCode).toList();
  var offset = 0;
  while (offset < characters.length) {
    final char = characters[offset];
    if (_isPunctuation(char)) {
      result.add(TextSegment(char, isPunctuation: true));
      offset++;
      continue;
    }
    Word? match;
    var matchLength = 0;
    for (var length = 4; length >= 1; length--) {
      if (offset + length > characters.length) {
        continue;
      }
      final candidateCharacters = characters.sublist(offset, offset + length);
      if (candidateCharacters.any((char) => _isPunctuation(char) || char.trim().isEmpty)) {
        continue;
      }
      final candidate = candidateCharacters.join();
      final word = byHanzi[candidate];
      if (word != null) {
        match = word;
        matchLength = length;
        break;
      }
    }
    if (match != null) {
      result.add(TextSegment(characters.sublist(offset, offset + matchLength).join(), word: match));
      offset += matchLength;
    } else {
      result.add(TextSegment(char));
      offset++;
    }
  }
  return result;
}

bool _isPunctuation(String char) =>
    '''，。！？；：、,.!?;:“”‘’"'（）()《》〈〉「」『』【】〔〕［］[]{}…—–-·・/\\_¿¡«»'''.contains(char);
