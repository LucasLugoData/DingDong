# 002 · Contador central de la sesión fijo

Estado: APROBADA
Peldaño inicial: 1
Revisión: no

## Objetivo
Al marcar una palabra "en progreso" (izquierda) se reinserta en la cola y el total del contador central sube (+1).
El total no debe crecer: el contador es "palabras distintas resueltas / palabras distintas de la sesión".

## Archivos permitidos
- lib/session.dart
- lib/screens/study_screen.dart
- test/session_test.dart

## Criterios de aceptación
- [ ] `StudySession` expone `total` (palabras distintas al crear la sesión, fijo) y `position` (1-based, nunca > total).
- [ ] Fallar no cambia `total`; las pastillas En progreso / Conocida siguen como ahora.
- [ ] study_screen usa `position / total` en contador y barra (no `queue.length`).
- [ ] Test: sesión de 5 con tracking, fallar 2 veces → total sigue en 5.

## Comando de verificación
`flutter test test/session_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado

Aprobada por `flutter test test/session_test.dart && flutter analyze lib test` en el peldaño 1 (gpt-6-luna low).
