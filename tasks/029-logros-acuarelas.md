# 029 · Emblemas en acuarela de los logros

Estado: APROBADA
Peldaño inicial: 3
Revisión: no

## Objetivo
Generar con tu herramienta de generación de imágenes un emblema por logro, con el MISMO estilo que `assets/passives/*.png` (míralas: épico, China imperial, acuarela, bermellón/oro/jade/añil, nubes y olas tradicionales). Las imágenes de `tasks/refs/` son solo referencia de estilo: no copies ninguna.

## Archivos permitidos
- assets/achievements/*.png (nuevos)
- pubspec.yaml (solo añadir `- assets/achievements/`)
- lib/game/achievements.dart (solo añadir el getter `imageAsset`)
- test/achievement_assets_test.dart (nuevo)

## API
En `Achievement` añade `String get imageAsset`: los de bloque (`hsk1_bronze`, `hsk2_gold`…) usan `assets/achievements/block_<rank>.png` (compartido entre mazos); el resto `assets/achievements/<id>.png`. No cambies nada más del archivo.

## Emblemas (18 archivos)
- block_bronze / block_silver / block_gold: medallón de bronce / plata / oro con dragón en relieve, cintas rojas.
- level_2 Primer trazo: una gota de tinta y la primera pincelada.
- level_3 Aprendiz de escriba: joven escriba con pincel ante un rollo.
- level_5: farolillo encendido; level_10: puerta de pagoda; level_15 Letrado: erudito con gorro de examen imperial.
- level_20: pabellón dorado entre nubes; level_25 Mandarín: funcionario con túnica bordada y sombrero de alas.
- level_30 Gran secretario: escritorio imperial con sellos y rollos; level_40 Consejero imperial: consejero ante el trono del dragón.
- level_50 Hijo del Cielo: emperador majestuoso con corona mian sobre el ejército y la Gran Muralla (épico).
- solitaire_win: naipes antiguos y copa de jade; solitaire_100k: montaña de monedas de oro y lingotes.
- grammar_10: rollo con frases caligrafiadas; reading_perfect: libro cosido abierto con luz dorada.
- roulette_win: rueda de la fortuna lacada con dados de hueso.

## Formato
- Cuadrado 384×384, sujeto centrado dentro de un círculo imaginario (se recorta en círculo), sin texto ni marco.
- ≤ 150 KB cada uno (Pillow instalado; cuantiza/optimiza PNG).

## Criterios de aceptación
- [ ] Existe el `imageAsset` de TODOS los `achievements`, cada archivo ≤ 150 KB y cuadrado (cabecera PNG: ancho bytes 16-19, alto 20-23).
- [ ] `pubspec.yaml` declara `assets/achievements/` y `rootBundle.load` de cada uno funciona en test.
- [ ] `test/achievement_assets_test.dart` comprueba lo anterior recorriendo `achievements`; `test/achievements_test.dart` sigue pasando.

## Comando de verificación
`flutter test test/achievement_assets_test.dart test/achievements_test.dart && flutter analyze lib test`

## Límite de pasos
40

## Dudas
Si no tienes herramienta de generación de imágenes, NO dibujes sustitutos con código: escribe aquí "sin generación de imágenes" y para.

## Resultado

Aprobada por `flutter test test/achievement_assets_test.dart test/achievements_test.dart && flutter analyze lib test` en el peldaño 3 (gpt-6.1-sol medium).
