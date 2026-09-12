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
