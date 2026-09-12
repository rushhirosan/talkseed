import 'dart:math';

import 'package:theme_dice/models/bingo_deck.dart';

/// 1 マス埋めたときの点数と特典
class BingoMarkOutcome {
  static const int pointsPerMark = 1;
  static const int pointsPerLine = 3;
  static const int pointsBonusCell = 2;
  static const int pointsChain = 1;
  static const int pointsStreak = 2;

  final BingoBoard board;
  final int points;
  final int newLineCount;
  final bool claimedBonus;
  final bool chainBonus;
  final bool streakBonus;

  const BingoMarkOutcome({
    required this.board,
    required this.points,
    required this.newLineCount,
    required this.claimedBonus,
    required this.chainBonus,
    required this.streakBonus,
  });

  bool get extraTurn => claimedBonus;
}

/// 空きマスからボーナスマスを1つ選ぶ。空きがなければ null。
int? pickBingoBonusIndex(BingoBoard board, Random random) {
  final open = [
    for (var i = 0; i < board.cellCount; i++)
      if (!board.isMarked(i)) i,
  ];
  if (open.isEmpty) {
    return null;
  }
  return open[random.nextInt(open.length)];
}

/// マス埋めの点数・連鎖・連続・ボーナスを計算する
BingoMarkOutcome resolveBingoMark({
  required BingoBoard before,
  required int index,
  required int playerIndex,
  int? bonusIndex,
  int? lastMarkPlayerIndex,
}) {
  final previousLines = before.completedLines.length;
  final chain = before.owners.entries.any(
    (e) => e.value == playerIndex && before.areAdjacent(e.key, index),
  );
  final next = before.mark(index, owner: playerIndex);
  final newLines = next.completedLines.length - previousLines;
  final bonus = bonusIndex == index;
  final streak = lastMarkPlayerIndex == playerIndex;

  var points = BingoMarkOutcome.pointsPerMark;
  if (bonus) {
    points += BingoMarkOutcome.pointsBonusCell;
  }
  if (chain) {
    points += BingoMarkOutcome.pointsChain;
  }
  if (streak) {
    points += BingoMarkOutcome.pointsStreak;
  }
  points += newLines * BingoMarkOutcome.pointsPerLine;

  return BingoMarkOutcome(
    board: next,
    points: points,
    newLineCount: newLines,
    claimedBonus: bonus,
    chainBonus: chain,
    streakBonus: streak,
  );
}
