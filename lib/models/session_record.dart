import 'dart:math';

/// セッション履歴の保存用モデル（端末内ローカル）
class SessionRecord {
  final String id;
  final DateTime playedAt;
  /// 'dice' | 'value_cards'
  final String mode;
  /// 出たテーマ一覧（サイコロ用）
  final List<String> topics;
  /// 選択カード（価値観カード用：プレイヤー名 -> カード一覧）
  final Map<String, List<String>> selectedCardsByPlayer;
  /// 参加人数（不明なら null）
  final int? playerCount;

  SessionRecord({
    required this.id,
    required this.playedAt,
    required this.mode,
    required this.topics,
    required this.selectedCardsByPlayer,
    this.playerCount,
  });

  factory SessionRecord.create({
    required String mode,
    required List<String> topics,
    required Map<String, List<String>> selectedCardsByPlayer,
    int? playerCount,
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
    };
  }

  factory SessionRecord.fromMap(Map<dynamic, dynamic> map) {
    final topicsRaw = map['topics'] as List<dynamic>? ?? [];
    final selectedRaw = map['selectedCardsByPlayer'] as Map<dynamic, dynamic>? ?? {};
    final selectedConverted = <String, List<String>>{};
    for (final entry in selectedRaw.entries) {
      final key = entry.key?.toString() ?? '';
      final list = (entry.value as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      if (key.isNotEmpty) {
        selectedConverted[key] = list;
      }
    }
    return SessionRecord(
      id: map['id']?.toString() ?? '',
      playedAt: DateTime.tryParse(map['playedAt']?.toString() ?? '') ?? DateTime.now(),
      mode: map['mode']?.toString() ?? 'dice',
      topics: topicsRaw.map((e) => e.toString()).toList(),
      selectedCardsByPlayer: selectedConverted,
      playerCount: map['playerCount'] is int ? map['playerCount'] as int : null,
    );
  }
}
