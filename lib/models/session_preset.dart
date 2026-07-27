import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';
import 'package:theme_dice/models/session_config.dart';

/// 保存可能なセッションモード
enum SessionPresetMode {
  oneOnOne,
  groupDiscussion,
  valueCards,
  dice,
}

/// 名前付きセッション設定（Pro 向け機能の基盤）
class SessionPreset {
  final String id;
  final String name;
  final SessionPresetMode mode;
  final OneOnOneSessionFormat? oneOnOneFormat;
  final SessionConfig? sessionConfig;
  final CardDeckType? discussionDeckType;
  final String? deckLabel;
  final List<String>? diceThemes;
  final DateTime updatedAt;

  /// ホーム Quick Start の並び順用（未使用時は [updatedAt] でソート）
  final DateTime? lastUsedAt;

  const SessionPreset({
    required this.id,
    required this.name,
    required this.mode,
    this.oneOnOneFormat,
    this.sessionConfig,
    this.discussionDeckType,
    this.deckLabel,
    this.diceThemes,
    required this.updatedAt,
    this.lastUsedAt,
  });

  /// Quick Start / ライブラリのソートキー
  DateTime get sortKey => lastUsedAt ?? updatedAt;

  factory SessionPreset.oneOnOne({
    required String id,
    required String name,
    required OneOnOneSessionFormat format,
    required DateTime updatedAt,
    DateTime? lastUsedAt,
  }) {
    return SessionPreset(
      id: id,
      name: name,
      mode: SessionPresetMode.oneOnOne,
      oneOnOneFormat: format,
      updatedAt: updatedAt,
      lastUsedAt: lastUsedAt,
    );
  }

  factory SessionPreset.groupDiscussion({
    required String id,
    required String name,
    required SessionConfig config,
    required CardDeckType discussionDeckType,
    String? deckLabel,
    required DateTime updatedAt,
    DateTime? lastUsedAt,
  }) {
    return SessionPreset(
      id: id,
      name: name,
      mode: SessionPresetMode.groupDiscussion,
      sessionConfig: config,
      discussionDeckType: discussionDeckType,
      deckLabel: deckLabel,
      updatedAt: updatedAt,
      lastUsedAt: lastUsedAt,
    );
  }

  factory SessionPreset.valueCards({
    required String id,
    required String name,
    required SessionConfig config,
    required DateTime updatedAt,
    DateTime? lastUsedAt,
  }) {
    return SessionPreset(
      id: id,
      name: name,
      mode: SessionPresetMode.valueCards,
      sessionConfig: config,
      updatedAt: updatedAt,
      lastUsedAt: lastUsedAt,
    );
  }

  factory SessionPreset.dice({
    required String id,
    required String name,
    required List<String> diceThemes,
    required SessionConfig config,
    required DateTime updatedAt,
    DateTime? lastUsedAt,
  }) {
    return SessionPreset(
      id: id,
      name: name,
      mode: SessionPresetMode.dice,
      diceThemes: diceThemes,
      sessionConfig: config,
      updatedAt: updatedAt,
      lastUsedAt: lastUsedAt,
    );
  }

  SessionPreset copyWith({
    String? name,
    OneOnOneSessionFormat? oneOnOneFormat,
    SessionConfig? sessionConfig,
    CardDeckType? discussionDeckType,
    String? deckLabel,
    List<String>? diceThemes,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    bool clearLastUsedAt = false,
  }) {
    return SessionPreset(
      id: id,
      name: name ?? this.name,
      mode: mode,
      oneOnOneFormat: oneOnOneFormat ?? this.oneOnOneFormat,
      sessionConfig: sessionConfig ?? this.sessionConfig,
      discussionDeckType: discussionDeckType ?? this.discussionDeckType,
      deckLabel: deckLabel ?? this.deckLabel,
      diceThemes: diceThemes ?? this.diceThemes,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: clearLastUsedAt ? null : (lastUsedAt ?? this.lastUsedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode.name,
      if (oneOnOneFormat != null) 'oneOnOneFormat': oneOnOneFormat!.name,
      if (sessionConfig != null) 'sessionConfig': sessionConfig!.toJson(),
      if (discussionDeckType != null)
        'discussionDeckType': discussionDeckType!.name,
      if (deckLabel != null) 'deckLabel': deckLabel,
      if (diceThemes != null) 'diceThemes': diceThemes,
      'updatedAt': updatedAt.toIso8601String(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt!.toIso8601String(),
    };
  }

  factory SessionPreset.fromJson(Map<String, dynamic> json) {
    final modeName = json['mode'] as String?;
    final mode = SessionPresetMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => SessionPresetMode.oneOnOne,
    );
    final formatName = json['oneOnOneFormat'] as String?;
    OneOnOneSessionFormat? format;
    if (formatName != null) {
      for (final candidate in OneOnOneSessionFormat.values) {
        if (candidate.name == formatName) {
          format = candidate;
          break;
        }
      }
    }
    final configRaw = json['sessionConfig'] as Map<String, dynamic>?;
    final deckTypeName = json['discussionDeckType'] as String?;
    CardDeckType? deckType;
    if (deckTypeName != null) {
      for (final candidate in CardDeckType.values) {
        if (candidate.name == deckTypeName) {
          deckType = candidate;
          break;
        }
      }
    }
    final themesRaw = json['diceThemes'] as List<dynamic>?;
    final lastUsedRaw = json['lastUsedAt'] as String?;
    return SessionPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: mode,
      oneOnOneFormat: format,
      sessionConfig:
          configRaw != null ? SessionConfig.fromJson(configRaw) : null,
      discussionDeckType: deckType,
      deckLabel: json['deckLabel'] as String?,
      diceThemes: themesRaw?.map((e) => e as String).toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastUsedAt:
          lastUsedRaw != null ? DateTime.parse(lastUsedRaw) : null,
    );
  }
}
