# 007 · Bienvenida: elegir modo y nombre

Estado: APROBADA
Peldaño inicial: 2
Revisión: no

## Objetivo
Primer arranque (player.mode == null): elegir "Modo libre" (app actual) o "Modo Dinastía" (progresión por niveles) y nombre.

## Archivos permitidos
- lib/screens/onboarding_screen.dart (nuevo)
- lib/main.dart
- lib/screens/home_screen.dart (solo un botón de menú "Cambiar a Modo Dinastía" en modo libre)
- test/onboarding_test.dart (nuevo)

## Criterios de aceptación
- [ ] Dos tarjetas grandes con descripción corta; Modo Dinastía pide nombre (obligatorio, máx. 16 caracteres).
- [ ] main.dart: mode null → Onboarding; free → Shell actual; dynasty → `DynastyShell` (si no existe aún, placeholder `Scaffold` "Modo Dinastía"; 008 lo sustituye).
- [ ] El cambio de modo se escucha del store (sin reiniciar la app).
- [ ] Widget test a 375 px: elegir libre → aparece la NavigationBar actual; Dinastía sin nombre → no avanza; con nombre → guarda nombre y modo.

## Comando de verificación
`flutter test test/onboarding_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado

Aprobada por `flutter test test/onboarding_test.dart && flutter analyze lib test` en el peldaño 5 (gpt-6-astra high).
