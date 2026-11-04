# 025 · Indicador x2 del modo menos usado

Estado: PENDIENTE
Peldaño inicial: 1
Revisión: no

## Objetivo
Mostrar qué modo (Tarjetas, Gramática, Lectura) da x2 de XP al canjear.

## Archivos permitidos
- lib/dynasty/dynasty_shell.dart
- test/dynasty_shell_test.dart

## Criterios de aceptación
- [ ] En el icono de la pestaña de `store.bonusMode` aparece un "x2" pequeño arriba a la derecha; si es null (usado hace < 2 h) no aparece en ninguna.
- [ ] Un brillo dorado recorre el icono cada ~8 s (animación corta; intervalo inyectable para tests).
- [ ] Tests: gamesPlayed {cards:3, grammar:0, reading:2} → x2 solo en Gramática; tras canjear una partida de Gramática desaparece.

## Comando de verificación
`flutter test test/dynasty_shell_test.dart && flutter analyze lib test`

## Límite de pasos
10

## Dudas

## Resultado
