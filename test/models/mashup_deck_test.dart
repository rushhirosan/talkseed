import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/mashup_deck.dart';

void main() {
  group('MashupDeck', () {
    late MashupDeck deck;

    setUp(() {
      deck = MashupDeck.fromJson({
        'template': '{category}の{angle}を{constraint}',
        'templateWithoutConstraint': '{category}の{angle}',
        'blocklist': [
          ['仕事', 'いちばんの失敗'],
        ],
        'axes': [
          {
            'id': 'category',
            'label': 'テーマ',
            'items': ['仕事', '趣味'],
          },
          {
            'id': 'angle',
            'label': '切り口',
            'items': ['いちばんの失敗', 'こだわり'],
          },
          {
            'id': 'constraint',
            'label': '制約',
            'optional': true,
            'items': ['30秒で'],
          },
        ],
      });
    });

    test('compose with constraint', () {
      final text = deck.compose({
        'category': '趣味',
        'angle': 'こだわり',
        'constraint': '30秒で',
      });
      expect(text, '趣味のこだわりを30秒で');
    });

    test('compose without constraint uses shorter template', () {
      final text = deck.compose({
        'category': '趣味',
        'angle': 'こだわり',
      });
      expect(text, '趣味のこだわり');
    });

    test('compose with only category drops leftover particles', () {
      expect(deck.compose({'category': '趣味'}), '趣味');
    });

    test('compose with only angle drops leftover particles', () {
      expect(deck.compose({'angle': 'こだわり'}), 'こだわり');
    });

    test('compose with angle and constraint', () {
      expect(
        deck.compose({
          'angle': 'こだわり',
          'constraint': '30秒で',
        }),
        'こだわりを30秒で',
      );
    });

    test('compose with category and constraint', () {
      expect(
        deck.compose({
          'category': '趣味',
          'constraint': '30秒で',
        }),
        '趣味を30秒で',
      );
    });

    test('EN compose keeps about when both axes present', () {
      final en = MashupDeck.fromJson({
        'template': '{angle} about {category} — {constraint}',
        'templateWithoutConstraint': '{angle} about {category}',
        'axes': [
          {
            'id': 'category',
            'label': 'Topic',
            'items': ['work'],
          },
          {
            'id': 'angle',
            'label': 'Angle',
            'items': ['A quiet brag'],
          },
          {
            'id': 'constraint',
            'label': 'Twist',
            'optional': true,
            'items': ['in 30 seconds'],
          },
        ],
      });
      expect(
        en.compose({
          'category': 'work',
          'angle': 'A quiet brag',
        }),
        'A quiet brag about work',
      );
      expect(
        en.compose({
          'category': 'work',
          'angle': 'A quiet brag',
          'constraint': 'in 30 seconds',
        }),
        'A quiet brag about work — in 30 seconds',
      );
      expect(en.compose({'angle': 'A quiet brag'}), 'A quiet brag');
      expect(en.compose({'category': 'work'}), 'work');
      expect(
        en.compose({
          'angle': 'A quiet brag',
          'constraint': 'in 30 seconds',
        }),
        'A quiet brag — in 30 seconds',
      );
    });

    test('isBlocked detects blocklisted pair', () {
      expect(
        deck.isBlocked({
          'category': '仕事',
          'angle': 'いちばんの失敗',
        }),
        isTrue,
      );
      expect(
        deck.isBlocked({
          'category': '趣味',
          'angle': 'いちばんの失敗',
        }),
        isFalse,
      );
    });
  });
}
