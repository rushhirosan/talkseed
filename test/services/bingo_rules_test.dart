import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/bingo_deck.dart';
import 'package:theme_dice/services/bingo_rules.dart';

void main() {
  BingoPrompt p(int i) => BingoPrompt(id: 'p$i', text: 'prompt $i');

  BingoBoard emptyBoard() => BingoBoard(
        size: BingoBoard.sizeSmall,
        cells: List.generate(9, p),
      );

  group('resolveBingoMark', () {
    test('base mark is 1 point', () {
      final outcome = resolveBingoMark(
        before: emptyBoard(),
        index: 0,
        playerIndex: 0,
      );
      expect(outcome.points, BingoMarkOutcome.pointsPerMark);
      expect(outcome.newLineCount, 0);
      expect(outcome.extraTurn, isFalse);
      expect(outcome.board.ownerOf(0), 0);
    });

    test('completing a line adds line points', () {
      final before = emptyBoard().mark(0, owner: 0).mark(1, owner: 1);
      final outcome = resolveBingoMark(
        before: before,
        index: 2,
        playerIndex: 0,
      );
      expect(outcome.newLineCount, 1);
      expect(
        outcome.points,
        BingoMarkOutcome.pointsPerMark + BingoMarkOutcome.pointsPerLine,
      );
    });

    test('bonus cell adds points and extra turn', () {
      final outcome = resolveBingoMark(
        before: emptyBoard(),
        index: 1,
        playerIndex: 0,
        bonusIndex: 1,
      );
      expect(outcome.claimedBonus, isTrue);
      expect(outcome.extraTurn, isTrue);
      expect(
        outcome.points,
        BingoMarkOutcome.pointsPerMark + BingoMarkOutcome.pointsBonusCell,
      );
    });

    test('chain bonus when adjacent to own cell', () {
      final before = emptyBoard().mark(0, owner: 0);
      final outcome = resolveBingoMark(
        before: before,
        index: 1,
        playerIndex: 0,
      );
      expect(outcome.chainBonus, isTrue);
      expect(
        outcome.points,
        BingoMarkOutcome.pointsPerMark + BingoMarkOutcome.pointsChain,
      );
    });

    test('no chain across diagonal', () {
      final before = emptyBoard().mark(0, owner: 0);
      final outcome = resolveBingoMark(
        before: before,
        index: 4,
        playerIndex: 0,
      );
      expect(outcome.chainBonus, isFalse);
      expect(outcome.points, BingoMarkOutcome.pointsPerMark);
    });

    test('streak bonus when same player marked last', () {
      final outcome = resolveBingoMark(
        before: emptyBoard(),
        index: 2,
        playerIndex: 1,
        lastMarkPlayerIndex: 1,
      );
      expect(outcome.streakBonus, isTrue);
      expect(
        outcome.points,
        BingoMarkOutcome.pointsPerMark + BingoMarkOutcome.pointsStreak,
      );
    });
  });

  group('pickBingoBonusIndex', () {
    test('skips already marked cells', () {
      final board = emptyBoard().mark(BingoBoard.centerIndexForSize(3)!);
      final picked = pickBingoBonusIndex(board, Random(0));
      expect(picked, isNotNull);
      expect(picked, isNot(BingoBoard.centerIndexForSize(3)));
    });

    test('returns null when board is full', () {
      var board = emptyBoard();
      for (var i = 0; i < board.cellCount; i++) {
        board = board.mark(i);
      }
      expect(pickBingoBonusIndex(board, Random()), isNull);
    });
  });
}
