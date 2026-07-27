import 'dart:math';

import 'package:theme_dice/models/session_config.dart';

/// セッション履歴の保存用モデル（端末内ローカル）
class SessionRecord {
  final String id;
  final DateTime playedAt;
  /// 'dice' | 'value_cards' | 'discussion' | 'one_on_one'
  static const String modeDice = 'dice';
  static const String modeValueCards = 'value_cards';
  static const String modeDiscussion = 'discussion';
  static const String modeOneOnOne = 'one_on_one';

  final String mode;
  /// 出たテーマ一覧（サイコロ用）
  final List<String> topics;
  /// 選択カード（価値観カード用：プレイヤー名 -> カード一覧）
  final Map<String, List<String>> selectedCardsByPlayer;
  /// 参加人数（不明なら null）
  final int? playerCount;
  /// 参加者の表示名（保存時点のラベル。カスタム名または「プレイヤーN」）
  final List<String> playerNames;
  /// 投票結果（サイコロ用：プレイヤー名 -> 票数）
  final Map<String, int> voteResults;

  /// プリセット化用: 1on1 の型（[OneOnOneSessionFormat.name]）
  final String? oneOnOneFormatName;

  /// プリセット化用: セッション設定スナップショット
  final SessionConfig? sessionConfig;

  /// プリセット化用: 議論デッキ種別（[CardDeckType.name]）
  final String? discussionDeckTypeName;

  /// プリセット化用: デッキ表示名
  final String? deckLabel;

  /// プリセット化用: サイコロ 6 面テーマ
  final List<String>? diceThemes;

  SessionRecord({
    required this.id,
    required this.playedAt,
    required this.mode,
    required this.topics,
    required this.selectedCardsByPlayer,
    this.playerCount,
    this.playerNames = const [],
    required this.voteResults,
    this.oneOnOneFormatName,
    this.sessionConfig,
    this.discussionDeckTypeName,
    this.deckLabel,
    this.diceThemes,
  });

  /// 履歴表示用の参加者名（新形式の [playerNames]、または価値観カードの map キー）
  /// 1on1 では [selectedCardsByPlayer] のキーはフェーズIDのため含めない
  List<String> get displayPlayerNames {
    if (playerNames.isNotEmpty) return playerNames;
    if (mode == modeOneOnOne) return const [];
    if (selectedCardsByPlayer.isNotEmpty) {
      return selectedCardsByPlayer.keys.toList();
    }
    return const [];
  }

  /// セッション設定から保存用の参加者ラベルを生成
  static List<String> labelsForPlayers({
    required int playerCount,
    List<String>? configPlayerNames,
    required String Function(int number) defaultName,
  }) {
    return List.generate(playerCount, (i) {
      if (configPlayerNames != null && i < configPlayerNames.length) {
        final name = configPlayerNames[i].trim();
        if (name.isNotEmpty) return name;
      }
      return defaultName(i + 1);
    });
  }

  factory SessionRecord.create({
    required String mode,
    required List<String> topics,
    required Map<String, List<String>> selectedCardsByPlayer,
    int? playerCount,
    List<String>? playerNames,
    Map<String, int>? voteResults,
    String? oneOnOneFormatName,
    SessionConfig? sessionConfig,
    String? discussionDeckTypeName,
    String? deckLabel,
    List<String>? diceThemes,
  }) {
    final now = DateTime.now();
    final rand = Random().nextInt(1000000);
    return SessionRecord(
      id: '${now.millisecondsSinceEpoch}-$rand',
      playedAt: now,
      mode: mode,
      topics: topics,
      selectedCardsByPlayer: selectedCardsByPlayer,
      playerCount: playerCount,
      playerNames: playerNames ?? const [],
      voteResults: voteResults ?? {},
      oneOnOneFormatName: oneOnOneFormatName,
      sessionConfig: sessionConfig,
      discussionDeckTypeName: discussionDeckTypeName,
      deckLabel: deckLabel,
      diceThemes: diceThemes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playedAt': playedAt.toIso8601String(),
      'mode': mode,
      'topics': topics,
      'selectedCardsByPlayer': selectedCardsByPlayer,
      'playerCount': playerCount,
      'playerNames': playerNames,
      'voteResults': voteResults,
      if (oneOnOneFormatName != null) 'oneOnOneFormatName': oneOnOneFormatName,
      if (sessionConfig != null) 'sessionConfig': sessionConfig!.toJson(),
      if (discussionDeckTypeName != null)
        'discussionDeckTypeName': discussionDeckTypeName,
      if (deckLabel != null) 'deckLabel': deckLabel,
      if (diceThemes != null) 'diceThemes': diceThemes,
    };
  }

  factory SessionRecord.fromMap(Map<dynamic, dynamic> map) {
    final topicsRaw = map['topics'] as List<dynamic>? ?? [];
    final selectedRaw =
        map['selectedCardsByPlayer'] as Map<dynamic, dynamic>? ?? {};
    final selectedConverted = <String, List<String>>{};
    for (final entry in selectedRaw.entries) {
      final key = entry.key?.toString() ?? '';
      final list =
          (entry.value as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      if (key.isNotEmpty) {
        selectedConverted[key] = list;
      }
    }
    final playerNamesRaw = map['playerNames'] as List<dynamic>? ?? [];
    final voteRaw = map['voteResults'] as Map<dynamic, dynamic>? ?? {};
    final voteConverted = <String, int>{};
    for (final entry in voteRaw.entries) {
      final key = entry.key?.toString() ?? '';
      if (key.isEmpty) {
        continue;
      }
      final value = entry.value;
      if (value is int) {
        voteConverted[key] = value;
      } else if (value != null) {
        final parsed = int.tryParse(value.toString());
        if (parsed != null) {
          voteConverted[key] = parsed;
        }
      }
    }
    final configRaw = map['sessionConfig'];
    SessionConfig? sessionConfig;
    if (configRaw is Map) {
      try {
        sessionConfig = SessionConfig.fromJson(
          Map<String, dynamic>.from(configRaw),
        );
      } catch (_) {
        sessionConfig = null;
      }
    }
    final themesRaw = map['diceThemes'] as List<dynamic>?;
    return SessionRecord(
      id: map['id']?.toString() ?? '',
      playedAt:
          DateTime.tryParse(map['playedAt']?.toString() ?? '') ?? DateTime.now(),
      mode: map['mode']?.toString() ?? 'dice',
      topics: topicsRaw.map((e) => e.toString()).toList(),
      selectedCardsByPlayer: selectedConverted,
      playerCount: map['playerCount'] is int ? map['playerCount'] as int : null,
      playerNames: playerNamesRaw
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      voteResults: voteConverted,
      oneOnOneFormatName: map['oneOnOneFormatName']?.toString(),
      sessionConfig: sessionConfig,
      discussionDeckTypeName: map['discussionDeckTypeName']?.toString(),
      deckLabel: map['deckLabel']?.toString(),
      diceThemes: themesRaw?.map((e) => e.toString()).toList(),
    );
  }
}
