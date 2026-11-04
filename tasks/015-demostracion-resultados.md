# 015 · Solitario: demostración, resultados y ruleta

Estado: PENDIENTE
Peldaño inicial: 3
Revisión: no

## Objetivo
Cierre de la partida: demostrar lo que dijiste saber, convertir puntos en XP y ruleta opcional.

## Archivos permitidos
- lib/dynasty/demo_screen.dart (nuevo)
- lib/dynasty/results_screen.dart (nuevo, reutilizable por Gramática y Lectura)
- lib/widgets/roulette.dart (nuevo)
- lib/dynasty/solitaire_screen.dart (solo navegar a la demo)
- test/demo_results_test.dart (nuevo)

## Criterios de aceptación
- [ ] Demostración: 10 hanzi a la izquierda y 10 fichas "pinyin · significado" barajadas a la derecha; tocar uno de cada lado los empareja. Un emparejamiento erróneo = demostración fallada (se marca en rojo y termina).
- [ ] `ResultsScreen(score, gameMode, ...)`: si superada, `grantXp(gameMode, xpFromScore(score))`, "x2" si aplica, barra de XP creciendo animada y número de XP ganado; subida de nivel visible. Si fallada: "Has perdido la experiencia", 0 XP (la partida cuenta).
- [ ] Solo en Solitario, 25% (Random inyectable): botón "Tentar a la suerte" antes de canjear → ruleta lila/amarilla, el jugador elige color, gira; acierto ×2, fallo ×0.75.
- [ ] Evaluar logros (`solitaire_win`, `solitaire_100k`, `roulette_win`, niveles).
- [ ] Widget tests: demo todo bien → XP > 0; un fallo → 0 XP; ruleta con Random fijo aplica ×2 o ×0.75.

## Comando de verificación
`flutter test test/demo_results_test.dart && flutter analyze lib test`

## Límite de pasos
25

## Dudas

## Resultado
