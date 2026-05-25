import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/utils/web_locale_query.dart';

void main() {
  group('parseLangQueryParam', () {
    test('returns en for en', () {
      expect(parseLangQueryParam('en'), const Locale('en'));
    });

    test('returns ja for ja', () {
      expect(parseLangQueryParam('ja'), const Locale('ja'));
    });

    test('is case insensitive', () {
      expect(parseLangQueryParam('EN'), const Locale('en'));
    });

    test('returns null for unknown or empty', () {
      expect(parseLangQueryParam('fr'), isNull);
      expect(parseLangQueryParam(null), isNull);
      expect(parseLangQueryParam(''), isNull);
    });
  });
}
