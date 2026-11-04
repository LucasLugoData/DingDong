import 'package:flutter_test/flutter_test.dart';
import 'package:dingdong/game/mastery.dart';
import 'package:dingdong/theme.dart';

void main() {
  group('masteryOf thresholds', () {
    test('red covers no hits and net below one', () {
      expect(masteryOf(0, 0), Mastery.red);
      expect(masteryOf(0, 5), Mastery.red);
      expect(masteryOf(3, 3), Mastery.red);
      expect(masteryOf(1, 2), Mastery.red);
    });

    test('orange covers net one and two', () {
      expect(masteryOf(1, 0), Mastery.orange);
      expect(masteryOf(2, 0), Mastery.orange);
      expect(masteryOf(4, 2), Mastery.orange);
      expect(masteryOf(5, 3), Mastery.orange);
    });

    test('blue covers net three through five', () {
      expect(masteryOf(3, 0), Mastery.blue);
      expect(masteryOf(5, 2), Mastery.blue);
      expect(masteryOf(5, 0), Mastery.blue);
    });

    test('green covers net six through nine', () {
      expect(masteryOf(6, 0), Mastery.green);
      expect(masteryOf(9, 3), Mastery.green);
      expect(masteryOf(9, 0), Mastery.green);
      expect(masteryOf(10, 1), Mastery.green);
    });

    test('net ten becomes gold at 85 percent precision', () {
      expect(masteryOf(10, 0), Mastery.gold);
      expect(masteryOf(17, 3), Mastery.gold);
      expect(masteryOf(16, 3), Mastery.green);
      expect(masteryOf(20, 10), Mastery.green);
    });
  });

  test('each mastery exposes its display color and label', () {
    expect(Mastery.red.color, AppColors.red);
    expect(Mastery.orange.color, AppColors.orange);
    expect(Mastery.blue.color, AppColors.blue);
    expect(Mastery.green.color, AppColors.green);
    expect(Mastery.gold.color, AppColors.gold);
    expect(Mastery.red.label, 'Sin dominar');
    expect(Mastery.orange.label, 'Floja');
    expect(Mastery.blue.label, 'En progreso');
    expect(Mastery.green.label, 'Conocida');
    expect(Mastery.gold.label, 'Consolidada');
  });

  test('difficulty multipliers match grammar rules', () {
    expect(difficultyMult(Mastery.red), 2.0);
    expect(difficultyMult(Mastery.orange), 1.5);
    expect(difficultyMult(Mastery.blue), 1.5);
    expect(difficultyMult(Mastery.green), 1.25);
    expect(difficultyMult(Mastery.gold), 1.25);
  });
}
