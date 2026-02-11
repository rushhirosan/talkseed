import 'dart:math';

/// 価値観カード ランキング形式のゲーム状態
/// ① カードを5枚ずつ配る
/// ② 残りは山札
/// ③ 順番に、山札から1枚引く
/// ④ 6枚を重要度順に並べる（上＝大切、下＝手放す）
/// ⑤ 一番下の1枚を捨てる
/// ⑥ 5回繰り返す
/// ⑦ 残り5枚を共有（重要度順）
class ValueGameState {
  /// 参加人数（2-10）
  final int playerCount;

  /// 各プレイヤーの手札（インデックス → 5枚のカード）
  final Map<int, List<String>> hands;

  /// 山札（上から引く）
  final List<String> drawPile;

  /// 捨て札（表向き）
  final List<String> discardPile;

  /// 現在のプレイヤーインデックス（0始まり）
  final int currentPlayerIndex;

  /// 現在のプレイヤーのラウンド（1-5）
  final int currentRound;

  /// ゲームフェーズ
  final ValuePhase phase;

  /// 共有フェーズで表示中のプレイヤーインデックス（-1 = 未開始）
  final int sharingPlayerIndex;

  ValueGameState({
    required this.playerCount,
    required this.hands,
    required this.drawPile,
    required this.discardPile,
    this.currentPlayerIndex = 0,
    this.currentRound = 1,
    this.phase = ValuePhase.playing,
    this.sharingPlayerIndex = -1,
  });

  /// プレイヤー名（1始まり）
  String playerLabel(int index) => 'プレイヤー${index + 1}';

  /// 現在のプレイヤーの手札（引いた1枚を含む = 6枚）
  List<String> get currentHandWithDrawn {
    final hand = hands[currentPlayerIndex] ?? [];
    if (hand.length == 6) return hand;
    return hand;
  }

  /// 山札から1枚引いた後の手札（6枚）をセットする前の状態か
  bool get needsToDraw => (hands[currentPlayerIndex] ?? []).length == 5;

  /// 捨てる選択待ちか（6枚ある状態）
  bool get needsToDiscard => (hands[currentPlayerIndex] ?? []).length == 6;

  /// ランキング確定待ちか（6枚を並べ替えて確定する）
  bool get needsToRank => (hands[currentPlayerIndex] ?? []).length == 6;

  /// プレイ進行中か
  bool get isPlaying => phase == ValuePhase.playing;

  /// 共有フェーズか
  bool get isSharing => phase == ValuePhase.sharing;

  /// 完了したか
  bool get isComplete => phase == ValuePhase.complete;

  /// 全プレイヤーのプレイが終わったか
  bool get allPlayersFinished =>
      currentPlayerIndex >= playerCount && currentRound > 5;
}

enum ValuePhase {
  /// プレイ中（引いて捨てる）
  playing,

  /// 共有フェーズ（残り5枚を順に表示）
  sharing,

  /// 完了
  complete,
}

/// 価値観カードゲームのロジック
class ValueGameLogic {
  static final Random _random = Random();

  /// デッキをシャッフルして初期状態を作成
  static ValueGameState createGame(List<String> deck, int playerCount) {
    if (deck.length < playerCount * 5) {
      throw ArgumentError(
          'デッキが足りません（${deck.length}枚 < ${playerCount * 5}枚）');
    }

    final shuffled = List<String>.from(deck)..shuffle(_random);

    final hands = <int, List<String>>{};
    for (var i = 0; i < playerCount; i++) {
      hands[i] = shuffled.sublist(i * 5, i * 5 + 5);
    }
    final drawPile =
        shuffled.sublist(playerCount * 5); // 残りが山札

    return ValueGameState(
      playerCount: playerCount,
      hands: hands,
      drawPile: drawPile,
      discardPile: [],
      currentPlayerIndex: 0,
      currentRound: 1,
      phase: ValuePhase.playing,
    );
  }

  /// 山札から1枚引く
  /// 山札が空の場合は捨て札をシャッフルして山札に戻す
  static ValueGameState drawCard(ValueGameState state) {
    if (!state.needsToDraw) return state;

    var drawPile = state.drawPile;
    var discardPile = state.discardPile;

    // 山札が空なら捨て札をシャッフルして山札に
    if (drawPile.isEmpty && discardPile.isNotEmpty) {
      drawPile = List<String>.from(discardPile)..shuffle(_random);
      discardPile = [];
    }

    if (drawPile.isEmpty) return state;

    final drawn = drawPile.first;
    final newDrawPile = drawPile.sublist(1);
    final hand = List<String>.from(state.hands[state.currentPlayerIndex] ?? [])
      ..add(drawn);

    final newHands = Map<int, List<String>>.from(state.hands);
    newHands[state.currentPlayerIndex] = hand;

    return ValueGameState(
      playerCount: state.playerCount,
      hands: newHands,
      drawPile: newDrawPile,
      discardPile: discardPile,
      currentPlayerIndex: state.currentPlayerIndex,
      currentRound: state.currentRound,
      phase: state.phase,
    );
  }

