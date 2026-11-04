# 003 · Modelo Player y persistencia con migración

Estado: APROBADA
Peldaño inicial: 2
Revisión: sí

## Objetivo
Añadir el estado del Modo Dinastía (tasks/DISENO.md "Player" y "API del store") sin perder datos de la versión instalada.

## Archivos permitidos
- lib/game/player.dart (nuevo)
- lib/store.dart
- pubspec.yaml (solo `version: 1.1.0+2`)
- test/player_store_test.dart (nuevo)

## Criterios de aceptación
- [ ] `Player` con toJson/fromJson tolerante a campos ausentes; `enum AppMode {free, dynasty}`.
- [ ] Test de migración: prefs con `progress`, `notes`, `favorites`, `custom`, `reviewKnown` y sin `player` → tras `AppStore.load()` todo sigue igual y `player.mode == null`.
- [ ] `recordAnswer`, `markSeen`, `setName`, `setMode`, `unlockMedal`, `setFeaturedMedal` persisten en `player` y sobreviven a recargar.
- [ ] `grantXp` suma la XP y `gamesPlayed[mode]++` (el x2 lo añade 004).
- [ ] `resetAccount` borra `player` y `progress`; conserva `notes`, `favorites`, `custom`.
- [ ] Las claves antiguas no se renombran.

## Comando de verificación
`flutter test test/player_store_test.dart test/srs_test.dart && flutter analyze lib test`

## Límite de pasos
20

## Dudas

## Resultado

Aprobada por `flutter test test/player_store_test.dart test/srs_test.dart && flutter analyze lib test` en el peldaño 2 (gpt-6-luna medium).
