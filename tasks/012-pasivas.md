# 012 · Catálogo de pasivas

Estado: PENDIENTE
Peldaño inicial: 2
Revisión: no

## Objetivo
Pasivas estilo roguelike que premian acertar (fichas, mult, multMult, monedas), con nombres chinos antiguos.

## Archivos permitidos
- lib/game/passives.dart (nuevo)
- test/passives_test.dart (nuevo)

## Criterios de aceptación
- [ ] `Passive(id, hanzi, name, description, price, rarity)` implementando `PassiveHooks` de 011.
- [ ] Al menos 14 de Solitario: 毛笔 Pincel (+5 fichas), 算盘 Ábaco (+1 moneda por acierto), 印章 Sello imperial (multMult ×1.5), 龙 Dragón (multMult ×2 con racha ≥10), 长城 Muralla (al fallar el mult se reduce a la mitad en vez de a 1), 灯笼 Farol (el primer fallo tras cada tienda no rompe la racha), 茶 Té (+20 fichas cada 5º acierto seguido), 铜钱 Moneda de cobre (+1 mult por cada 5 monedas guardadas), 竹简 Tablilla (+2 mult con racha ≥5), 玉 Jade (+0.1 multMult permanente por cada racha de 10), 春秋 Anales (+8 fichas en palabras HSK3/4), 商人 Mercader (tienda −1 de precio), 孔子 Confucio (+15 fichas en palabras de 2+ caracteres), 凤凰 Fénix (+3 monedas al romperse una racha ≥5).
- [ ] `rollShop(random, owned)` → 3 pasivas distintas no poseídas, ponderadas por rareza.
- [ ] Gramática: `GrammarPerk(positive, negative)`; positivas +10/+25/+50% XP; negativas: +1 bola en el bombo, palabras más difíciles (más rojas), palabras menos comunes (HSK superior). `rollGrammarChoice(random)` → 2 opciones.
- [ ] Un test por pasiva contra `SolitaireRun`.

## Comando de verificación
`flutter test test/passives_test.dart test/solitaire_test.dart && flutter analyze lib test`

## Límite de pasos
25

## Dudas

## Resultado
