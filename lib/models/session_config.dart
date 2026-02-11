/// 遊び方（サイコロ or トピックカード/リスト）
enum PlayMode {
  /// サイコロを振ってテーマを選ぶ
  dice,
  /// トピックカード/リストを引いてテーマを選ぶ
  topicCard,
}

/// セッション設定を管理するモデルクラス
class SessionConfig {
  /// 遊び方
  final PlayMode playMode;
  
  /// 参加人数（2-10人）
  final int playerCount;
  
  /// タイマー時間
  final Duration timerDuration;
  
  /// タイマーを有効にするかどうか
  final bool enableTimer;
  
  /// プレイヤー名のリスト（オプション、nullの場合は番号のみ使用）
  final List<String>? playerNames;
  
  const SessionConfig({
    this.playMode = PlayMode.dice,
    required this.playerCount,
    required this.timerDuration,
    this.enableTimer = true,
    this.playerNames,
  }) : assert(playerCount >= 2 && playerCount <= 10, '参加人数は2-10人の範囲で設定してください');
  
  /// デフォルト設定
  static const SessionConfig defaultConfig = SessionConfig(
    playMode: PlayMode.dice,
    playerCount: 4,
    timerDuration: Duration(minutes: 3),
    enableTimer: true,
  );
  
  /// プレイヤー名を取得（インデックスは0始まり、カスタム名がない場合はnull）
  String? getPlayerName(int index) {
    if (playerNames != null && index < playerNames!.length) {
      final name = playerNames![index];
      return name.isNotEmpty ? name : null;
    }
    return null;
  }
  
  /// コピーを作成（一部のプロパティを変更）
  SessionConfig copyWith({
    PlayMode? playMode,
    int? playerCount,
    Duration? timerDuration,
    bool? enableTimer,
    List<String>? playerNames,
  }) {
    return SessionConfig(
      playMode: playMode ?? this.playMode,
      playerCount: playerCount ?? this.playerCount,
      timerDuration: timerDuration ?? this.timerDuration,
      enableTimer: enableTimer ?? this.enableTimer,
      playerNames: playerNames ?? this.playerNames,
    );
  }
}
