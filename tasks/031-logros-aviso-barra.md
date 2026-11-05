# 031 · Aviso de logro y medalla de la barra con el medallón imperial

Estado: PENDIENTE
Peldaño inicial: 2
Revisión: no

## Objetivo
Usar `AchievementMedal` (`lib/widgets/achievement_medal.dart`, tarea 030) en el aviso "¡Logro conseguido!" y en la medalla destacada de la barra superior.

## Archivos permitidos
- lib/main.dart (solo `showMedalToast`)
- lib/widgets/top_bar.dart
- test/dynasty_shell_test.dart

## Criterios de aceptación
- [ ] `showMedalToast`: SnackBar con fondo laca negra y filete dorado (borde `AppColors.gold`), `AchievementMedal(size: 48, unlocked: true)`, "¡Logro conseguido!" en dorado y el título debajo.
- [ ] Barra superior: el `Container` con `ValueKey('featured-medal')` (40×40) contiene `AchievementMedal(size: 40)` de la medalla destacada; sin medalla, círculo gris como ahora.
- [ ] Los tests existentes siguen pasando; añade en `test/dynasty_shell_test.dart` una comprobación de que con medalla destacada hay un `AchievementMedal` dentro de `featured-medal`.

## Comando de verificación
`flutter test test/dynasty_shell_test.dart test/profile_test.dart && flutter analyze lib test`

## Límite de pasos
12

## Dudas

## Resultado
