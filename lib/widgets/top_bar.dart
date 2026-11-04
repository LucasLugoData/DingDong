import 'package:flutter/material.dart';

import '../game/achievements.dart';
import '../game/xp.dart';
import '../main.dart' show store;
import '../theme.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.bg,
    child: SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final player = store.player;
            final progress = progressOf(player.xp);
            final medal = achievements
                .where((medal) => medal.id == player.featuredMedal)
                .firstOrNull;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Semantics(
                      label: medal?.title ?? 'Sin medalla destacada',
                      image: true,
                      child: Container(
                        key: const ValueKey('featured-medal'),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: medal?.color ?? Colors.grey,
                        ),
                        child: medal == null
                            ? null
                            : Icon(medal.icon, color: AppColors.bg),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Nv ${progress.level}'),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress.xpEnNivel / progress.xpNecesaria,
                          semanticsLabel:
                              'Experiencia: ${progress.xpEnNivel} de ${progress.xpNecesaria} XP',
                          color: AppColors.gold,
                          backgroundColor: AppColors.line,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
