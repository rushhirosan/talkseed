import 'dart:math';

import 'package:theme_dice/models/bingo_deck.dart';

/// デッキから重複なしでボードを配る
class BingoPicker {
  final BingoDeck deck;
  final Random _random;

  BingoPicker({
    required this.deck,
    Random? random,
  }) : _random = random ?? Random();

  BingoBoard deal({required int playerCount}) {
    final size = BingoBoard.sizeForPlayerCount(playerCount);
    final count = BingoBoard.cellCountForSize(size);
    if (deck.prompts.length < count) {
      throw StateError(
        'Bingo deck has ${deck.prompts.length} prompts; need $count',
      );
    }
    final shuffled = List<BingoPrompt>.from(deck.prompts)..shuffle(_random);
    return BingoBoard(
      size: size,
      cells: shuffled.take(count).toList(),
    );
  }
}
