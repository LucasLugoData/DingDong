# 017 · Submodo Fusión

Estado: PENDIENTE
Peldaño inicial: 2
Revisión: no

## Objetivo
Ver cómo sinogramas básicos del vocabulario se combinan en palabras más complejas también del vocabulario.

## Archivos permitidos
- lib/game/fusion.dart (nuevo, puro)
- lib/dynasty/fusion_screen.dart (nuevo)
- lib/screens/word_list_screen.dart (solo abrir FusionScreen)
- test/fusion_test.dart (nuevo)

## Criterios de aceptación
- [ ] `fusions(List<Word>)` → por cada palabra de 2+ caracteres, sus componentes de 1 carácter que también son palabras del vocabulario; solo si existen al menos 2 (p. ej. 大 + 学 = 大学).
- [ ] `fusionsOf(char)` filtra las que contienen ese carácter.
- [ ] UI: fila superior con los caracteres básicos (con color de dominio); debajo tarjetas "大 + 学 = 大学" con pinyin y significado de partes y resultado; tocar un carácter filtra.
- [ ] Test con vocabulario de ejemplo.

## Comando de verificación
`flutter test test/fusion_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado
