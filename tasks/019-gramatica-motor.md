# 019 · Gramática: bombo, corrector y puntuación (puro)

Estado: APROBADA
Peldaño inicial: 3
Revisión: no

## Objetivo
Lógica de una tirada de Gramática en `lib/game/grammar.dart` (corrección offline por reglas de orden).

## Archivos permitidos
- lib/game/grammar.dart (nuevo)
- test/grammar_test.dart (nuevo)

## Criterios de aceptación
- [ ] `drawBalls(seenWords, roles, random, {extra = 0, harder = false, rarer = false})` → 2-5 palabras vistas: sobre todo sujeto, tiempo, CCM, CCL, verbo, objeto; con menor probabilidad (~20%) clasificador, número, 了/会, 比/很, 又…又, 没有/不, variantes de 那/哪. Siempre al menos un verbo.
- [ ] Fichas auxiliares siempre disponibles (我 你 他 是 的 在 很 不 吗 了), que no puntúan.
- [ ] `checkSentence(List<String> tokens, roles)` → bool por token según el orden: [tiempo] sujeto [tiempo] [negación/会] [在+lugar | manera] verbo [了] [número+clasificador] objeto [了]; A 比 B adj; 很 + adj; 又 adj 又 adj; 吗 al final; 的 entre modificador y sustantivo. Token fuera de sitio = false.
- [ ] Frase válida si usa ≥ 2 bolas y tiene sujeto+verbo o verbo+objeto.
- [ ] `scoreSentence`: por bola bien colocada 10 × `difficultyMult(mastery)`; total × multiplicador de frase (1 + 0.25 × frases válidas previas de la tirada).
- [ ] Tests: 我今天在家吃饭了 correcta; 吃我饭 marca errores; 他比我高 correcta; puntuación con multiplicadores.

## Comando de verificación
`flutter test test/grammar_test.dart test/grammar_roles_test.dart && flutter analyze lib test`

## Límite de pasos
25

## Dudas

## Resultado

Aprobada tras arreglos de Claude/Sonnet: suite completa 141 tests OK y analyze limpio.
