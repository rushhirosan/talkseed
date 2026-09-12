import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/mashup_deck.dart';
import 'package:theme_dice/services/mashup_picker.dart';

void main() {
  group('MashupPicker', () {
    late MashupDeck deck;
    late List<MashupAxis> axes;

    setUp(() {
      deck = MashupDeck.fromJson({
        'template': '{category}の{angle}',
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
        ],
      });
      axes = deck.axes;
    });

    test('spin keeps locked picks', () {
      final picker = MashupPicker(deck: deck, axes: axes);
      final picks = picker.spin(
        lockedPicks: const {'category': '仕事'},
        spinAxisIds: {'angle'},
      );
      expect(picks['category'], '仕事');
      expect(picks['angle'], isNotEmpty);
    });

    test('spin fills all requested axes', () {
      final picker = MashupPicker(deck: deck, axes: axes);
      final picks = picker.spin(
        lockedPicks: const {},
        spinAxisIds: {'category', 'angle'},
      );
      expect(picks['category'], isNotEmpty);
      expect(picks['angle'], isNotEmpty);
    });
  });
}
