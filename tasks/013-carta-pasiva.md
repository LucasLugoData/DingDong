# 013 · Widget de carta de pasiva (estética antigua china)

Estado: APROBADA
Peldaño inicial: 2
Revisión: no

## Objetivo
Carta reutilizable para la tienda de Solitario y la elección de Gramática (DISENO.md "Estética de pasivas").

## Archivos permitidos
- lib/widgets/passive_card.dart (nuevo)
- test/passive_card_test.dart (nuevo)

## Criterios de aceptación
- [ ] Fondo de papel/papiro (`paper`) con fibras y bordes irregulares (CustomPaint); marco de pincel en `ink`.
- [ ] Boceto aleatorio por carta (semilla): montañas a tinta, muro agrietado o rollo de bambú; trazos finos, baja opacidad.
- [ ] Hanzi grande en tinta, nombre en español, descripción, sello rojo (`seal`) con precio o rareza.
- [ ] `PassiveCard({hanzi, name, description, String? price, bool selected = false, VoidCallback? onTap, int seed = 0})` (no depende de 012).
- [ ] ~150×220; tres caben con scroll horizontal a 375 px.
- [ ] Widget test: renderiza sin overflow y onTap funciona.

## Comando de verificación
`flutter test test/passive_card_test.dart && flutter analyze lib test`

## Límite de pasos
15

## Dudas

## Resultado

Aprobada tras arreglos de Claude/Sonnet: suite completa 141 tests OK y analyze limpio.
