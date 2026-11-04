import 'package:flutter/material.dart';

import '../game/achievements.dart';
import '../game/player.dart';
import '../game/xp.dart';
import '../main.dart' show store;
import '../theme.dart';
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
                    Wrap(spacing: 3, children: [for (final medal in earned.take(4))
                      CircleAvatar(radius: 6, backgroundColor: medal.color)]),
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
      builder: (context) => SafeArea(child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .78,
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) => Column(children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Logros',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            Expanded(child: ListView.builder(
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final medal = achievements[index];
                final unlocked = store.player.medals.contains(medal.id);
                final featured = store.player.featuredMedal == medal.id;
                final color = unlocked ? medal.color : AppColors.line;
                return ListTile(
                  leading: CircleAvatar(backgroundColor: color,
                    child: Icon(medal.icon, color: unlocked ? AppColors.bg : AppColors.muted)),
                  title: Text(medal.title, style: TextStyle(color: unlocked ? AppColors.text : AppColors.muted)),
                  subtitle: Text(medal.description),
                  trailing: unlocked ? Icon(featured ? Icons.star : Icons.star_border,
                    color: featured ? AppColors.gold : AppColors.muted) : const Icon(Icons.lock_outline),
                  onTap: unlocked ? () => store.setFeaturedMedal(featured ? null : medal.id) : null,
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
