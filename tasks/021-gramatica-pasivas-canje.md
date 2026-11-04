# 021 · Gramática: elección de pasivas cada 2 frases y canjear

Estado: PENDIENTE
Peldaño inicial: 2
Revisión: no

## Objetivo
Cerrar el bucle de la tirada de Gramática.

## Archivos permitidos
- lib/dynasty/grammar_screen.dart
- test/grammar_screen_test.dart

## Criterios de aceptación
- [ ] Cada 2 frases entregadas se ofrecen 2 opciones de `rollGrammarChoice` con `PassiveCard`: cada una con efecto positivo (bonus de XP) y negativo (más bolas, más difíciles o menos comunes) que se aplican al resto de la tirada.
- [ ] Botón "Canjear" visible tras la primera frase: abre `ResultsScreen` de 015 con `gameMode: 'grammar'` y la puntuación × (1 + bonus); reinicia la tirada.
- [ ] Logro `grammar_10`.
- [ ] Test: tras 2 frases aparece la elección; canjear suma XP al player.

## Comando de verificación
`flutter test test/grammar_screen_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado
