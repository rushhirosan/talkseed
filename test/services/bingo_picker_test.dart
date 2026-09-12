import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/bingo_deck.dart';
import 'package:theme_dice/services/bingo_picker.dart';

void main() {
  group('BingoPicker', () {
    BingoDeck deckWith(int count) {
      return BingoDeck(
        prompts: List.generate(
          count,
          (i) => BingoPrompt(id: 'p$i', text: 'prompt $i'),
        ),
      );
    }

    test('deal returns 9 cells for up to 3 players', () {
      final picker = BingoPicker(deck: deckWith(30), random: Random(1));
      final board = picker.deal(playerCount: 3);
      expect(board.size, 3);
      expect(board.cells, hasLength(9));
      expect(board.cells.map((c) => c.id).toSet(), hasLength(9));
    });

    test('deal returns 25 cells for 4+ players', () {
      final picker = BingoPicker(deck: deckWith(30), random: Random(2));
      final board = picker.deal(playerCount: 4);
      expect(board.size, 5);
      expect(board.cells, hasLength(25));
    });

    test('deal throws when the deck is too small', () {
      final picker = BingoPicker(deck: deckWith(5));
      expect(() => picker.deal(playerCount: 2), throwsStateError);
    });
  });
}
