# 014 · Solitario: pantalla de partida y tienda

Estado: APROBADA
Peldaño inicial: 3
Revisión: no

## Objetivo
Jugar las 100 tarjetas con el marcador estilo referencia y tienda cada 20.

## Archivos permitidos
- lib/dynasty/solitaire_screen.dart (nuevo)
- lib/dynasty/shop_sheet.dart (nuevo)
- lib/dynasty/cards_home.dart (solo abrir la ruta)
- test/solitaire_screen_test.dart (nuevo)

## Criterios de aceptación
- [ ] Pantalla completa (Navigator.push), sin TopBar. Reutiliza `FlashCard` (derecha = la sé, izquierda = no la sé).
- [ ] Marcador: puntos totales; "+N Fichas" (número azul), "+N Mult" (número rojo, "Mult" dorado), píldora roja "X1.5 Mult" si multMult ≠ 1; monedas; "k/100"; animación breve al sumar.
- [ ] Cada respuesta → `store.recordAnswer`.
- [ ] En 20/40/60/80 se abre la tienda: 3 `PassiveCard` de `rollShop`, comprar si hay monedas, "Continuar". Fila de pasivas poseídas visible durante la partida.
- [ ] Al llegar a 100 navega a la demostración (015; si no existe, placeholder con la puntuación).
- [ ] Widget test a 375 px con Random fijo: responder 20 → aparece la tienda; comprar descuenta monedas.

## Comando de verificación
`flutter test test/solitaire_screen_test.dart && flutter analyze lib test`

## Límite de pasos
25

## Dudas

## Resultado

Aprobada tras arreglos de Claude/Sonnet: suite completa 141 tests OK y analyze limpio.
