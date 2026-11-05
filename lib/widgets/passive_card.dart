import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/passives.dart';
import '../theme.dart';

/// Carta imperial con ilustración, sello y marco de laca.
class PassiveCard extends StatelessWidget {
  const PassiveCard({
    super.key,
    required this.hanzi,
    required this.name,
    required this.description,
    this.price,
    this.selected = false,
    this.onTap,
    this.seed = 0,
    this.imageAsset,
    this.rarity = PassiveRarity.common,
  });

  final String hanzi;
  final String name;
  final String description;
  final String? price;
  final bool selected;
  final VoidCallback? onTap;
  final int seed;
  final String? imageAsset;
  final PassiveRarity rarity;

  Color get _rarityColor => switch (rarity) {
    PassiveRarity.common => AppColors.bronze,
    PassiveRarity.uncommon => const Color(0xFF478C70),
    PassiveRarity.rare => AppColors.gold,
    PassiveRarity.legendary => AppColors.seal,
  };

  Widget _fallback() => CustomPaint(
    painter: _WatercolorPainter(seed),
    child: Center(
      child: Text(
        hanzi,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.ink,
          fontSize: hanzi.length > 1 ? 38 : 52,
          fontFamilyFallback: cjkFallback,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  Widget _seal() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.seal,
      border: Border.all(color: AppColors.accentSoft, width: .6),
      borderRadius: BorderRadius.circular(2),
    ),
    child: Text(
      hanzi.runes.length == 2
          ? hanzi.runes.map(String.fromCharCode).join('\n')
          : hanzi,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.paper,
        fontFamilyFallback: cjkFallback,
        fontSize: 16,
        height: 1.1,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 220,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF101213),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.accentSoft,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: [
            if (selected || rarity == PassiveRarity.legendary)
              BoxShadow(
                color: AppColors.gold.withValues(alpha: selected ? .35 : .17),
                blurRadius: selected ? 14 : 9,
                spreadRadius: selected ? 1 : 0,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: CustomPaint(
              foregroundPainter: const _ImperialFramePainter(),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Container(
                  key: const Key('passive-rarity-frame'),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: _rarityColor, width: 1.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: ColoredBox(
                      color: AppColors.paper,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            top: 0, left: 0, right: 0, height: 122,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageAsset == null)
                                  _fallback()
                                else
                                  Image.asset(
                                    imageAsset!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, error, stackTrace) => _fallback(),
                                    frameBuilder: (_, child, frame, loaded) => Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        child,
                                        Positioned(top: 5, left: 5, child: _seal()),
                                      ],
                                    ),
                                  ),
                                const Positioned(
                                  left: 0, right: 0, bottom: 0, height: 26,
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Color(0x00F1E2C2), AppColors.paper],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 116, left: 4, right: 4, bottom: 3,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 19,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.paperBack,
                                    border: Border.symmetric(
                                      horizontal: BorderSide(
                                        color: AppColors.bronze.withValues(alpha: .5),
                                        width: .5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.ink.withValues(alpha: .85),
                                        fontSize: 10,
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                ),
                                if (price != null)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 88),
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.seal,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        price!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.paper,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImperialFramePainter extends CustomPainter {
  const _ImperialFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = .65;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(3.5), const Radius.circular(5),
      ),
      paint,
    );
    for (final corner in [
      Offset.zero, Offset(size.width, 0),
      Offset(0, size.height), Offset(size.width, size.height),
    ]) {
      canvas.save();
      canvas.translate(corner.dx, corner.dy);
      canvas.scale(corner.dx == 0 ? 1 : -1, corner.dy == 0 ? 1 : -1);
      final fret = Path()
        ..moveTo(3, 17)..lineTo(3, 3)..lineTo(17, 3)
        ..moveTo(6, 12)..lineTo(6, 6)..lineTo(12, 6)
        ..lineTo(12, 9)..lineTo(9, 9);
      canvas.drawPath(fret, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ImperialFramePainter oldDelegate) => false;
}

class _WatercolorPainter extends CustomPainter {
  const _WatercolorPainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.paper);
    for (var i = 0; i < 18; i++) {
      final center = Offset(random.nextDouble() * size.width,
          random.nextDouble() * size.height);
      final radius = 16 + random.nextDouble() * 34;
      final color = i.isEven ? AppColors.seal : const Color(0xFF334D68);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 2, height: radius * 1.4),
        Paint()..shader = RadialGradient(
          colors: [color.withValues(alpha: .13), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WatercolorPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
