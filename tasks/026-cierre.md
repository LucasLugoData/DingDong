# 026 · Cierre: suite completa y compilación

Estado: BLOQUEADA
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

Mismo error en dos peldaños seguidos: revisa el comando de verificación antes de reintentar.
```
Tiempo agotado (600 s)
00:17 +115 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:17 +116 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:17 +117 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:17 +118 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:18 +119 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:18 +120 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:18 +121 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:18 +122 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:18 +123 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:18 +124 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:18 +125 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: a 375 px: 20 respuestas abren tienda y comprar descuenta monedas
00:19 +126 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/word_list_test.dart: ordena por fallos y pinta de rojo en Dinastía
00:22 +126 -11: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: deslizar, girar, cuatro tiendas y demostración tras 100 respuestas
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: null
  Actual: FlutterError:<A RenderFlex overflowed by 3.8 pixels on the right.>

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart:97:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart line 97
The test description was:
  deslizar, girar, cuatro tiendas y demostración tras 100 respuestas
════════════════════════════════════════════════════════════════════════════════════════════════════
00:22 +126 -12: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/word_list_test.dart: ordena por fallos y pinta de rojo en Dinastía
00:22 +126 -12: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/solitaire_screen_test.dart: deslizar, girar, cuatro tiendas y demostración tras 100 respuestas [E]
  Test failed. See exception logs above.
  The test description was: deslizar, girar, cuatro tiendas y demostración tras 100 respuestas
  
00:22 +127 -12: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/word_list_test.dart: ordena por fallos y pinta de rojo en Dinastía
00:23 +128 -12: C:/Users/Ariel/OneDrive/Escritorio/DingDong/test/word_list_test.dart: ordena por fallos y pinta de rojo en Dinastía
```
