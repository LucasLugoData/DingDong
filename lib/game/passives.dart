import 'dart:math';

import 'solitaire.dart';

enum PassiveRarity { common, uncommon, rare, legendary }

class Passive extends PassiveHooks {
  Passive(this.id, this.hanzi, this.name, this.description, this.price,
      this.rarity);

  final String id;
  final String hanzi;
  final String name;
  final String description;
  @override
  final int price;
  final PassiveRarity rarity;

  @override
  void onCorrect(SolitaireRun run) {
    if (id == 'wall' || id == 'lantern' || id == 'phoenix') _streak++;
    switch (id) {
      case 'brush': run.chips += 5;
      case 'abacus': run.coinsPerCorrect = 2;
      case 'seal': run.multMult *= 1.5;
      case 'dragon': if (run.mult >= 10) run.multMult *= 2;
      case 'tea': if ((run.mult) % 5 == 0) run.chips += 20;
      case 'copper_coin': if (run.coins >= 5) run.mult += run.coins ~/ 5;
      case 'bamboo': if (run.mult >= 5) run.mult += 2;
      case 'jade':
        _streak++;
        if (_streak % 10 == 0) run.multMult += 0.1;
      case 'spring_autumn':
        if (run.current?.deck == 'hsk3' || run.current?.deck == 'hsk4') {
          run.chips += 8;
        }
      case 'confucius':
        if ((run.current?.hanzi.runes.length ?? 0) >= 2) run.chips += 15;
      case 'phoenix': break;
    }
  }

  int _streak = 0;
  bool _lanternReady = false;
  bool _lanternUsed = false;

  @override
  void onWrong(SolitaireRun run) {
    switch (id) {
      case 'wall':
        run.mult = max(1, (_streak + 2) ~/ 2);
        _streak = 0;
      case 'lantern':
        if (_lanternReady && !_lanternUsed) {
          run.mult = max(1, _streak + 1);
          _lanternUsed = true;
        } else {
          _streak = 0;
        }
      case 'phoenix':
        if (_streak >= 5) run.coins += 3;
        _streak = 0;
      case 'jade': _streak = 0;
    }
  }

  @override
  void onShop(SolitaireRun run) {
    if (id == 'lantern') {
      _lanternReady = true;
      _lanternUsed = false;
    }
  }

  @override
  int priceModifier(int price) => id == 'merchant' ? price - 1 : price;
}

final passiveCatalog = <Passive>[
  Passive('brush', '毛笔', 'Pincel', '+5 fichas por acierto', 4, PassiveRarity.common),
  Passive('abacus', '算盘', 'Ábaco', '+1 moneda por acierto', 5, PassiveRarity.common),
  Passive('seal', '印章', 'Sello imperial', 'multMult ×1.5', 8, PassiveRarity.rare),
  Passive('dragon', '龙', 'Dragón', 'multMult ×2 con racha ≥10', 12, PassiveRarity.legendary),
  Passive('wall', '长城', 'Muralla', 'Al fallar, conserva la mitad del mult', 9, PassiveRarity.rare),
  Passive('lantern', '灯笼', 'Farol', 'El primer fallo tras cada tienda conserva la racha', 8, PassiveRarity.rare),
  Passive('tea', '茶', 'Té', '+20 fichas cada 5º acierto seguido', 6, PassiveRarity.uncommon),
  Passive('copper_coin', '铜钱', 'Moneda de cobre', '+1 mult por cada 5 monedas', 7, PassiveRarity.uncommon),
  Passive('bamboo', '竹简', 'Tablilla', '+2 mult con racha ≥5', 7, PassiveRarity.uncommon),
  Passive('jade', '玉', 'Jade', '+0.1 multMult permanente por racha de 10', 14, PassiveRarity.legendary),
  Passive('spring_autumn', '春秋', 'Anales', '+8 fichas en HSK3/4', 5, PassiveRarity.uncommon),
  Passive('merchant', '商人', 'Mercader', 'Tienda −1 de precio', 10, PassiveRarity.rare),
  Passive('confucius', '孔子', 'Confucio', '+15 fichas en palabras de 2+ caracteres', 6, PassiveRarity.uncommon),
  Passive('phoenix', '凤凰', 'Fénix', '+3 monedas al romper racha ≥5', 11, PassiveRarity.rare),
];

List<Passive> rollShop(Random random, List<PassiveHooks> owned) {
  final excluded = owned.whereType<Passive>().map((p) => p.id).toSet();
  final pool = passiveCatalog.where((p) => !excluded.contains(p.id)).toList();
  final result = <Passive>[];
  while (result.length < 3 && pool.isNotEmpty) {
    final weights = pool.map((p) => switch (p.rarity) {
      PassiveRarity.common => 8,
      PassiveRarity.uncommon => 5,
      PassiveRarity.rare => 2,
      PassiveRarity.legendary => 1,
    }).toList();
    final total = weights.reduce((a, b) => a + b);
    var choice = random.nextInt(total);
    var index = 0;
    while (choice >= weights[index]) {
      choice -= weights[index++];
    }
    result.add(pool.removeAt(index));
  }
  return result;
}

class GrammarPerk {
  const GrammarPerk(this.positive, this.negative);
  final String positive;
  final String negative;

  static const positives = ['+10% XP', '+25% XP', '+50% XP'];
  static const negatives = [
    '+1 bola en el bombo',
    'Palabras más difíciles (más rojas)',
    'Palabras menos comunes (HSK superior)',
  ];
}

List<GrammarPerk> rollGrammarChoice(Random random) {
  final positives = List<String>.of(GrammarPerk.positives)..shuffle(random);
  final negatives = List<String>.of(GrammarPerk.negatives)..shuffle(random);
  return [GrammarPerk(positives[0], negatives[0]), GrammarPerk(positives[1], negatives[1])];
}
