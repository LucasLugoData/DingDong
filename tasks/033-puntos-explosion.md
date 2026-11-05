# 033 · Explosión de puntos estilo casino (widget)

Estado: APROBADA
Peldaño inicial: 3
Revisión: no

## Objetivo
Widget `ScoreBurst` que convierte cada `ScoreEvent` (tarea 032) en un espectáculo de casino de cartas: exagerado, satisfactorio, con mucho "juice" (pop, sacudida, números que vuelan, monedas, elogio gigante). Estética China imperial del resto de la app (laca negra, oro, bermellón, jade). Diseño original: nada copiado de otros juegos. A 375 px.

## Archivos permitidos
- lib/widgets/score_burst.dart (nuevo)
- test/score_burst_test.dart (nuevo)

## Diseño
`ScoreBurst({required ScoreEvent? event, required int eventId, Duration duration = const Duration(milliseconds: 1100)})`; se dispara cada vez que cambia `eventId`. Es una capa (`IgnorePointer`, `Stack` a pantalla completa) que se coloca encima del Solitario.
1. **Fichas × Mult** (0-350 ms): una placa azul con `chips` y una roja con `mult` caen desde arriba con rebote (`Curves.elasticOut`), se sacuden y chocan en el centro con un destello blanco-dorado; aparece «×» entre ellas.
2. **Ganancia** (350-800 ms): `+gain` gigante en dorado con contorno negro grueso (texto con `Paint..style = stroke` debajo + relleno con degradado oro→naranja), escala 0→1.4→1 y sube flotando mientras se desvanece. Si `multMult != 1`, un sello rojo «X1.5» gira y se estampa al lado.
3. **Lluvia de monedas**: 6-20 monedas doradas con agujero cuadrado (CustomPainter) salen disparadas en abanico y caen con gravedad; cantidad proporcional a `log(gain)`.
4. **Elogio** (si `praiseFor(event.streak)` no es null): hanzi enorme con el texto debajo («¡Genial!»), inclinado unos grados, con rebote y contorno; cuanto más `tier`, más grande, más partículas, rayos de luz girando detrás y colores (tier 5: arco iris dorado).
5. **Sacudida**: expón `double shakeFor(ScoreEvent e)` (0 si falla, crece con `gain` y `tier`, máximo 12 px) para que la pantalla se sacuda (lo usa la 034).
6. **Fallo**: solo un «✕» rojo que se rompe en trozos y una vibración corta; sin elogio.
- Todas las animaciones terminan solas en `duration` (nada en bucle infinito: `pumpAndSettle` debe acabar). Usa `HapticFeedback.mediumImpact` en tier ≥ 3 y `heavyImpact` en tier 5. Sin dependencias nuevas.

## Criterios de aceptación
- [ ] Con un evento de acierto `gain 120`, tras ~400 ms se ve el texto `+120`; tras `pumpAndSettle` no queda nada visible (capa vacía).
- [ ] Con `streak 10` aparece «太棒了» y «¡Genial!»; con `streak 4` no aparece ningún elogio.
- [ ] Con fallo no aparece `+` ni elogio.
- [ ] `shakeFor` es 0 en fallo, crece con `gain` y nunca supera 12.
- [ ] Sin overflow a 375×812.

## Comando de verificación
`flutter test test/score_burst_test.dart && flutter analyze lib test`

## Límite de pasos
30

## Dudas

## Resultado

Aprobada tras arreglo de Claude: el test no contaba el primer fotograma del ticker (+82 ms).
