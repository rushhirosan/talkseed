import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/services/preset_service.dart';

/// 履歴 [SessionRecord] からプリセットを復元・保存する（P4.3）。
class SessionRecordPresetFactory {
  SessionRecordPresetFactory._();

  /// この履歴からプリセット化できるか（設定スナップショットがあるか）
  static bool canSaveAsPreset(SessionRecord record) {
    return _resolveMode(record) != null;
  }

  /// 名前を付けて [PresetService] に保存する。
  /// 不可のときは [PresetValidationException] または [StateError]。
  static Future<SessionPreset> saveAsPreset({
    required SessionRecord record,
    required String name,
  }) async {
    final mode = _resolveMode(record);
    if (mode == null) {
      throw StateError('preset_unavailable');
    }

    switch (mode) {
      case SessionPresetMode.oneOnOne:
        final format = _oneOnOneFormat(record);
        if (format == null) {
          throw StateError('preset_unavailable');
        }
        return PresetService.saveOneOnOnePreset(name: name, format: format);
      case SessionPresetMode.groupDiscussion:
        final config = record.sessionConfig;
        final deckType = _discussionDeckType(record);
        if (config == null || deckType == null) {
          throw StateError('preset_unavailable');
        }
        return PresetService.saveGroupDiscussionPreset(
          name: name,
          config: config,
          discussionDeckType: deckType,
          deckLabel: record.deckLabel,
        );
      case SessionPresetMode.valueCards:
        final config = _sessionConfigOrBasic(record);
        if (config == null) {
          throw StateError('preset_unavailable');
        }
        return PresetService.saveValueCardsPreset(name: name, config: config);
      case SessionPresetMode.dice:
        final themes = record.diceThemes;
        final config =
            _sessionConfigOrBasic(record) ?? SessionConfig.defaultConfig;
        if (themes == null || themes.length != 6) {
          throw StateError('preset_unavailable');
        }
        return PresetService.saveDicePreset(
          name: name,
          diceThemes: themes,
          config: config,
        );
    }
  }

  static SessionPresetMode? _resolveMode(SessionRecord record) {
    switch (record.mode) {
      case SessionRecord.modeOneOnOne:
        return _oneOnOneFormat(record) != null
            ? SessionPresetMode.oneOnOne
            : null;
      case SessionRecord.modeDiscussion:
        return record.sessionConfig != null &&
                _discussionDeckType(record) != null
            ? SessionPresetMode.groupDiscussion
            : null;
      case SessionRecord.modeValueCards:
        return _sessionConfigOrBasic(record) != null
            ? SessionPresetMode.valueCards
            : null;
      case SessionRecord.modeDice:
        final themes = record.diceThemes;
        return themes != null && themes.length == 6
            ? SessionPresetMode.dice
            : null;
      default:
        return null;
    }
  }

  static OneOnOneSessionFormat? _oneOnOneFormat(SessionRecord record) {
    final name = record.oneOnOneFormatName;
    if (name == null) return null;
    for (final format in OneOnOneSessionFormat.values) {
      if (format.name == name) return format;
    }
    return null;
  }

  static CardDeckType? _discussionDeckType(SessionRecord record) {
    final name = record.discussionDeckTypeName;
    if (name == null) return null;
    for (final type in CardDeckType.values) {
      if (type.name == name) return type;
    }
    return null;
  }

  /// 価値観・サイコロ用。保存時の config がなければ人数・名前だけ復元。
  static SessionConfig? _sessionConfigOrBasic(SessionRecord record) {
    if (record.sessionConfig != null) {
      return record.sessionConfig;
    }
    final count = record.playerCount;
    if (count == null || count < 2 || count > 10) {
      return null;
    }
    return SessionConfig(
      playerCount: count,
      timerDuration: SessionConfig.defaultConfig.timerDuration,
      enableTimer: SessionConfig.defaultConfig.enableTimer,
      playerNames: record.playerNames.isEmpty ? null : record.playerNames,
    );
  }
}
