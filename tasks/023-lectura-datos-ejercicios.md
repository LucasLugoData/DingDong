# 023 · Lectura: datos de ejercicios

Estado: PENDIENTE
Peldaño inicial: 2
Revisión: no

## Objetivo
Para cada uno de los 6 textos de lib/data/readings.dart, pregunta de idea central y frases etiquetadas.

## Archivos permitidos
- lib/data/reading_exercises.dart (nuevo; archivo de datos)
- test/reading_exercises_test.dart (nuevo)

## Criterios de aceptación
- [ ] `ReadingExercise(readingTitle, ideaQuestion, options (4, en español), correctIndex, taggedSentences)`.
- [ ] `taggedSentences`: 3-4 frases del texto, cada una lista de (palabra, etiqueta): sustantivo, verbo, adjetivo, sujeto, objeto, partícula, tiempo, lugar, clasificador, número, adverbio. Las palabras concatenadas reproducen exactamente la frase original.
- [ ] Test: un ejercicio por texto; cada frase etiquetada aparece literal en su texto; cada frase tiene al menos un verbo.

## Comando de verificación
`flutter test test/reading_exercises_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado
