/// Ordenación alfabética según el pinyin (no según la traducción).
///
/// Se compara primero por las letras sin tono (ü va después de u), luego por
/// la secuencia de tonos (1-4, neutro al final) y por último por los caracteres.
library;

const _toned = {
  'ā': 'a1', 'á': 'a2', 'ǎ': 'a3', 'à': 'a4',
  'ē': 'e1', 'é': 'e2', 'ě': 'e3', 'è': 'e4',
  'ī': 'i1', 'í': 'i2', 'ǐ': 'i3', 'ì': 'i4',
  'ō': 'o1', 'ó': 'o2', 'ǒ': 'o3', 'ò': 'o4',
  'ū': 'u1', 'ú': 'u2', 'ǔ': 'u3', 'ù': 'u4',
  'ǖ': 'v1', 'ǘ': 'v2', 'ǚ': 'v3', 'ǜ': 'v4', 'ü': 'v5',
};

/// Devuelve (letras base, tonos) a partir de un pinyin con diacríticos.
(String, String) pinyinParts(String pinyin) {
  final base = StringBuffer();
  final tones = StringBuffer();
  for (final ch in pinyin.toLowerCase().split('')) {
    final t = _toned[ch];
    if (t != null) {
      base.write(t[0]);
      if (t[1] != '5') tones.write(t[1]);
    } else if (RegExp(r'[a-z]').hasMatch(ch)) {
      base.write(ch);
    }
  }
  return (base.toString(), tones.toString());
}

/// Clave de ordenación: letras base + tonos + caracteres.
String pinyinSortKey(String pinyin, String hanzi) {
  final (base, tones) = pinyinParts(pinyin);
  return '$base\u0000${tones.padRight(8, '5')}\u0000$hanzi';
}

/// Texto normalizado para buscar sin tonos ni espacios ("bei fang" == "běifāng").
String pinyinSearchKey(String text) => pinyinParts(text).$1;
