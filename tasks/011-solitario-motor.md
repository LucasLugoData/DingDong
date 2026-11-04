# 011 · Motor del modo Solitario (puro)

Estado: PENDIENTE
Peldaño inicial: 3
Revisión: no

## Objetivo
Reglas de la partida Solitario, sin UI, en `lib/game/solitaire.dart`.

## Archivos permitidos
- lib/game/solitaire.dart (nuevo)
- test/solitaire_test.dart (nuevo)

## Criterios de aceptación
- [ ] `SolitaireRun(words, passives, random)`: 100 tarjetas de las vistas, barajadas (si hay menos de 100, se repiten barajadas hasta 100).
- [ ] Acierto: fichas base 10 → puntos += fichas × mult × multMult; después mult += 1 (racha). Fallo: mult vuelve a 1. multMult empieza en 1.0 y solo lo cambian pasivas (queda abierto a futuro).
- [ ] Monedas: +1 por acierto (modificable por pasivas).
- [ ] Interfaz `PassiveHooks` (onCorrect/onWrong/onShop/priceModifier) definida aquí; 012 implementa el catálogo.
- [ ] `isShopTime` tras las tarjetas 20, 40, 60, 80. `buy(passive)` descuenta monedas; máx. 5 pasivas.
- [ ] `knownThisRun` (ids acertados). `demoWords(random)` = 10 de ellos (todos si hay menos; con menos de 3 la demostración se da por fallada).
- [ ] `finishDemo(bool allCorrect)`: si falla, `finalScore = 0`.
- [ ] Tests: aciertos seguidos dan 10+20+30; fallo resetea; tiendas en 20/40/60/80; demo fallida → 0.

## Comando de verificación
`flutter test test/solitaire_test.dart && flutter analyze lib test`

## Límite de pasos
20

## Dudas

## Resultado
