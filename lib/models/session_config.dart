import 'package:theme_dice/l10n/app_localizations.dart';

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

  /// 議論モードのみ: デッキから使うお題の最大枚数。null ならデッキ全枚（シャッフル後にそのまま使う）
  final int? discussionPromptCap;

  /// 議論モードのみ: 出題するカテゴリー ID（CardDeck の theme キーから導出される ID と同じ体系）。
  /// null なら全カテゴリ。非 null のときはリストに含まれるカテゴリのお題だけをプールする。
  final List<String>? discussionCategoryIds;

  const SessionConfig({
    this.playMode = PlayMode.dice,
    required this.playerCount,
    required this.timerDuration,
    this.enableTimer = true,
    this.playerNames,
    this.discussionPromptCap,
    this.discussionCategoryIds,
  }) : assert(playerCount >= 2 && playerCount <= 10, '参加人数は2-10人の範囲で設定してください');
  
  /// デフォルト設定
  static const SessionConfig defaultConfig = SessionConfig(
    playMode: PlayMode.dice,
    playerCount: 4,
    timerDuration: Duration(minutes: 3),
    enableTimer: true,
    discussionPromptCap: null,
    discussionCategoryIds: null,
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
    int? discussionPromptCap,
    bool applyDiscussionPromptCap = false,
    List<String>? discussionCategoryIds,
    bool applyDiscussionCategoryIds = false,
  }) {
    return SessionConfig(
      playMode: playMode ?? this.playMode,
      playerCount: playerCount ?? this.playerCount,
      timerDuration: timerDuration ?? this.timerDuration,
      enableTimer: enableTimer ?? this.enableTimer,
      playerNames: playerNames ?? this.playerNames,
      discussionPromptCap: applyDiscussionPromptCap
          ? discussionPromptCap
          : this.discussionPromptCap,
      discussionCategoryIds: applyDiscussionCategoryIds
          ? discussionCategoryIds
          : this.discussionCategoryIds,
    );
  }

  /// [PlayerIndicator] / [GameSession.playerLabelAt] と同じ表示規則
  String displayLabelForPlayer(int playerIndex, AppLocalizations l10n) {
    if (playerNames != null && playerIndex < playerNames!.length) {
      final name = playerNames![playerIndex];
      if (name.isNotEmpty) {
        return '$name (${playerIndex + 1}/$playerCount)';
      }
    }
    return l10n.currentPlayer(playerIndex + 1, playerCount);
  }
}
