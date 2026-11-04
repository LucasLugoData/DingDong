import 'dart:math';

import 'package:flutter/material.dart';

import '../game/passives.dart';
import '../game/solitaire.dart';
import '../theme.dart';
import '../widgets/passive_card.dart';

class ShopSheet extends StatefulWidget {
  const ShopSheet({super.key, required this.run, required this.random,
    required this.onPurchase});

  final SolitaireRun run;
  final Random random;
  final VoidCallback onPurchase;

  @override
  State<ShopSheet> createState() => _ShopSheetState();
}

class _ShopSheetState extends State<ShopSheet> {
  late final _offers = rollShop(widget.random, widget.run.passives);
  final _bought = <String>{};

  @override
  Widget build(BuildContext context) {
    final run = widget.run;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Tienda', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text('${run.coins} monedas', key: const ValueKey('shop-coins'),
            style: const TextStyle(color: AppColors.gold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: List.generate(_offers.length, (index) {
                final passive = _offers[index];
                final bought = _bought.contains(passive.id);
                final canBuy = !bought && run.passives.length < 5 &&
                    run.coins >= run.priceOf(passive);
                return Padding(
                  padding: EdgeInsets.only(right: index == _offers.length - 1 ? 0 : 12),
                  child: Semantics(
                  label: 'Comprar ${passive.name}',
                  enabled: canBuy,
                  child: PassiveCard(
                    key: ValueKey('offer-${passive.id}'),
                    hanzi: passive.hanzi,
                    name: passive.name,
                    description: passive.description,
                    seed: index,
                    selected: bought,
                    price: bought ? 'Comprada' : '${run.priceOf(passive)} monedas',
                    onTap: canBuy ? () {
                      if (!run.buy(passive)) return;
                      setState(() => _bought.add(passive.id));
                      widget.onPurchase();
                    } : null,
                  ),
                  ),
                );
              })),
            ),
          ),
          const SizedBox(height: 12),
          Text('${run.passives.length}/5 pasivas'),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => Navigator.pop(context),
            child: const Text('Continuar')),
        ]),
      ),
    );
  }
}
