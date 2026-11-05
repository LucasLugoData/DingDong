# 034 · Marcador de casino en el Solitario

Estado: APROBADA
Peldaño inicial: 3
Revisión: no

## Objetivo
Integrar `ScoreBurst` (tarea 033) en `SolitaireScreen` y convertir el marcador en un panel de casino imperial: que conseguir puntos se sienta épico.

## Archivos permitidos
- lib/dynasty/solitaire_screen.dart
- test/solitaire_screen_test.dart

PROHIBIDO tocar la tarjeta de papiro de memorizar (`FlashCard`), `lib/theme.dart` y la lógica de `lib/game/`.

## Diseño
- Panel de marcador: placa de laca negra con filete dorado. Puntuación grande en dorado con contorno que **cuenta hacia arriba** (Tween animado ~600 ms desde el valor anterior) y palpita al llegar. Debajo, dos placas tipo ficha de casino: azul «Fichas» y roja «Mult» separadas por «×»; cuando cambian hacen pop. Si `multMult != 1`, sello rojo «X…» al lado. Si `mult ≥ 10`, la puntuación arde: aura de llamas naranjas animada que se apaga sola tras el evento (no en bucle infinito).
- Al responder: `ScoreBurst` encima de todo con `run.lastEvent`; la pantalla entera se sacude con `shakeFor(event)` (Transform.translate amortiguado).
- Pasivas equipadas: miniaturas redondas con `assets/passives/<id>.png` (en vez de `Chip`), manteniendo el `Tooltip` y el texto `'${hanzi} ${name}'` accesible (p. ej. `Semantics` o texto pequeño bajo la miniatura). Las de `lastEvent.triggered` saltan, se ladean y muestran una etiqueta flotante corta («+5», «×1.5», «+1 💰»).
- Monedas: el contador `run-coins` hace pop al subir.
- Nada bloquea la entrada: se puede seguir respondiendo durante la animación (el test pulsa «La sé» 20 veces seguidas).

## Criterios de aceptación
- [ ] Tras un acierto hay un `ScoreBurst` en el árbol con el evento de `run.lastEvent`.
- [ ] La puntuación mostrada (`ValueKey('score')`) acaba siendo el valor de `run.score` tras `pumpAndSettle`.
- [ ] Con una pasiva equipada se ve su miniatura (`Image` con `AssetImage('assets/passives/<id>.png')`) y el texto `'${hanzi} ${name}'` sigue encontrándose.
- [ ] Todos los tests de `test/solitaire_screen_test.dart` siguen pasando (ajusta solo esperas/pumps, sin quitar comprobaciones) y sin overflow a 375×812.

## Comando de verificación
`flutter test test/solitaire_screen_test.dart test/score_burst_test.dart && flutter analyze lib test`

## Límite de pasos
25

## Dudas

## Resultado

Aprobada por `flutter test test/solitaire_screen_test.dart test/score_burst_test.dart && flutter analyze lib test` en el peldaño 3 (gpt-6.1-sol medium).
