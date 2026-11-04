# 006 · Catálogo de logros (medallas)

Estado: APROBADA
Peldaño inicial: 2
Revisión: no

## Objetivo
Medallas y su evaluación pura para bloques, perfil y barra superior.

## Archivos permitidos
- lib/game/achievements.dart (nuevo)
- test/achievements_test.dart (nuevo)

## Criterios de aceptación
- [ ] `Achievement(id, title, description, color, icon)`.
- [ ] Por bloque (hsk1..hsk4): `<deck>_bronze` (33% del bloque en seen), `<deck>_silver` (100% en seen), `<deck>_gold` (todo el bloque en green o gold).
- [ ] Generales: `level_5`, `level_10`, `level_20`, `solitaire_win` (demostración superada), `solitaire_100k` (100000 puntos en una partida), `grammar_10` (10 frases válidas en una tirada), `reading_perfect` (ejercicios de lectura sin fallos), `roulette_win`.
- [ ] `evaluate(Player, Map<String,List<String>> deckWordIds, {Map<String,Object> event = const {}})` → ids nuevos (no repite los ya obtenidos).
- [ ] `blockMedals(deckId)` → las 3 del bloque en orden bronce, plata, oro.
- [ ] Tests de cada condición.

## Comando de verificación
`flutter test test/achievements_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado

Aprobada por `flutter test test/achievements_test.dart && flutter analyze lib test` en el peldaño 3 (gpt-6.1-sol medium).
