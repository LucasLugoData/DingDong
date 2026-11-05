class Praise {
  const Praise({required this.hanzi, required this.text, required this.tier});

  final String hanzi;
  final String text;
  final int tier;
}

Praise? praiseFor(int streak) {
  if (streak == 3) return const Praise(hanzi: '好', text: '¡Bien!', tier: 1);
  if (streak == 5) return const Praise(hanzi: '很好', text: '¡Muy bien!', tier: 2);
  if (streak == 10) return const Praise(hanzi: '太棒了', text: '¡Genial!', tier: 3);
  if (streak == 15) return const Praise(hanzi: '无敌', text: '¡Imparable!', tier: 4);
  if (streak >= 20 && streak % 10 == 0) {
    return const Praise(hanzi: '天子', text: '¡Imperial!', tier: 5);
  }
  return null;
}
