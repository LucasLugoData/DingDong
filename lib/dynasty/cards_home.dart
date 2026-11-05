import 'package:flutter/material.dart';

import '../game/achievements.dart';
import '../game/xp.dart';
import '../main.dart';
import '../models.dart';
import '../screens/study_screen.dart';
import '../theme.dart';
import 'solitaire_screen.dart';

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
        ...Deck.list.where((d) => d.id.startsWith('hsk')),
        ...Deck.list.where((d) => d.id == Deck.custom || d.id == Deck.favorites),
        Deck(Deck.all, 'Todo', 'Todas las tarjetas vistas y las propias'),
      ];
      final solitaireXp = unlockXp('hsk2', sizes);
      final seenWords = [...store.allWords.where((w) => seen.contains(w.id))]
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SolitaireBanner(
            seenCount: seenWords.length,
            locked: store.player.xp < solitaireXp,
            requiredXp: solitaireXp,
            onOpen: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SolitaireScreen(words: seenWords),
            )),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 18, 4, 8),
            child: Text('Estudio por bloques',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.muted)),
          ),
          for (final deck in decks)
            _Block(
              deck: deck,
              words: deck.id == Deck.all ? all : store.wordsOf(deck.id),
              locked: deck.id.startsWith('hsk') && deck.id != 'hsk1' && store.player.xp < unlockXp(deck.id, sizes),
              requiredXp: unlockXp(deck.id, sizes),
              onOpen: () => _openProgress(context, deck, deck.id == Deck.all ? all : store.wordsOf(deck.id)),
            ),
        ],
      );
    },
  );

  void _openProgress(BuildContext context, Deck deck, List<Word> words) {
    var earnedXp = 0;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudyScreen(
      deckId: deck.id,
      words: words,
      onAnswer: (word, correct) {
        earnedXp += xpPerProgressAnswer(correct);
        if (!word.isCustom) store.recordAnswer(word.id, correct, see: true);
      },
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

/// Apartado especial: Solitario con todas las palabras vistas.
class _SolitaireBanner extends StatelessWidget {
  const _SolitaireBanner({required this.seenCount, required this.locked, required this.requiredXp, required this.onOpen});
  final int seenCount;
  final bool locked;
  final int requiredXp;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final enabled = !locked && seenCount > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('solitaire-banner'),
        onTap: enabled ? onOpen : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: locked ? AppColors.surface : AppColors.seal,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gold.withValues(alpha: locked ? .25 : .9), width: 2),
          ),
          child: Row(children: [
            Text('龍', style: hanziStyle(44).copyWith(
              color: locked ? AppColors.muted : AppColors.gold)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SOLITARIO', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2,
                color: locked ? AppColors.muted : AppColors.paper)),
              const SizedBox(height: 4),
              Text(
                locked ? 'Desbloquea con $requiredXp XP'
                  : seenCount == 0 ? 'Descubre palabras en los bloques para jugar'
                  : 'Con tus $seenCount palabras vistas',
                style: TextStyle(color: locked ? AppColors.muted : AppColors.paper.withValues(alpha: .85))),
            ])),
            Icon(locked ? Icons.lock_outline : Icons.play_arrow_rounded,
              color: locked ? AppColors.muted : AppColors.gold, size: 32),
          ]),
        ),
      ),
    );
  }
}
