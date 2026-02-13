import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/theme.dart';
import 'package:theme_dice/models/polyhedron_type.dart';

void main() {
  group('ThemeModel', () {
    group('getDefaultThemeKeys', () {
      test('tetrahedron returns 4 keys', () {
        final keys = ThemeModel.getDefaultThemeKeys(PolyhedronType.tetrahedron);
        expect(keys, hasLength(4));
      });

      test('cube returns 6 keys', () {
        final keys = ThemeModel.getDefaultThemeKeys(PolyhedronType.cube);
        expect(keys, hasLength(6));
      });

      test('octahedron returns 8 keys', () {
        final keys = ThemeModel.getDefaultThemeKeys(PolyhedronType.octahedron);
        expect(keys, hasLength(8));
      });

      test('returns new list each time (no shared mutable list)', () {
        final a = ThemeModel.getDefaultThemeKeys(PolyhedronType.cube);
        final b = ThemeModel.getDefaultThemeKeys(PolyhedronType.cube);
        expect(identical(a, b), false);
        a.add('extra');
        expect(b, hasLength(6));
      });
    });

    group('getThemeByIndex', () {
      test('returns theme at valid index', () {
        const themes = ['A', 'B', 'C'];
        expect(ThemeModel.getThemeByIndex(0, themes), 'A');
        expect(ThemeModel.getThemeByIndex(1, themes), 'B');
        expect(ThemeModel.getThemeByIndex(2, themes), 'C');
      });

      test('returns null for negative index', () {
        expect(ThemeModel.getThemeByIndex(-1, ['A']), isNull);
      });

      test('returns null for index >= length', () {
        expect(ThemeModel.getThemeByIndex(1, ['A']), isNull);
        expect(ThemeModel.getThemeByIndex(3, ['A', 'B', 'C']), isNull);
      });
    });

    group('getThemeByFaceNumber', () {
      test('face 1 maps to index 0', () {
        const themes = ['First', 'Second'];
        expect(ThemeModel.getThemeByFaceNumber(1, themes), 'First');
      });

      test('face 2 maps to index 1', () {
        const themes = ['First', 'Second'];
        expect(ThemeModel.getThemeByFaceNumber(2, themes), 'Second');
      });

      test('returns null for face 0 (invalid)', () {
        expect(ThemeModel.getThemeByFaceNumber(0, ['A']), isNull);
      });

      test('returns null when face exceeds list length', () {
        expect(ThemeModel.getThemeByFaceNumber(10, ['A', 'B']), isNull);
      });
    });

    group('defaultThemeKeys / themeCandidateKeys', () {
      test('defaultThemeKeys has 6 items', () {
        expect(ThemeModel.defaultThemeKeys, hasLength(6));
      });

      test('themeCandidateKeys is non-empty', () {
        expect(ThemeModel.themeCandidateKeys, isNotEmpty);
      });
    });
  });
}
