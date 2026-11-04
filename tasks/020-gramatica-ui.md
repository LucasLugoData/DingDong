# 020 · Gramática: bombo y construcción de frases

Estado: APROBADA
Peldaño inicial: 3
Revisión: no

## Objetivo
Pestaña Gramática: tirar el bombo, montar la frase con fichas y corregir palabra por palabra.

## Archivos permitidos
- lib/dynasty/grammar_screen.dart (nuevo)
- lib/widgets/bingo_drum.dart (nuevo, CustomPaint + animación)
- lib/dynasty/dynasty_shell.dart (solo enlazar la pestaña)
- test/grammar_screen_test.dart (nuevo)

## Criterios de aceptación
- [ ] Bombo de bingo con bolas (palabras vistas) que gira al pulsarlo y suelta 2-5 bolas con hanzi, pinyin y color de dominio.
- [ ] Zona de frase: tocar fichas (bolas + auxiliares) las añade; tocarlas en la frase las quita; reordenar arrastrando.
- [ ] "Entregar": se iluminan una a una en verde (bien) o naranja (mal); después puntuación de la frase y total; `store.recordAnswer` por bola usada.
- [ ] "Otra tirada" conserva la puntuación y sube el multiplicador de frase.
- [ ] Widget test a 375 px con Random fijo: tirar, montar 我 + verbo + objeto, entregar → colores y puntuación visibles.

## Comando de verificación
`flutter test test/grammar_screen_test.dart && flutter analyze lib test`

## Límite de pasos
25

## Dudas

## Resultado

Aprobada tras arreglos de Claude/Sonnet: suite completa 141 tests OK y analyze limpio.
