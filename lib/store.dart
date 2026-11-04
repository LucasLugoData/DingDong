import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'srs.dart';

/// Estado global: vocabulario, progreso, notas, favoritas y ajustes.
class AppStore extends ChangeNotifier {
  AppStore._(this._prefs);

  final SharedPreferences _prefs;
  final List<Word> _builtIn = [];
  final List<Word> _custom = [];
  final Map<String, CardProgress> _progress = {};
  final Map<String, String> _notes = {};
  final Set<String> _favorites = {};

  /// Las conocidas vuelven a salir con intervalos crecientes (si no, nunca).
  bool reviewKnown = true;

  static const _kProgress = 'progress', _kNotes = 'notes', _kFav = 'favorites';
  static const _kCustom = 'custom', _kReviewKnown = 'reviewKnown';

  static Future<AppStore> load() async {
    final store = AppStore._(await SharedPreferences.getInstance());
    final raw = jsonDecode(await rootBundle.loadString('assets/vocab.json'));
    store._builtIn.addAll((raw as List).map((e) => Word.fromJson(e)));
    store._restore();
    return store;
  }

  void _restore() {
    final p = _prefs;
    final prog = p.getString(_kProgress);
    if (prog != null) {
      (jsonDecode(prog) as Map<String, dynamic>).forEach(
        (k, v) => _progress[k] = CardProgress.fromJson(v),
      );
    }
    final notes = p.getString(_kNotes);
    if (notes != null) _notes.addAll(Map<String, String>.from(jsonDecode(notes)));
    _favorites.addAll(p.getStringList(_kFav) ?? const []);
    final custom = p.getString(_kCustom);
    if (custom != null) {
      _custom.addAll((jsonDecode(custom) as List).map((e) => Word.fromJson(e)));
    }
    reviewKnown = p.getBool(_kReviewKnown) ?? true;
  }

  // ---------- Consultas ----------

  List<Word> get allWords => [..._builtIn, ..._custom];

  /// Palabras de un mazo, ordenadas por pinyin.
  List<Word> wordsOf(String deck) {
    final words = switch (deck) {
      Deck.all => allWords,
      Deck.favorites => allWords.where((w) => _favorites.contains(w.id)).toList(),
      Deck.custom => List.of(_custom),
      _ => _builtIn.where((w) => w.deck == deck).toList(),
    };
    words.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return words;
  }

  CardProgress progressOf(String id) => _progress[id] ?? CardProgress();
  String noteOf(String id) => _notes[id] ?? '';
  bool isFavorite(String id) => _favorites.contains(id);

  bool isDue(Word w, [DateTime? now]) => Srs.isDue(
    progressOf(w.id),
    now ?? DateTime.now(),
    reviewKnown: reviewKnown,
  );

  ({int fresh, int learning, int known, int due}) statsOf(String deck) {
    var fresh = 0, learning = 0, known = 0, due = 0;
    final now = DateTime.now();
    for (final w in wordsOf(deck)) {
      final p = progressOf(w.id);
      if (p.isNew) {
        fresh++;
      } else if (p.isKnown) {
        known++;
      } else {
        learning++;
      }
      if (Srs.isDue(p, now, reviewKnown: reviewKnown)) due++;
    }
    return (fresh: fresh, learning: learning, known: known, due: due);
  }

  // ---------- Cambios ----------

  void answer(Word w, bool correct) {
    _progress[w.id] = Srs.answer(progressOf(w.id), correct, DateTime.now());
    _saveProgress();
    notifyListeners();
  }

  void resetProgress(String deck) {
    for (final w in wordsOf(deck)) {
      _progress.remove(w.id);
    }
    _saveProgress();
    notifyListeners();
  }

  void setNote(String id, String note) {
    final t = note.trim();
    t.isEmpty ? _notes.remove(id) : _notes[id] = t;
    _prefs.setString(_kNotes, jsonEncode(_notes));
    notifyListeners();
  }

  void toggleFavorite(String id) {
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    _prefs.setStringList(_kFav, _favorites.toList());
    notifyListeners();
  }

  void setReviewKnown(bool v) {
    reviewKnown = v;
    _prefs.setBool(_kReviewKnown, v);
    notifyListeners();
  }

  /// Crea o actualiza una tarjeta propia. Devuelve la palabra guardada.
  Word saveCustom({
    String? id,
    required String hanzi,
    required String pinyin,
    required String meaning,
  }) {
    final word = Word(
      id: id ?? 'custom-${DateTime.now().microsecondsSinceEpoch}',
      hanzi: hanzi.trim(),
      pinyin: pinyin.trim(),
      meaning: meaning.trim(),
      deck: Deck.custom,
    );
    final i = _custom.indexWhere((w) => w.id == word.id);
    i >= 0 ? _custom[i] = word : _custom.add(word);
    _saveCustom();
    notifyListeners();
    return word;
  }

  void deleteCustom(String id) {
    _custom.removeWhere((w) => w.id == id);
    _progress.remove(id);
    _notes.remove(id);
    _favorites.remove(id);
    _saveCustom();
    _saveProgress();
    _prefs.setString(_kNotes, jsonEncode(_notes));
    _prefs.setStringList(_kFav, _favorites.toList());
    notifyListeners();
  }

  void _saveProgress() => _prefs.setString(
    _kProgress,
    jsonEncode(_progress.map((k, v) => MapEntry(k, v.toJson()))),
  );

  void _saveCustom() =>
      _prefs.setString(_kCustom, jsonEncode(_custom.map((w) => w.toJson()).toList()));
}
