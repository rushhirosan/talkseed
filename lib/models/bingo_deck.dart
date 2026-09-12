/// 会話ビンゴの 1 マス
class BingoPrompt {
  final String id;
  final String text;

  const BingoPrompt({required this.id, required this.text});

  factory BingoPrompt.fromJson(Map<String, dynamic> json) {
    return BingoPrompt(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }
}

/// conversation_bingo_*.json 全体
class BingoDeck {
  final List<BingoPrompt> prompts;

  const BingoDeck({required this.prompts});

  factory BingoDeck.fromJson(Map<String, dynamic> json) {
    return BingoDeck(
      prompts: (json['prompts'] as List<dynamic>)
          .map(
            (e) => BingoPrompt.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .where((p) => p.id.isNotEmpty && p.text.isNotEmpty)
          .toList(),
    );
  }
}

/// 共有ビンゴボード（人数に応じて 3×3 / 5×5）
class BingoBoard {
  /// ビンゴモードの参加人数上限
  static const int maxPlayers = 6;

  /// 最小盤（少人数）
  static const int sizeSmall = 3;

  /// 大人数向け盤
  static const int sizeLarge = 5;

  /// [playerCount] に応じた一辺のマス数（2–3人は 3×3、4–6人は 5×5）
  static int sizeForPlayerCount(int playerCount) {
    return playerCount <= 3 ? sizeSmall : sizeLarge;
  }

  static int cellCountForSize(int size) => size * size;

  /// 奇数盤の中央。偶数盤では null
  static int? centerIndexForSize(int size) {
    if (size.isEven) {
      return null;
    }
    return cellCountForSize(size) ~/ 2;
  }

  static List<List<int>> linesForSize(int size) {
    final lines = <List<int>>[];
    for (var r = 0; r < size; r++) {
      lines.add([for (var c = 0; c < size; c++) r * size + c]);
    }
    for (var c = 0; c < size; c++) {
      lines.add([for (var r = 0; r < size; r++) r * size + c]);
    }
    lines.add([for (var i = 0; i < size; i++) i * size + i]);
    lines.add([for (var i = 0; i < size; i++) i * size + (size - 1 - i)]);
    return lines;
  }

  final int size;
  final List<BingoPrompt> cells;
  final Set<int> marked;

  /// 埋めたマス → プレイヤー index（FREE 中央は持たない）
  final Map<int, int> owners;

  int get cellCount => size * size;

  int? get centerIndex => centerIndexForSize(size);

  List<List<int>> get lines => linesForSize(size);

  BingoBoard({
    required this.size,
    required List<BingoPrompt> cells,
    Set<int>? marked,
    Map<int, int>? owners,
  })  : cells = List<BingoPrompt>.unmodifiable(cells),
        marked = Set<int>.unmodifiable(marked ?? const <int>{}),
        owners = Map<int, int>.unmodifiable(owners ?? const <int, int>{}) {
    assert(size == sizeSmall || size == sizeLarge, 'unsupported bingo size');
    assert(this.cells.length == cellCount);
  }

  factory BingoBoard.forPlayerCount({
    required int playerCount,
    required List<BingoPrompt> cells,
    Set<int>? marked,
    Map<int, int>? owners,
  }) {
    return BingoBoard(
      size: sizeForPlayerCount(playerCount),
      cells: cells,
      marked: marked,
      owners: owners,
    );
  }

  bool isMarked(int index) => marked.contains(index);

  bool get isBlackout => marked.length >= cellCount;

  bool get hasBingo => completedLines.isNotEmpty;

  List<List<int>> get completedLines {
    return [
      for (final line in lines)
        if (line.every(marked.contains)) line,
    ];
  }

  Set<int> get cellsInCompletedLines {
    return {for (final line in completedLines) ...line};
  }

  /// このマスを埋めれば新しいラインが揃う未埋めマス
  Set<int> get hotCells {
    final currentCount = completedLines.length;
    final hot = <int>{};
    for (var i = 0; i < cellCount; i++) {
      if (marked.contains(i)) {
        continue;
      }
      if (mark(i).completedLines.length > currentCount) {
        hot.add(i);
      }
    }
    return hot;
  }

  int? ownerOf(int index) => owners[index];

  /// 横・縦のみ隣接（斜めは不可）
  bool areAdjacent(int a, int b) {
    final ar = a ~/ size;
    final ac = a % size;
    final br = b ~/ size;
    final bc = b % size;
    return (ar - br).abs() + (ac - bc).abs() == 1;
  }

  /// [adjacentOnly] のとき、既に埋まったマスに隣接する未埋めマスのみ選べる
  bool canSelect(int index, {required bool adjacentOnly}) {
    if (index < 0 || index >= cellCount || marked.contains(index)) {
      return false;
    }
    if (!adjacentOnly || marked.isEmpty) {
      return true;
    }
    for (final markedIndex in marked) {
      if (areAdjacent(index, markedIndex)) {
        return true;
      }
    }
    return false;
  }

  BingoBoard mark(int index, {int? owner}) {
    if (index < 0 || index >= cellCount || marked.contains(index)) {
      return this;
    }
    final nextOwners = Map<int, int>.from(owners);
    if (owner != null) {
      nextOwners[index] = owner;
    }
    return BingoBoard(
      size: size,
      cells: cells,
      marked: {...marked, index},
      owners: nextOwners,
    );
  }
}
