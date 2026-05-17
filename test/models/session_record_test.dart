import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/session_record.dart';

void main() {
  group('SessionRecord', () {
    test('labelsForPlayers uses custom names and defaults', () {
      final labels = SessionRecord.labelsForPlayers(
        playerCount: 3,
        configPlayerNames: ['Alice', '', 'Carol'],
        defaultName: (n) => 'Player $n',
      );
      expect(labels, ['Alice', 'Player 2', 'Carol']);
    });

    test('toMap and fromMap preserve playerNames', () {
      final record = SessionRecord.create(
        mode: 'discussion',
        topics: ['topic A'],
        selectedCardsByPlayer: const {},
        playerCount: 2,
        playerNames: ['Alice', 'Bob'],
      );
      final restored = SessionRecord.fromMap(record.toMap());
      expect(restored.playerNames, ['Alice', 'Bob']);
      expect(restored.displayPlayerNames, ['Alice', 'Bob']);
    });

    test('displayPlayerNames falls back to selectedCardsByPlayer keys', () {
      final record = SessionRecord.create(
        mode: 'value_cards',
        topics: const [],
        selectedCardsByPlayer: {
          'Alice': ['card1'],
          'Bob': ['card2'],
        },
        playerCount: 2,
      );
      expect(record.displayPlayerNames, ['Alice', 'Bob']);
    });
  });
}
