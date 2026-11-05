# 027 · Ilustraciones en acuarela de las 14 pasivas

Estado: APROBADA
Peldaño inicial: 3
Revisión: no

## Objetivo
Generar con tu herramienta de generación de imágenes una ilustración por pasiva de `passiveCatalog` (`lib/game/passives.dart`): estilo **épico, China imperial, acuarela** (tinta y aguada, papel de arroz, rojos bermellón, oro, jade, azul añil; nubes y olas tradicionales, ambiente de leyenda). Las imágenes de `tasks/refs/` son SOLO referencia de estilo y composición (dragón entre nubes, emperador sobre ejército, pagoda con cerezo, cartas de tarot con marco): no copies ninguna, ni texto, ni marcas de agua, ni personajes concretos.

## Archivos permitidos
- assets/passives/*.png (nuevos)
- pubspec.yaml (solo añadir `- assets/passives/` en `flutter: assets:`)
- test/passive_assets_test.dart (nuevo)

## Motivo de cada ilustración (id → escena)
- brush 毛笔: pincel de caligrafía sobre tintero, trazo de tinta que se convierte en río.
- abacus 算盘: ábaco de madera lacada con monedas de oro en un despacho imperial.
- seal 印章: sello imperial de jade rojo con dragón tallado, impresión bermellón.
- dragon 龙: dragón rojo y dorado serpenteando entre nubes y olas con perla luminosa.
- wall 长城: la Gran Muralla sobre montañas brumosas al amanecer.
- lantern 灯笼: farolillos rojos encendidos flotando de noche sobre un palacio.
- tea 茶: tetera de barro y taza humeante, hojas de té, pabellón al fondo.
- copper_coin 铜钱: monedas de cobre con agujero cuadrado ensartadas en cordón rojo.
- bamboo 竹简: tablillas de bambú atadas con texto antiguo, bosque de bambú.
- jade 玉: disco bi de jade verde brillando sobre seda.
- spring_autumn 春秋: rollo de anales desplegado, mitad cerezo en flor, mitad hojas otoñales.
- merchant 商人: mercader con túnica y caravana en la Ruta de la Seda.
- confucius 孔子: sabio anciano con túnica y rollo, bajo un pino.
- phoenix 凤凰: fénix de fuego naranja y oro renaciendo de las llamas.

## Formato
- Un archivo por id: `assets/passives/<id>.png`, vertical 3:4 (p. ej. 384×512), sin texto ni bordes (el marco lo pinta la app), sujeto centrado y fondo que llegue a los bordes.
- Reduce cada una a ≤ 200 KB (Pillow está instalado: `python -c "from PIL import Image..."`, cuantiza/optimiza PNG).
- Paleta y trazo coherentes entre las 14: que parezcan de la misma baraja.

## Criterios de aceptación
- [ ] Existe `assets/passives/<id>.png` para TODOS los ids de `passiveCatalog`, cada uno ≤ 200 KB y con proporción alto/ancho entre 1.25 y 1.4.
- [ ] `pubspec.yaml` declara `assets/passives/` y `rootBundle.load('assets/passives/<id>.png')` funciona en test.
- [ ] Test `test/passive_assets_test.dart` comprueba los dos puntos anteriores recorriendo `passiveCatalog` (tamaño y proporción leyendo la cabecera PNG: ancho bytes 16-19, alto 20-23).

## Comando de verificación
`flutter test test/passive_assets_test.dart && flutter analyze lib test`

## Límite de pasos
40

## Dudas
Si no tienes herramienta de generación de imágenes, NO dibujes sustitutos con código: escribe aquí "sin generación de imágenes" y para.

## Resultado

Aprobada por `flutter test test/passive_assets_test.dart && flutter analyze lib test` en el peldaño 3 (gpt-6.1-sol medium).
