# 016 · Hanziario: colores de dominio y orden por más falladas

Estado: PENDIENTE
Peldaño inicial: 1
Revisión: no

## Objetivo
En Modo Dinastía la lista de palabras usa los 5 colores de dominio y puede ordenarse por más falladas.

## Archivos permitidos
- lib/screens/word_list_screen.dart
- lib/dynasty/dynasty_shell.dart (solo pasar `dynasty: true`)
- test/word_list_test.dart (nuevo)

## Criterios de aceptación
- [ ] Parámetro `dynasty` (por defecto false: el modo libre queda igual).
- [ ] Con dynasty: el indicador de cada palabra usa `masteryOf(wordStats).color`; leyenda pequeña rojo → dorado arriba.
- [ ] Selector de orden: Pinyin (defecto) / Más falladas (misses desc, desempate pinyin).
- [ ] Botón "Fusión" que abre la vista de 017 (placeholder si no existe).
- [ ] Widget test: palabra con 3 fallos sale primera con "Más falladas" y en rojo.

## Comando de verificación
`flutter test test/word_list_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado
