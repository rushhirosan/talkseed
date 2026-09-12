import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/bingo_deck.dart';

void main() {
  group('BingoBoard', () {
    BingoPrompt p(int i) => BingoPrompt(id: 'p$i', text: 'prompt $i');

    BingoBoard board3() => BingoBoard(
          size: BingoBoard.sizeSmall,
          cells: List.generate(9, p),
        );

    test('sizeForPlayerCount switches at 4 players', () {
      expect(BingoBoard.sizeForPlayerCount(2), BingoBoard.sizeSmall);
      expect(BingoBoard.sizeForPlayerCount(3), BingoBoard.sizeSmall);
      expect(BingoBoard.sizeForPlayerCount(4), BingoBoard.sizeLarge);
      expect(BingoBoard.sizeForPlayerCount(6), BingoBoard.sizeLarge);
    });

    test('mark is immutable and tracks cells', () {
      final board = board3();
      final next = board.mark(0).mark(4);
      expect(board.marked, isEmpty);
      expect(next.isMarked(0), isTrue);
      expect(next.isMarked(4), isTrue);
      expect(next.hasBingo, isFalse);
    });

    test('row line is bingo', () {
      final next = board3().mark(0).mark(1).mark(2);
      expect(next.hasBingo, isTrue);
      expect(next.completedLines, [
        [0, 1, 2],
      ]);
      expect(next.cellsInCompletedLines, {0, 1, 2});
    });

    test('column and diagonal lines', () {
      final board = board3();
      expect(board.mark(0).mark(3).mark(6).hasBingo, isTrue);
      expect(board.mark(0).mark(4).mark(8).hasBingo, isTrue);
      expect(board.mark(2).mark(4).mark(6).hasBingo, isTrue);
    });

    test('5x5 has longer lines', () {
      final board = BingoBoard(
        size: BingoBoard.sizeLarge,
        cells: List.generate(25, p),
      );
      expect(board.lines.first, hasLength(5));
      expect(board.centerIndex, 12);
      var next = board;
      for (final i in [0, 1, 2, 3]) {
        next = next.mark(i);
      }
      expect(next.hasBingo, isFalse);
      next = next.mark(4);
      expect(next.hasBingo, isTrue);
    });

    test('blackout requires all cells', () {
      var next = board3();
      for (var i = 0; i < 8; i++) {
        next = next.mark(i);
      }
      expect(next.isBlackout, isFalse);
      next = next.mark(8);
      expect(next.isBlackout, isTrue);
    });

    test('hotCells lists squares one mark from a line', () {
      final board = board3();
      final almostRow = board.mark(0).mark(1);
      expect(almostRow.hotCells, {2});

      final almostColumn = board.mark(0).mark(3);
      expect(almostColumn.hotCells, {6});

      expect(board.hotCells, isEmpty);
      expect(almostRow.mark(2).hotCells, isEmpty);
    });

    test('hotCells still finds a second line after bingo', () {
      final afterFirstLine =
          board3().mark(0).mark(1).mark(2).mark(3).mark(4);
      expect(afterFirstLine.hasBingo, isTrue);
      expect(afterFirstLine.hotCells, contains(5));
    });

    test('mark stores owner', () {
      final next = board3().mark(0, owner: 1);
      expect(next.ownerOf(0), 1);
      expect(board3().ownerOf(0), isNull);
    });

    test('areAdjacent ignores diagonals', () {
      final board = board3();
      expect(board.areAdjacent(0, 1), isTrue);
      expect(board.areAdjacent(0, 3), isTrue);
      expect(board.areAdjacent(0, 4), isFalse);
      expect(board.areAdjacent(4, 1), isTrue);
    });

    test('canSelect respects adjacent-only rule', () {
      final withCenter = board3().mark(BingoBoard.centerIndexForSize(3)!);
      expect(withCenter.canSelect(0, adjacentOnly: false), isTrue);
      expect(withCenter.canSelect(0, adjacentOnly: true), isFalse);
      expect(withCenter.canSelect(1, adjacentOnly: true), isTrue);
      expect(withCenter.canSelect(3, adjacentOnly: true), isTrue);
      expect(withCenter.canSelect(5, adjacentOnly: true), isTrue);
      expect(withCenter.canSelect(7, adjacentOnly: true), isTrue);
    });

    test('fromJson keeps prompts', () {
      final deck = BingoDeck.fromJson({
        'prompts': [
          {'id': 'a', 'text': 'one'},
          {'id': 'b', 'text': 'two'},
        ],
      });
      expect(deck.prompts, hasLength(2));
      expect(deck.prompts.first.text, 'one');
    });

    test('shipped JSON decks cover large board', () {
      final minCells = BingoBoard.cellCountForSize(BingoBoard.sizeLarge);
      for (final path in [
        'data/conversation_bingo.json',
        'data/conversation_bingo_en.json',
      ]) {
        final decoded =
            jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
        final deck = BingoDeck.fromJson(decoded);
        expect(deck.prompts.length, greaterThanOrEqualTo(minCells),
            reason: path);
      }
    });
  });
}
