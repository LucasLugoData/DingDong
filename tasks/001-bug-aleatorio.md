# 001 · Bug: volver de aleatorio a abecedario

Estado: PENDIENTE
Peldaño inicial: 1
Revisión: no

## Objetivo
Al activar aleatorio, avanzar tarjetas y volver a orden por pinyin, la sesión salta a una tarjeta cualquiera. Debe volver
a la tarjeta en la que estabas en orden pinyin al activar aleatorio (o a la siguiente pendiente si esa ya se respondió).

## Archivos permitidos
- lib/session.dart
- test/session_test.dart (nuevo)

## Criterios de aceptación
- [ ] `StudySession` guarda la palabra ancla (la actual en orden pinyin) al pasar a aleatorio.
- [ ] Sin tracking: aleatorio → next() x5 → pinyin deja `current` == ancla.
- [ ] Con tracking: tras responder algunas en aleatorio y volver, `current` es la primera pendiente con sortKey >= ancla (orden pinyin) y el resto sigue ordenado; ninguna pendiente se pierde ni se duplica.
- [ ] Si se empezó en aleatorio (sin ancla) se mantiene el comportamiento actual.
- [ ] Tests con `Random(1)`.

## Comando de verificación
`flutter test test/session_test.dart test/srs_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado
