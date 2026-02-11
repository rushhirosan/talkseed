import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/models/session_config.dart';

/// ゲームセッションの状態を管理するクラス
class GameSession {
  /// セッション設定
  final SessionConfig config;
  
  /// テーマのマップ
  final Map<PolyhedronType, List<String>> themes;
  
  /// ラウンド履歴
  final List<RoundResult> rounds;
  
  /// 現在のプレイヤーインデックス（0始まり）
  int currentPlayerIndex;
  
  /// 現在のラウンド番号（1始まり）
  int currentRound;
  
  /// セッションがアクティブかどうか
  bool isActive;
  
  GameSession({
    required this.config,
    required this.themes,
    List<RoundResult>? rounds,
    this.currentPlayerIndex = 0,
    this.currentRound = 1,
    this.isActive = false,
  }) : rounds = rounds ?? [];
  
  /// 現在のプレイヤー名を取得（カスタム名がある場合のみ、nullの場合は番号を使用）
  String? get currentPlayerName {
    if (config.playerNames != null && currentPlayerIndex < config.playerNames!.length) {
      final name = config.playerNames![currentPlayerIndex];
      return name.isNotEmpty ? name : null;
    }
    return null;
  }
  
  /// 全プレイヤーが1回ずつ話したかどうか（ラウンド完了）
  bool get isRoundComplete => currentPlayerIndex >= config.playerCount;
  
  /// 最後のプレイヤーかどうか（全員1回ずつでセッション終了とする）
  bool get isLastPlayer => currentPlayerIndex >= config.playerCount - 1;

  /// 次のプレイヤーに進む（最後のプレイヤーが終わったらセッション終了）
  void nextPlayer() {
    currentPlayerIndex++;
    if (isRoundComplete) {
      // 全員の番が終わったらセッション終了（1番目に戻さない）
      endSession();
    }
  }
  
  /// ラウンド結果を追加
  void addRoundResult(String theme) {
    rounds.add(RoundResult(
      roundNumber: currentRound,
      playerIndex: currentPlayerIndex,
      playerName: currentPlayerName,
      theme: theme,
      timestamp: DateTime.now(),
    ));
  }
  
  /// セッションを終了
  void endSession() {
    isActive = false;
  }
  
  /// セッションを開始
  void startSession() {
    isActive = true;
    currentPlayerIndex = 0;
    currentRound = 1;
  }
}

/// ラウンド結果を表すクラス
class RoundResult {
  /// ラウンド番号
  final int roundNumber;
  
  /// プレイヤーインデックス
  final int playerIndex;
  
  /// プレイヤー名
  final String? playerName;
  
  /// 選ばれたテーマ
  final String theme;
  
  /// タイムスタンプ
  final DateTime timestamp;
  
  RoundResult({
    required this.roundNumber,
    required this.playerIndex,
    this.playerName,
    required this.theme,
    required this.timestamp,
  });
}
