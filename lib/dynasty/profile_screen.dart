import 'package:flutter/material.dart';

import '../game/achievements.dart';
import '../game/player.dart';
import '../game/xp.dart';
import '../main.dart' show store;
import '../theme.dart';
import '../widgets/achievement_medal.dart';
import '../widgets/mascot.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final player = store.player;
        final progress = progressOf(player.xp);
        final earned = achievements.where((medal) => player.medals.contains(medal.id)).toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 7),
                  Text('Nivel ${progress.level}', style: const TextStyle(color: AppColors.accentSoft)),
                  const SizedBox(height: 6),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                    value: progress.xpEnNivel / progress.xpNecesaria,
                    minHeight: 8, color: AppColors.gold, backgroundColor: AppColors.line,
                  )),
                  const SizedBox(height: 4),
                  Text('faltan ${progress.xpNecesaria - progress.xpEnNivel} XP',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ])),
                const SizedBox(width: 8),
                InkWell(
                  key: const ValueKey('profile-achievements'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showAchievements(context),
                  child: Padding(padding: const EdgeInsets.all(8), child: Column(children: [
                    const Icon(Icons.workspace_premium_outlined, color: AppColors.gold),
                    const SizedBox(height: 6),
                    Wrap(spacing: 3, children: [for (final medal in earned.take(3))
                      AchievementMedal(medal: medal, unlocked: true, size: 22)]),
                  ])),
                ),
              ]),
              const SizedBox(height: 14),
              Expanded(child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Obra', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Expanded(child: Center(child: Mascot())),
                  const Padding(padding: EdgeInsets.only(bottom: 18), child: Text('Tu mascota llegará pronto',
                    style: TextStyle(color: AppColors.muted))),
                ]),
              )),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.cloud_outlined),
                label: const Text('Online · Próximamente'),
              ),
              const SizedBox(height: 4),
              TextButton(onPressed: () => _confirmReset(context),
                child: const Text('Reiniciar cuenta', style: TextStyle(color: AppColors.red))),
              TextButton(onPressed: () => store.setMode(AppMode.free),
                child: const Text('Cambiar a modo libre')),
            ],
          ),
        );
      },
    ),
  );

  Future<void> _showAchievements(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101213),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.accentSoft),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) => SafeArea(child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .78,
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) => Column(children: [
            Container(
              margin: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFF281614), AppColors.seal, Color(0xFF281614),
                ]),
                border: Border.all(color: AppColors.accentSoft, width: .7),
              ),
              child: const Text('Logros', textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gold, fontSize: 24,
                  fontWeight: FontWeight.bold, letterSpacing: 3)),
            ),
            Text('${achievements.where((medal) => store.player.medals.contains(medal.id)).length} / ${achievements.length}',
              style: const TextStyle(color: AppColors.accentSoft, fontSize: 13)),
            const SizedBox(height: 12),
            Expanded(child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisExtent: 144,
                crossAxisSpacing: 8, mainAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final medal = achievements[index];
                final unlocked = store.player.medals.contains(medal.id);
                final featured = store.player.featuredMedal == medal.id;
                return Tooltip(
                  message: medal.description,
                  triggerMode: TooltipTriggerMode.tap,
                  child: Semantics(
                    button: true,
                    selected: featured,
                    child: InkWell(
                      key: unlocked ? ValueKey('equip-${medal.id}') : null,
                      borderRadius: BorderRadius.circular(8),
                      onTap: unlocked
                        ? () => store.setFeaturedMedal(featured ? null : medal.id)
                        : null,
                      child: Column(children: [
                        Stack(children: [
                          AchievementMedal(medal: medal, unlocked: unlocked),
                          if (featured)
                            Positioned(
                              right: 0, bottom: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.seal,
                                  border: Border.all(color: AppColors.accentSoft, width: .6),
                                ),
                                child: const Text('装备', style: TextStyle(
                                  color: AppColors.paper, fontSize: 11,
                                  fontFamilyFallback: cjkFallback)),
                              ),
                            ),
                        ]),
                        const SizedBox(height: 6),
                        Text(medal.title, maxLines: 2,
                          overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, height: 1.25,
                            color: unlocked ? AppColors.paper : AppColors.muted)),
                      ]),
                    ),
                  ),
                );
              },
            )),
          ]),
        ),
      )),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar cuenta'),
        content: const Text('Se borrará tu progreso y volverás a la bienvenida. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reiniciar')),
        ],
      ),
    );
    if (confirmed == true) store.resetAccount();
  }
}
