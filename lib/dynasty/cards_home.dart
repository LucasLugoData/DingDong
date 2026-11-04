import 'package:flutter/material.dart';

import '../game/achievements.dart';
import '../game/xp.dart';
import '../main.dart';
import '../models.dart';
import '../screens/study_screen.dart';
import '../theme.dart';

class CardsHome extends StatelessWidget {
  const CardsHome({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final sizes = {for (final entry in store.wordIdsByDeck.entries) entry.key: entry.value.length};
      final seen = store.player.seen;
      final all = [...store.allWords.where((w) => w.isCustom || seen.contains(w.id))]
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
      final decks = [
        Deck(Deck.all, 'Todo', 'Todas las tarjetas vistas y las propias'),
        ...Deck.list.where((d) => d.id.startsWith('hsk')),
        ...Deck.list.where((d) => d.id == Deck.custom || d.id == Deck.favorites),
      ];
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Vistas: ${store.player.seen.length}', style: const TextStyle(color: AppColors.muted)),
          ),
          for (final deck in decks)
            _Block(
              deck: deck,
              words: deck.id == Deck.all ? all : store.wordsOf(deck.id),
              locked: deck.id.startsWith('hsk') && deck.id != 'hsk1' && store.player.xp < unlockXp(deck.id, sizes),
              requiredXp: unlockXp(deck.id, sizes),
              onOpen: () => _chooseMode(context, deck, deck.id == Deck.all ? all : store.wordsOf(deck.id)),
            ),
        ],
      );
    },
  );

  void _chooseMode(BuildContext context, Deck deck, List<Word> words) {
    final threshold = unlockXp('hsk2', {
      for (final entry in store.wordIdsByDeck.entries) entry.key: entry.value.length,
    });
    if (store.player.xp < threshold) {
      _openProgress(context, deck, words);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: const Text('Progreso'), leading: const Icon(Icons.trending_up), onTap: () {
            Navigator.pop(sheetContext);
            _openProgress(context, deck, words);
          }),
          ListTile(title: const Text('Solitario'), leading: const Icon(Icons.style), onTap: () {
            Navigator.pop(sheetContext);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente')));
          }),
        ]),
      ),
    );
  }

  void _openProgress(BuildContext context, Deck deck, List<Word> words) {
    var earnedXp = 0;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudyScreen(
      deckId: deck.id,
      words: words,
      onAnswer: (_, correct) => earnedXp += xpPerProgressAnswer(correct),
      onFinish: () {
        store.grantXp('cards', earnedXp);
        for (final id in evaluate(store.player, store.wordIdsByDeck)) {
          store.unlockMedal(id);
        }
      },
    )));
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.deck, required this.words, required this.locked, required this.requiredXp, required this.onOpen});
  final Deck deck;
  final List<Word> words;
  final bool locked;
  final int requiredXp;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final hsk = deck.id.startsWith('hsk');
    final medals = hsk ? blockMedals(deck.id) : const <Achievement>[];
    return Card(
      color: locked ? AppColors.surface.withValues(alpha: .45) : AppColors.surface,
      child: InkWell(
        onTap: locked ? null : onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (locked) const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.lock_outline, color: AppColors.muted)),
              Expanded(child: Text(deck.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: locked ? AppColors.muted : AppColors.text))),
              if (hsk) ...[
                for (final medal in medals)
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Icon(Icons.circle, size: 13, color: store.player.medals.contains(medal.id) ? medal.color : AppColors.bg),
                  ),
              ],
            ]),
            const SizedBox(height: 6),
            Text(locked ? 'Desbloquea con $requiredXp XP' : '${words.length} tarjetas', style: const TextStyle(color: AppColors.muted)),
          ]),
        ),
      ),
    );
  }
}
