import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/utils/dice_3d_utils.dart';

void main() {
  group('Dice3DUtils', () {
    test('diceSize is 150', () {
      expect(Dice3DUtils.diceSize, 150.0);
    });

    group('getFrontFace', () {
      test('no rotation returns face 1 (front)', () {
        final face = Dice3DUtils.getFrontFace(0, 0, 0);
        expect(face, 1);
      });

      test('returns value between 1 and 6', () {
        final random = Random(42);
        for (var i = 0; i < 20; i++) {
          final face = Dice3DUtils.getFrontFace(
            random.nextDouble() * 2 * pi,
            random.nextDouble() * 2 * pi,
            random.nextDouble() * 2 * pi,
          );
          expect(face, inInclusiveRange(1, 6));
        }
      });
    });

    group('generateRandomRotation', () {
      test('returns map with x, y, z keys', () {
        final random = Random(42);
        final rot = Dice3DUtils.generateRandomRotation(0, 0, 0, random);
        expect(rot.keys, containsAll(['x', 'y', 'z']));
        expect(rot['x'], isA<double>());
        expect(rot['y'], isA<double>());
        expect(rot['z'], isA<double>());
      });
    });

    group('calculateRotationForFace', () {
      test('returns map with x, y, z for face 1-6', () {
        final random = Random(42);
        for (var face = 1; face <= 6; face++) {
          final rot = Dice3DUtils.calculateRotationForFace(face, random);
          expect(rot.keys, containsAll(['x', 'y', 'z']));
        }
      });
    });
  });
}
