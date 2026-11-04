import 'models.dart';

/// Repetición espaciada tipo Leitner.
///
/// - ✓ en una tarjeta nueva: la sabías de antes → pasa directa a "conocida".
/// - ✓ en una tarjeta en progreso: sube un escalón y el intervalo crece.
/// - ✗: vuelve al escalón 1 y reaparece pocas tarjetas después en esta sesión.
class Srs {
  /// Intervalo (en días) de cada escalón. El escalón 1 se repasa en la sesión.
  static const intervals = [0, 0, 1, 3, 7, 15, 35, 90];

  /// Cuántas tarjetas después reaparece una fallada dentro de la sesión.
  static const relearnGap = 4;

  static CardProgress answer(CardProgress p, bool correct, DateTime now) {
    if (correct) {
      final next = p.isNew
          ? CardProgress.knownStage
          : (p.stage + 1).clamp(1, intervals.length - 1);
      return CardProgress(
        stage: next,
        due: now.add(Duration(days: intervals[next])),
        lapses: p.lapses,
      );
    }
    return CardProgress(stage: 1, due: now, lapses: p.lapses + 1);
  }

  /// ¿Debe salir hoy? Con [reviewKnown] a false las conocidas no vuelven a
  /// salir hasta que se reinicia el progreso.
  static bool isDue(CardProgress p, DateTime now, {bool reviewKnown = true}) {
    if (p.isNew) return true;
    if (p.isKnown && !reviewKnown) return false;
    return p.due == null || !p.due!.isAfter(now);
  }
}
