import 'dart:io';

import 'package:dingdong/game/passives.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pubspec declara el directorio de ilustraciones pasivas', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, matches(RegExp(r'^    - assets/passives/\s*$', multiLine: true)));
  });

  for (final passive in passiveCatalog) {
    test('${passive.id}: PNG incluido, hasta 200 KB y proporción vertical', () async {
      final path = 'assets/passives/${passive.id}.png';
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);

      final bytes = await rootBundle.load(path);
      expect(bytes.lengthInBytes, file.lengthSync(), reason: path);
      expect(bytes.lengthInBytes, lessThanOrEqualTo(200000), reason: path);
      expect(bytes.lengthInBytes, greaterThanOrEqualTo(24), reason: path);
      expect(bytes.buffer.asUint8List(bytes.offsetInBytes, 8),
          orderedEquals([137, 80, 78, 71, 13, 10, 26, 10]), reason: path);
      expect(bytes.getUint32(8), 13, reason: 'Longitud IHDR: $path');
      expect(bytes.buffer.asUint8List(bytes.offsetInBytes + 12, 4),
          orderedEquals([73, 72, 68, 82]), reason: 'IHDR: $path');

      final width = bytes.getUint32(16);
      final height = bytes.getUint32(20);
      expect(width, greaterThan(0), reason: path);
      expect(height / width, inInclusiveRange(1.25, 1.4), reason: path);
    });
  }
}
