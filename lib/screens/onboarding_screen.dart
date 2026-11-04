import 'package:flutter/material.dart';

import '../game/player.dart';
import '../main.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: store.player.name);

  void _startDynasty() {
    if (!_formKey.currentState!.validate()) return;
    store.setName(_name.text.trim());
    store.setMode(AppMode.dynasty);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Elige cómo aprender', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                _ModeCard(
                  title: 'Modo libre',
                  description: 'Estudia a tu ritmo con todos los mazos.',
                  icon: Icons.style,
                  onTap: () => store.setMode(AppMode.free),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.account_tree, size: 32, color: AppColors.accentSoft),
                          const SizedBox(height: 8),
                          const Text('Modo Dinastía', textAlign: TextAlign.center, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          const Text('Avanza por niveles y construye tu progreso.', textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _name,
                            maxLength: 16,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(labelText: 'Tu nombre'),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Escribe tu nombre'
                                : null,
                            onFieldSubmitted: (_) => _startDynasty(),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(onPressed: _startDynasty, child: const Text('Empezar Modo Dinastía')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.title, required this.description, required this.icon, required this.onTap});
  final String title, description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [Icon(icon, size: 36, color: AppColors.accentSoft), const SizedBox(height: 8), Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(description, textAlign: TextAlign.center)]),
      ),
    ),
  );
}
