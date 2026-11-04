import 'pinyin.dart';

class Word {
  Word({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    required this.deck,
    this.lang = 'es',
  }) : sortKey = pinyinSortKey(pinyin, hanzi),
       searchKey = pinyinSearchKey(pinyin);

  final String id;
  final String hanzi;
  final String pinyin;
  final String meaning;
  final String deck;
  final String lang;
  final String sortKey;
  final String searchKey;

  bool get isCustom => deck == Deck.custom;

  factory Word.fromJson(Map<String, dynamic> j) => Word(
    id: j['id'] as String,
    hanzi: j['hanzi'] as String,
    pinyin: j['pinyin'] as String,
    meaning: j['meaning'] as String,
    deck: j['deck'] as String,
    lang: (j['lang'] as String?) ?? 'es',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'hanzi': hanzi,
    'pinyin': pinyin,
    'meaning': meaning,
    'deck': deck,
    'lang': lang,
  };
}

class Deck {
  const Deck(this.id, this.title, this.subtitle);
  final String id;
  final String title;
  final String subtitle;

  static const custom = 'custom';
  static const favorites = 'fav';
  static const all = 'all';

  static const list = [
    Deck('hsk1', 'HSK 1', 'Nuevo HSK 3.0 · 300 palabras'),
    Deck('hsk2', 'HSK 2', 'Nuevo HSK 3.0 · 200 palabras'),
    Deck('hsk3', 'HSK 3', 'Nuevo HSK 3.0 · 500 palabras'),
    Deck('hsk4', 'HSK 4', '540 palabras sin repetir HSK 1–3'),
    Deck(custom, 'Mis tarjetas', 'Las palabras que añades tú'),
    Deck(favorites, 'Favoritas', 'Las marcadas con estrella'),
    Deck(all, 'Todo', 'Todas las listas juntas'),
  ];

  static Deck byId(String id) => list.firstWhere((d) => d.id == id);
}

/// Estado de repetición espaciada de una tarjeta.
class CardProgress {
  CardProgress({this.stage = 0, this.due, this.lapses = 0});

  /// 0 = nueva; 1-2 = en progreso; >= [knownStage] = conocida.
  int stage;
  DateTime? due;
  int lapses;

  static const knownStage = 3;

  bool get isNew => stage == 0;
  bool get isKnown => stage >= knownStage;
  bool get isLearning => !isNew && !isKnown;

  factory CardProgress.fromJson(Map<String, dynamic> j) => CardProgress(
    stage: j['s'] as int,
    due: j['d'] == null ? null : DateTime.fromMillisecondsSinceEpoch(j['d']),
    lapses: (j['l'] as int?) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    's': stage,
    'd': due?.millisecondsSinceEpoch,
    'l': lapses,
  };
}
