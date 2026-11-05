# 028 · Carta de pasiva estilo baraja imperial

Estado: APROBADA
Peldaño inicial: 3
Revisión: no

## Objetivo
Rediseñar `PassiveCard` como una carta épica de baraja china imperial (inspiración: cartas de tarot de `tasks/refs/7.jpg`, acuarelas de `tasks/refs/`), usando la ilustración en acuarela de cada pasiva (`assets/passives/<id>.png`, tarea 027). Debe verse bonita a 375 px de ancho sobre el tema negro de la app.

## Archivos permitidos
- lib/widgets/passive_card.dart
- lib/dynasty/shop_sheet.dart
- test/passive_card_test.dart

PROHIBIDO tocar la tarjeta de papiro de memorizar (flashcards), `lib/theme.dart` y cualquier otro widget: solo la carta de pasiva.

## Diseño
- Tamaño igual: 150×220. Marco de laca negra con doble filete dorado (`AppColors.gold`/`accentSoft`) y pequeños adornos en las esquinas (nubes o grecas dibujadas con CustomPainter).
- Color del filete interior según rareza (`PassiveRarity`): common bronce, uncommon jade (verde), rare oro, legendary bermellón con brillo dorado suave (BoxShadow).
- Arriba: ilustración ocupando ~60 % de la altura, recortada con esquinas suaves, con degradado inferior que funde la acuarela con el papel.
- Sobre la ilustración, arriba a la izquierda: el hanzi en un sello rojo (`AppColors.seal`) con letra clara; si el hanzi tiene 2 caracteres, en vertical.
- Abajo, sobre papel (`AppColors.paper`): nombre en una cinta/banda (negrita, tinta), descripción en 3 líneas máx. Precio como sello rojo rectangular abajo a la derecha (como ahora).
- `selected`: filete exterior más grueso y brillo dorado.
- Sin ilustración (`imageAsset == null`, p. ej. Gramática) o si falla la carga (`errorBuilder`): fondo de aguada acuarela pintada con CustomPainter (manchas suaves bermellón/añil sobre papel, usa `seed`) y el hanzi grande centrado, como ahora.

## API
- Nuevos parámetros opcionales: `String? imageAsset`, `PassiveRarity rarity = PassiveRarity.common`. Los demás no cambian (Gramática sigue compilando sin tocarla).
- `shop_sheet.dart` pasa `imageAsset: 'assets/passives/${passive.id}.png'` y `rarity: passive.rarity`.

## Criterios de aceptación
- [ ] Con `imageAsset`, la carta contiene un `Image` con ese `AssetImage`; sin él, no hay `Image` y se ve el hanzi.
- [ ] Mide 150×220 en ambos casos y no hay overflow con nombre/descripción largos (tests actuales de `passive_card_test.dart` siguen pasando).
- [ ] Test nuevo: el filete de una carta `legendary` y uno `common` usan colores distintos (expón el color por una `Key('passive-rarity-frame')` en un `Container`/`DecoratedBox` y compáralo).
- [ ] Los tests de tienda y Gramática siguen pasando.

## Comando de verificación
`flutter test test/passive_card_test.dart test/solitaire_screen_test.dart test/grammar_screen_test.dart && flutter analyze lib test`

## Límite de pasos
25

## Dudas

## Resultado

Aprobada por `flutter test test/passive_card_test.dart test/solitaire_screen_test.dart test/grammar_screen_test.dart && flutter analyze lib test` en el peldaño 3 (gpt-6.1-sol medium).
