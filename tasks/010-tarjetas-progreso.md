# 010 · Tarjetas Dinastía: bloques, bloqueo y modo Progreso

Estado: PENDIENTE
Peldaño inicial: 2
Revisión: no

## Objetivo
Pestaña Tarjetas del Modo Dinastía con bloques bloqueados por XP, medallas por bloque y contador de vistas.

## Archivos permitidos
- lib/dynasty/cards_home.dart (nuevo)
- lib/screens/study_screen.dart (solo parámetros opcionales `onAnswer(Word, bool)`, `onFinish()` y `words`)
- lib/store.dart (solo getter `wordIdsByDeck`)
- lib/dynasty/dynasty_shell.dart (solo enlazar la pestaña)
- test/cards_home_test.dart (nuevo)

## Criterios de aceptación
- [ ] Sin "Para hoy" ni "N hoy" en esta vista (ni arriba ni en cada bloque). Arriba solo "Vistas: N" (= player.seen.length).
- [ ] Bloques: Todo, HSK1-4, Mis tarjetas, Favoritas. "Todo" = palabras en seen + tarjetas propias.
- [ ] HSK2-4 bloqueados (candado, gris, "Desbloquea con N XP") hasta `player.xp >= unlockXp(deck)`.
- [ ] Cada bloque HSK muestra a la derecha sus 3 círculos de medalla: oscuros si no se tienen, iluminados con su color si sí.
- [ ] Al estudiar: cada respuesta → `store.recordAnswer`; al terminar o salir, `grantXp('cards', suma de xpPerProgressAnswer)`; luego `evaluate` de logros y `unlockMedal`.
- [ ] Con hsk2 desbloqueado, al abrir un bloque se elige "Progreso" o "Solitario" (Solitario abre 014; si no existe, SnackBar "Próximamente").
- [ ] Widget test a 375 px: con xp 0 HSK2 bloqueado; con xp suficiente desbloqueado y aparece la elección.

## Comando de verificación
`flutter test test/cards_home_test.dart test/session_test.dart && flutter analyze lib test`

## Límite de pasos
20

## Dudas

## Resultado
