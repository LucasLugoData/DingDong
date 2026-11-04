# 026 · Cierre: suite completa y compilación

Estado: APROBADA
Peldaño inicial: 1
Revisión: no

## Objetivo
Comprobar que todo compila y pasa, y generar builds para capturas e instalación como actualización.

## Archivos permitidos
- Solo arreglos mínimos de analyze/test en archivos de tareas anteriores.

## Criterios de aceptación
- [ ] Suite completa en verde y analyze sin errores.
- [ ] `flutter build web` y `flutter build apk --release` funcionan con versión 1.1.0+2 y applicationId `com.ariel.dingdong`.

## Comando de verificación
`flutter test && flutter analyze lib test && flutter build web && flutter build apk --release`

## Límite de pasos
15

## Dudas

## Resultado

Aprobada: 141 tests OK, analyze limpio, build web y APK release OK.
