import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/polyhedron_type.dart';

void main() {
  group('PolyhedronType', () {
    test('tetrahedron has 4 faces', () {
      expect(PolyhedronType.tetrahedron.faceCount, 4);
    });

    test('cube has 6 faces', () {
      expect(PolyhedronType.cube.faceCount, 6);
    });

    test('octahedron has 8 faces', () {
      expect(PolyhedronType.octahedron.faceCount, 8);
    });

    test('each type has non-empty displayName', () {
      expect(PolyhedronType.tetrahedron.displayName, isNotEmpty);
      expect(PolyhedronType.cube.displayName, isNotEmpty);
      expect(PolyhedronType.octahedron.displayName, isNotEmpty);
    });

    test('values list contains all three types', () {
      expect(PolyhedronType.values, hasLength(3));
      expect(PolyhedronType.values, contains(PolyhedronType.tetrahedron));
      expect(PolyhedronType.values, contains(PolyhedronType.cube));
      expect(PolyhedronType.values, contains(PolyhedronType.octahedron));
    });
  });
}
