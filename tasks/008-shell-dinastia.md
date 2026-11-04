# 008 · Shell Dinastía: 5 pestañas y barra superior

Estado: PENDIENTE
Peldaño inicial: 3
Revisión: no

## Objetivo
Navegación del Modo Dinastía y barra superior común (DISENO.md "UI").

## Archivos permitidos
- lib/dynasty/dynasty_shell.dart (nuevo)
- lib/widgets/top_bar.dart (nuevo)
- lib/main.dart (sustituir el placeholder de 007)
- test/dynasty_shell_test.dart (nuevo)

## Criterios de aceptación
- [ ] Barra inferior propia: Tarjetas, Hanziario, Perfil, Gramática, Lectura. Perfil es un botón circular central ~1.3× más grande.
- [ ] Pestañas sin implementar muestran un placeholder con su nombre. Hanziario reutiliza WordListScreen y Lectura ReadingScreen mientras tanto; Tarjetas reutiliza HomeScreen hasta 010.
- [ ] `TopBar`: nombre (izq.), círculo de medalla destacada (centro; gris vacío si no hay), "Nv N" + barra de XP con `progressOf` (der.). Se actualiza con el store. Oculta en Perfil.
- [ ] Widget test a 375 px: 5 destinos, cada uno cambia la vista, TopBar muestra nombre y nivel, sin overflow.

## Comando de verificación
`flutter test test/dynasty_shell_test.dart && flutter analyze lib test`

## Límite de pasos
20

## Dudas

## Resultado
