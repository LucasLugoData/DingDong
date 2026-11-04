# 005 · Dominio por colores y paleta nueva

Estado: APROBADA
Peldaño inicial: 1
Revisión: no

## Objetivo
Colores rojo → naranja → azul → verde → dorado según aciertos y fallos de todos los modos Dinastía.

## Archivos permitidos
- lib/game/mastery.dart (nuevo)
- lib/theme.dart (solo añadir los colores de DISENO.md)
- test/mastery_test.dart (nuevo)

## Criterios de aceptación
- [ ] `masteryOf(hits, misses)`: neto = hits - misses. red si hits == 0 o neto < 1; orange 1-2; blue 3-5; green 6-9; gold si neto >= 10 y precisión >= 85% (si no, green).
- [ ] `Mastery.color` y `Mastery.label` (Sin dominar, Floja, En progreso, Conocida, Consolidada).
- [ ] `difficultyMult(Mastery)` para Gramática: green/gold 1.25, orange/blue 1.5, red 2.0.
- [ ] Tests de todos los límites.

## Comando de verificación
`flutter test test/mastery_test.dart && flutter analyze lib test`

## Límite de pasos
10

## Dudas

## Resultado

Aprobada por `flutter test test/mastery_test.dart && flutter analyze lib test` en el peldaño 1 (gpt-6-luna low).
