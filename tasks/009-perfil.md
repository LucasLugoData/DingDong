# 009 · Pantalla Perfil

Estado: APROBADA
Peldaño inicial: 2
Revisión: no

## Objetivo
Perfil del Modo Dinastía con logros, zona de mascota y opciones de cuenta.

## Archivos permitidos
- lib/dynasty/profile_screen.dart (nuevo)
- lib/widgets/mascot.dart (nuevo, CustomPaint)
- lib/dynasty/dynasty_shell.dart (solo enlazar la pestaña)
- test/profile_test.dart (nuevo)

## Criterios de aceptación
- [ ] Arriba izq.: nombre; debajo nivel y barra de XP con "faltan N XP". A la derecha del nombre: botón de logros con las medallas obtenidas (círculos de color).
- [ ] Pulsar logros abre una hoja con todas las medallas (obtenidas a color, bloqueadas oscuras) y permite elegir la destacada (`setFeaturedMedal`), la que se ve en la TopBar.
- [ ] Centro (zona más grande, Expanded): "Obra" con un monigote dibujado (futura mascota).
- [ ] Debajo: botón "Online" deshabilitado, "Próximamente".
- [ ] Más abajo: "Reiniciar cuenta" (confirmación → `resetAccount`, vuelve a bienvenida) y "Cambiar a modo libre".
- [ ] Widget test a 375 px: muestra nombre; elegir medalla destacada actualiza el store; reiniciar pide confirmación.

## Comando de verificación
`flutter test test/profile_test.dart && flutter analyze lib test`

## Límite de pasos
20

## Dudas

## Resultado

Aprobada: Codex dejó el perfil hecho; Claude arregló el overflow de home_screen (fila de puntos) que rompía el test.