  /// ランキング確定（並べ替えた6枚のうち、最後の1枚を捨てる）
  static ValueGameState confirmRanking(
      ValueGameState state, List<String> orderedHand) {
    if (!state.needsToRank || orderedHand.length != 6) return state;

    final kept = orderedHand.sublist(0, 5);
    final discarded = orderedHand[5];
    final newDiscardPile = [...state.discardPile, discarded];

    final newHands = Map<int, List<String>>.from(state.hands);
    newHands[state.currentPlayerIndex] = kept;

    var nextPlayer = state.currentPlayerIndex;
    var nextRound = state.currentRound;

    if (state.currentRound >= 5) {
      nextPlayer = state.currentPlayerIndex + 1;
      nextRound = 1;

      if (nextPlayer >= state.playerCount) {
        return ValueGameState(
          playerCount: state.playerCount,
          hands: newHands,
          drawPile: state.drawPile,
          discardPile: newDiscardPile,
          currentPlayerIndex: state.currentPlayerIndex,
          currentRound: 5,
          phase: ValuePhase.sharing,
          sharingPlayerIndex: 0,
        );
      }
    } else {
      nextRound = state.currentRound + 1;
    }

    return ValueGameState(
      playerCount: state.playerCount,
      hands: newHands,
      drawPile: state.drawPile,
      discardPile: newDiscardPile,
      currentPlayerIndex: nextPlayer,
      currentRound: nextRound,
      phase: state.phase,
    );
  }

  /// 手札から1枚捨てる（[index]の位置のカードを捨て、次に引くカードを同じ位置に置く）
  static ValueGameState discardCard(
      ValueGameState state, int index) {
    if (!state.needsToDiscard) return state;

    final hand = List<String>.from(state.hands[state.currentPlayerIndex] ?? []);
    if (index < 0 || index >= hand.length) return state;

    final card = hand.removeAt(index);
    final newDiscardPile = [...state.discardPile, card];

    final newHands = Map<int, List<String>>.from(state.hands);
    newHands[state.currentPlayerIndex] = hand;

    var nextPlayer = state.currentPlayerIndex;
    var nextRound = state.currentRound;

    if (state.currentRound >= 5) {
      nextPlayer = state.currentPlayerIndex + 1;
      nextRound = 1;

      if (nextPlayer >= state.playerCount) {
        return ValueGameState(
          playerCount: state.playerCount,
          hands: newHands,
          drawPile: state.drawPile,
          discardPile: newDiscardPile,
          currentPlayerIndex: state.currentPlayerIndex,
          currentRound: 5,
          phase: ValuePhase.sharing,
          sharingPlayerIndex: 0,
        );
      }
    } else {
      nextRound = state.currentRound + 1;
    }

    return ValueGameState(
      playerCount: state.playerCount,
      hands: newHands,
      drawPile: state.drawPile,
      discardPile: newDiscardPile,
      currentPlayerIndex: nextPlayer,
      currentRound: nextRound,
      phase: state.phase,
    );
  }

  /// 共有フェーズで次のプレイヤーへ
  static ValueGameState nextSharingPlayer(ValueGameState state) {
    if (state.phase != ValuePhase.sharing) return state;

    final next = state.sharingPlayerIndex + 1;
    if (next >= state.playerCount) {
      return ValueGameState(
        playerCount: state.playerCount,
        hands: state.hands,
        drawPile: state.drawPile,
        discardPile: state.discardPile,
        currentPlayerIndex: state.currentPlayerIndex,
        currentRound: state.currentRound,
        phase: ValuePhase.complete,
        sharingPlayerIndex: -1,
      );
    }

    return ValueGameState(
      playerCount: state.playerCount,
      hands: state.hands,
      drawPile: state.drawPile,
      discardPile: state.discardPile,
      currentPlayerIndex: state.currentPlayerIndex,
      currentRound: state.currentRound,
      phase: state.phase,
      sharingPlayerIndex: next,
    );
  }
}
