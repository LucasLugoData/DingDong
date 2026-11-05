# 030 · Medallón imperial y hoja de Logros

Estado: APROBADA
Peldaño inicial: 3
Revisión: no

## Objetivo
Crear `AchievementMedal`, un medallón china imperial a juego con `PassiveCard` (`lib/widgets/passive_card.dart`: laca negra, doble filete dorado, sello rojo, papel), y rediseñar la hoja "Logros" del perfil como una vitrina épica. Se diseña y prueba a 375 px.

## Archivos permitidos
- lib/widgets/achievement_medal.dart (nuevo)
- lib/dynasty/profile_screen.dart (solo `_showAchievements` y el botón `profile-achievements`)
- test/achievement_medal_test.dart (nuevo)
- test/profile_test.dart

PROHIBIDO tocar la tarjeta de papiro de memorizar, `lib/theme.dart`, `PassiveCard` y otras pantallas.

## Diseño
- `AchievementMedal({required Achievement medal, required bool unlocked, double size = 72})`: círculo con la ilustración `medal.imageAsset` recortada en círculo; anillo exterior dorado con greca/nubes pintado con CustomPainter, anillo interior del color `medal.color`; dos cintas rojas cortas colgando abajo. `errorBuilder`: fondo de aguada bermellón con `Icon(medal.icon)`.
- Bloqueado: ilustración en escala de grises (`ColorFiltered`), atenuada, anillo gris (`AppColors.line`) y candado pequeño en un sello oscuro. Desbloqueado: brillo dorado suave.
- Hoja Logros: fondo laca negra con título "Logros" en dorado sobre una cinta y contador `n / total`; rejilla de 3 columnas (`GridView`) con cada medallón y debajo el título (2 líneas máx., centrado). La equipada lleva una marca "装备" en sello rojo. Al tocar un logro desbloqueado se equipa/desequipa como ahora (`store.setFeaturedMedal`); al tocar uno bloqueado se muestra su descripción (SnackBar o tooltip). Mantén `ValueKey('equip-${medal.id}')` en el elemento tocable de cada logro desbloqueado.
- Botón `profile-achievements` del perfil: en vez de los puntitos, hasta 3 `AchievementMedal` pequeños (size 22) de los conseguidos.

## Criterios de aceptación
- [ ] `AchievementMedal` muestra `Image` con `AssetImage(medal.imageAsset)`; bloqueado envuelve en `ColorFiltered` y muestra `Icons.lock`.
- [ ] La hoja Logros muestra todos los logros en rejilla sin overflow a 375×812 (test con `tester.view.physicalSize`).
- [ ] Tocar un logro desbloqueado lo equipa y volver a tocarlo lo desequipa; `test/profile_test.dart` sigue pasando (ajústalo solo si cambia un texto, nunca quitando comprobaciones).

## Comando de verificación
`flutter test test/achievement_medal_test.dart test/profile_test.dart && flutter analyze lib test`

## Límite de pasos
25

## Dudas

## Resultado

Aprobada por `flutter test test/achievement_medal_test.dart test/profile_test.dart && flutter analyze lib test` en el peldaño 3 (gpt-6.1-sol medium).
