import 'package:flutter/material.dart';

import '../game/fusion.dart';
import '../game/mastery.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';

class FusionScreen extends StatefulWidget {
  const FusionScreen({super.key});

  @override
  State<FusionScreen> createState() => _FusionScreenState();
}

class _FusionScreenState extends State<FusionScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Fusión')),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final words = store.wordsOf(Deck.all);
          final combinations = _selected == null
              ? fusions(words)
              : fusionsOf(_selected!, words);
          final basics = words.where((word) => word.hanzi.runes.length == 1).toList();
          return Column(children: [
            SizedBox(
              height: 86,
              child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), children: [
                for (final word in basics)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(word.hanzi, style: hanziStyle(22).copyWith(color: _color(word))),
                      selected: _selected == word.hanzi,
                      onSelected: (_) => setState(() => _selected = _selected == word.hanzi ? null : word.hanzi),
                    ),
                  ),
              ]),
            ),
            Expanded(
              child: combinations.isEmpty
                  ? const Center(child: Text('No hay fusiones para mostrar', style: TextStyle(color: AppColors.muted)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: combinations.length,
                      itemBuilder: (context, index) => _FusionCard(
                        fusion: combinations[index],
                        colorOf: _color,
                        onSelect: (char) => setState(() => _selected = char),
                      ),
                    ),
            ),
          ]);
        },
      ),
    ),
  );

  Color _color(Word word) {
    final stats = store.player.wordStats[word.id] ?? (hits: 0, misses: 0);
    return masteryOf(stats.hits, stats.misses).color;
  }
}

class _FusionCard extends StatelessWidget {
  const _FusionCard({required this.fusion, required this.colorOf, required this.onSelect});
  final Fusion fusion;
  final Color Function(Word) colorOf;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.surface,
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 7, runSpacing: 5, children: [
          for (var i = 0; i < fusion.parts.length; i++) ...[
            if (i > 0) const Text('+', style: TextStyle(color: AppColors.muted, fontSize: 20)),
            InkWell(onTap: () => onSelect(fusion.parts[i].hanzi), child: Text(fusion.parts[i].hanzi, style: hanziStyle(28).copyWith(color: colorOf(fusion.parts[i])))),
          ],
          const Text('=', style: TextStyle(color: AppColors.muted, fontSize: 20)),
          Text(fusion.word.hanzi, style: hanziStyle(28)),
        ]),
        const SizedBox(height: 8),
        for (final part in fusion.parts)
          Text('${part.hanzi} · ${part.pinyin} · ${part.meaning}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const Divider(height: 16),
        Text('${fusion.word.pinyin} · ${fusion.word.meaning}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}
