# 032 · Evento de puntuación del Solitario (lógica pura)

Estado: APROBADA
Peldaño inicial: 2
Revisión: no

## Objetivo
Que cada respuesta del Solitario deje un registro de lo que pasó para poder animarlo como un casino (tareas 033-034): cuánto se ganó, con qué fichas y mult, qué pasivas saltaron y qué elogio toca según la racha.

## Archivos permitidos
- lib/game/solitaire.dart
- lib/game/praise.dart (nuevo)
- test/solitaire_test.dart
- test/praise_test.dart (nuevo)

## API
- En `SolitaireRun`: `ScoreEvent? lastEvent`, se rellena en cada `answer`. La puntuación y el resto de reglas NO cambian.
- `class ScoreEvent { bool correct; int chips; int mult; double multMult; double gain; int streak; List<int> triggered; }`
  - `chips`/`mult`/`multMult`: valores usados en el cálculo (`gain = chips * mult * multMult`, 0 si falla).
  - `streak`: aciertos seguidos incluido este (0 si falla).
  - `triggered`: índices (en `passives`) de las pasivas cuyo `onCorrect`/`onWrong` cambió `chips`, `mult`, `multMult`, `coins` o `coinsPerCorrect` (compara antes/después de cada hook).
- `lib/game/praise.dart`: `Praise? praiseFor(int streak)` con `Praise {String hanzi; String text; int tier;}`:
  - 3 → 好 «¡Bien!» (tier 1) · 5 → 很好 «¡Muy bien!» (2) · 10 → 太棒了 «¡Genial!» (3) · 15 → 无敌 «¡Imparable!» (4) · 20 y cada 10 más → 天子 «¡Imperial!» (5). Otros valores → null.

## Criterios de aceptación
- [ ] Tras un acierto con 10 fichas y mult 1: `lastEvent.gain == 10`, `chips == 10`, `mult == 1`, `streak == 1`; tras un fallo `gain == 0`, `streak == 0`.
- [ ] Con la pasiva `brush` (índice 0) un acierto deja `triggered == [0]`; con `bamboo` y mult < 5 queda vacío.
- [ ] `praiseFor` devuelve lo indicado para 3, 5, 10, 15, 20, 30 y null para 4 y 0.
- [ ] Los tests existentes de `test/solitaire_test.dart` siguen pasando sin cambiar sus valores.

## Comando de verificación
`flutter test test/solitaire_test.dart test/praise_test.dart && flutter analyze lib test`

## Límite de pasos
12

## Dudas

## Resultado

Aprobada por `flutter test test/solitaire_test.dart test/praise_test.dart && flutter analyze lib test` en el peldaño 2 (gpt-6-luna medium).
