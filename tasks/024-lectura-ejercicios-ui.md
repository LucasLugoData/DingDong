# 024 · Lectura: pantalla de ejercicios

Estado: APROBADA
Peldaño inicial: 2
Revisión: no

## Objetivo
Ejercicio 1: idea central. Ejercicio 2: "pulsa el verbo / sustantivo / partícula…" en frases del texto.

## Archivos permitidos
- lib/dynasty/reading_exercise_screen.dart (nuevo)
- lib/screens/reading_screen.dart (solo abrir la ruta)
- test/reading_exercise_test.dart (nuevo)

## Criterios de aceptación
- [ ] Pantalla completa sin TopBar. Paso 1: pregunta + 4 opciones; feedback verde/rojo.
- [ ] Paso 2: por cada frase etiquetada, "Pulsa el <etiqueta>" con una etiqueta presente elegida al azar; palabras como fichas; acierto verde, fallo naranja.
- [ ] Puntuación: 100 por acierto, +50% por racha; al final `ResultsScreen` de 015 con `gameMode: 'reading'`; logro `reading_perfect` si 0 fallos; `recordAnswer` de las palabras del vocabulario pulsadas.
- [ ] Widget test a 375 px: todo bien → XP > 0 y medalla.

## Comando de verificación
`flutter test test/reading_exercise_test.dart && flutter analyze lib test`

## Límite de pasos
20

## Dudas

## Resultado

Aprobada tras arreglos de Claude/Sonnet: suite completa 141 tests OK y analyze limpio.
