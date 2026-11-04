import 'package:flutter/material.dart';

import '../main.dart';
import '../models.dart';
import '../game/player.dart';
import '../theme.dart';
import 'study_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final total = store.statsOf(Deck.all);
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              sliver: SliverToBoxAdapter(child: _Header(stats: total)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
                  mainAxisExtent: 148,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildListDelegate([
                  for (final d in Deck.list) _DeckCard(deck: d),
                ]),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.stats});
  final ({int fresh, int learning, int known, int due}) stats;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFF9B5BFF)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('字', style: hanziStyle(24)),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Zìkǎ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text('字卡 · vocabulario HSK', style: TextStyle(color: AppColors.muted)),
            ],
          )),
          if (store.player.mode == AppMode.free)
            PopupMenuButton<AppMode>(
              tooltip: 'Menú',
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: AppMode.dynasty,
                  child: Text('Cambiar a Modo Dinastía'),
                ),
              ],
              onSelected: (_) => store.setMode(null),
            ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          _Stat(value: stats.due, label: 'Para hoy', color: AppColors.accentSoft),
          _Stat(value: stats.learning, label: 'En progreso', color: AppColors.orange),
          _Stat(value: stats.known, label: 'Conocidas', color: AppColors.green),
        ],
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    ),
  );
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.deck});
  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final s = store.statsOf(deck.id);
    final total = s.fresh + s.learning + s.known;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: total == 0
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => StudyScreen(deckId: deck.id)),
              ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(deck.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  if (s.due > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${s.due} hoy',
                          style: const TextStyle(
                              color: AppColors.accentSoft, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(deck.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              const Spacer(),
              _ProgressBar(fresh: s.fresh, learning: s.learning, known: s.known),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Dot(AppColors.green, '${s.known} conocidas'),
                  const SizedBox(width: 14),
                  _Dot(AppColors.orange, '${s.learning} en progreso'),
                  const Spacer(),
                  Text('$total', style: const TextStyle(color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fresh, required this.learning, required this.known});
  final int fresh, learning, known;

  @override
  Widget build(BuildContext context) {
    Widget seg(int n, Color c) =>
        n == 0 ? const SizedBox.shrink() : Expanded(flex: n, child: Container(color: c));
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 8,
        child: fresh + learning + known == 0
            ? Container(color: AppColors.line)
            : Row(children: [
                seg(known, AppColors.green),
                seg(learning, AppColors.orange),
                seg(fresh, AppColors.line),
              ]),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ],
  );
}
