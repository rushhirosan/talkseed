import 'dart:math';

import 'package:theme_dice/models/mashup_deck.dart';

/// マッシュアップの軸組み合わせを抽選（blocklist・直前の同一語を避ける）
class MashupPicker {
  static const int _maxAttempts = 40;

  final MashupDeck deck;
  final List<MashupAxis> axes;
  final Random _random;

  MashupPicker({
    required this.deck,
    required this.axes,
    Random? random,
  }) : _random = random ?? Random();

  /// [lockedPicks] は固定済みの軸。[spinAxisIds] だけ新しく抽選する。
  Map<String, String> spin({
    required Map<String, String> lockedPicks,
    required Set<String> spinAxisIds,
    Map<String, String>? previousPicks,
  }) {
    if (spinAxisIds.isEmpty) {
      return Map<String, String>.from(lockedPicks);
    }

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final picks = Map<String, String>.from(lockedPicks);
      for (final axis in axes) {
        if (!spinAxisIds.contains(axis.id)) {
          continue;
        }
        final avoid = previousPicks?[axis.id];
        picks[axis.id] = _pickItem(axis, avoid: avoid);
      }
      if (!deck.isBlocked(picks)) {
        return picks;
      }
    }

    // blocklist 回避に失敗したら最後の試行結果を返す
    final fallback = Map<String, String>.from(lockedPicks);
    for (final axis in axes) {
      if (spinAxisIds.contains(axis.id)) {
        fallback[axis.id] = _pickItem(axis);
      }
    }
    return fallback;
  }

  String _pickItem(MashupAxis axis, {String? avoid}) {
    if (axis.items.isEmpty) {
      return '';
    }
    if (axis.items.length == 1) {
      return axis.items.first;
    }
    for (var i = 0; i < 12; i++) {
      final item = axis.items[_random.nextInt(axis.items.length)];
      if (item != avoid) {
        return item;
      }
    }
    return axis.items[_random.nextInt(axis.items.length)];
  }
}
