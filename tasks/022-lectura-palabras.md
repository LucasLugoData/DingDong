# 022 · Lectura: pinyin al tocar, traducción al mantener

Estado: APROBADA
Peldaño inicial: 2
Revisión: no

## Objetivo
Segmentar los textos en palabras del vocabulario para mostrar pinyin (toque) y significado (pulsación larga).

## Archivos permitidos
- lib/game/segment.dart (nuevo, puro)
- lib/screens/reading_screen.dart
- test/segment_test.dart (nuevo)

## Criterios de aceptación
- [ ] `segment(String text, Map<String, Word> byHanzi)`: coincidencia más larga primero (hasta 4 caracteres); puntuación aparte; desconocidos sueltos.
- [ ] Tocar una palabra muestra/oculta su pinyin encima; mantener muestra un globo con el significado.
- [ ] En Modo Dinastía cada texto tiene botón "Ejercicios" (abre 024; placeholder si no existe).
- [ ] Test: "我今天去学校" → [我, 今天, 去, 学校] con vocabulario de ejemplo.

## Comando de verificación
`flutter test test/segment_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado

Aprobada tras arreglos de Claude/Sonnet: suite completa 141 tests OK y analyze limpio.
