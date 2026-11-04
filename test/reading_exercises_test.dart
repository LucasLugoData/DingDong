import 'package:flutter_test/flutter_test.dart';
import 'package:dingdong/data/reading_exercises.dart';
import 'package:dingdong/data/readings.dart';

void main() {
  test('hay un ejercicio por cada lectura, con frases literales y verbo', () {
    expect(readingExercises, hasLength(readings.length));

    for (final reading in readings) {
      final matches = readingExercises
          .where((exercise) => exercise.readingTitle == reading.title)
          .toList();
      expect(matches, hasLength(1));
      final exercise = matches.single;
      expect(exercise.ideaQuestion, isNotEmpty);
      expect(exercise.options, hasLength(4));
      expect(exercise.options, everyElement(isNotEmpty));
      expect(exercise.options.toSet(), hasLength(4));
      expect(exercise.correctIndex, inInclusiveRange(0, 3));
      expect(exercise.taggedSentences.length, inInclusiveRange(3, 4));

      for (final tagged in exercise.taggedSentences) {
        final sentence = tagged.map((word) => word.$1).join();
        expect(reading.sentences.any((source) => source.$1 == sentence), isTrue);
        expect(tagged.any((word) => word.$2 == 'verbo'), isTrue);
        for (final word in tagged) {
          expect(word.$1, isNotEmpty);
          expect(
            const {
              'sustantivo',
              'verbo',
              'adjetivo',
              'sujeto',
              'objeto',
              'partícula',
              'tiempo',
              'lugar',
              'clasificador',
              'número',
              'adverbio',
            },
            contains(word.$2),
          );
        }
      }
    }
  });
}
