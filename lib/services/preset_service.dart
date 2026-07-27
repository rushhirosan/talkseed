import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/services/purchase_service.dart';

/// 端末内に名前付きセッション設定を保存する（外部送信なし）
class PresetService {
  PresetService._();

  static const _storageKey = 'session_presets_v1';

  /// Pro 時の絶対上限（無料枠は [PurchaseService.freePresetLimit]）
  static const int maxPresets = PurchaseService.proPresetLimit;

  static Future<List<SessionPreset>> listPresets({
    SessionPresetMode? mode,
  }) async {
    final all = _sorted(await _loadAll());
    if (mode == null) {
      return all;
    }
    return all.where((p) => p.mode == mode).toList();
  }

  /// ホーム Quick Start 用（最近使った順、最大 [limit] 件）
  static Future<List<SessionPreset>> listRecentPresets({int limit = 3}) async {
    final all = _sorted(await _loadAll());
    if (all.length <= limit) {
      return all;
    }
    return all.sublist(0, limit);
  }

  static Future<void> markPresetUsed(String id) async {
    final presets = await _loadAll();
    final index = presets.indexWhere((p) => p.id == id);
    if (index < 0) {
      return;
    }
    final now = DateTime.now();
    presets[index] = presets[index].copyWith(lastUsedAt: now);
    await _persist(_sorted(presets));
  }

  static List<SessionPreset> _sorted(List<SessionPreset> presets) {
    return [...presets]..sort((a, b) => b.sortKey.compareTo(a.sortKey));
  }

  static Future<SessionPreset> saveOneOnOnePreset({
    required String name,
    required OneOnOneSessionFormat format,
    String? existingId,
  }) async {
    final trimmed = _validateName(name);
    final presets = await _loadAll();
    await _ensureCapacity(presets, existingId);

    final now = DateTime.now();
    final preset = SessionPreset.oneOnOne(
      id: existingId ?? now.microsecondsSinceEpoch.toString(),
      name: trimmed,
      format: format,
      updatedAt: now,
      lastUsedAt: _preservedLastUsedAt(presets, existingId),
    );

    await _upsert(presets, preset);
    return preset;
  }

  static Future<SessionPreset> saveGroupDiscussionPreset({
    required String name,
    required SessionConfig config,
    required CardDeckType discussionDeckType,
    String? deckLabel,
    String? existingId,
  }) async {
    final trimmed = _validateName(name);
    _validateDiscussionConfig(config);
    final presets = await _loadAll();
    await _ensureCapacity(presets, existingId);

    final now = DateTime.now();
    final preset = SessionPreset.groupDiscussion(
      id: existingId ?? now.microsecondsSinceEpoch.toString(),
      name: trimmed,
      config: config,
      discussionDeckType: discussionDeckType,
      deckLabel: deckLabel,
      updatedAt: now,
      lastUsedAt: _preservedLastUsedAt(presets, existingId),
    );

    await _upsert(presets, preset);
    return preset;
  }

  static Future<SessionPreset> saveValueCardsPreset({
    required String name,
    required SessionConfig config,
    String? existingId,
  }) async {
    final trimmed = _validateName(name);
    final presets = await _loadAll();
    await _ensureCapacity(presets, existingId);

    final now = DateTime.now();
    final preset = SessionPreset.valueCards(
      id: existingId ?? now.microsecondsSinceEpoch.toString(),
      name: trimmed,
      config: _basicSessionConfigSnapshot(config),
      updatedAt: now,
      lastUsedAt: _preservedLastUsedAt(presets, existingId),
    );

    await _upsert(presets, preset);
    return preset;
  }

  static Future<SessionPreset> saveDicePreset({
    required String name,
    required List<String> diceThemes,
    required SessionConfig config,
    String? existingId,
  }) async {
    final trimmed = _validateName(name);
    _validateDiceThemes(diceThemes);
    final presets = await _loadAll();
    await _ensureCapacity(presets, existingId);

    final now = DateTime.now();
    final preset = SessionPreset.dice(
      id: existingId ?? now.microsecondsSinceEpoch.toString(),
      name: trimmed,
      diceThemes: List<String>.from(diceThemes),
      config: _basicSessionConfigSnapshot(config),
      updatedAt: now,
      lastUsedAt: _preservedLastUsedAt(presets, existingId),
    );

    await _upsert(presets, preset);
    return preset;
  }

  static String _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw PresetValidationException.emptyName();
    }
    return trimmed;
  }

  static Future<void> _ensureCapacity(
    List<SessionPreset> presets,
    String? existingId,
  ) async {
    if (existingId != null) {
      return;
    }
    final max = await PurchaseService.maxPresetsAllowed();
    if (presets.length >= max) {
      throw PresetValidationException.maxPresetsReached(max);
    }
  }

  static void _validateDiscussionConfig(SessionConfig config) {
    final ids = config.discussionCategoryIds;
    if (ids != null && ids.isEmpty) {
      throw PresetValidationException.invalidConfig();
    }
  }

  static void _validateDiceThemes(List<String> themes) {
    if (themes.length != 6) {
      throw PresetValidationException.invalidConfig();
    }
  }

  static SessionConfig _basicSessionConfigSnapshot(SessionConfig config) {
    return SessionConfig(
      playerCount: config.playerCount,
      timerDuration: config.timerDuration,
      enableTimer: config.enableTimer,
      playerNames: config.playerNames,
    );
  }

  static DateTime? _preservedLastUsedAt(
    List<SessionPreset> presets,
    String? existingId,
  ) {
    if (existingId == null) {
      return null;
    }
    for (final p in presets) {
      if (p.id == existingId) {
        return p.lastUsedAt;
      }
    }
    return null;
  }

  static Future<void> _upsert(
    List<SessionPreset> presets,
    SessionPreset preset,
  ) async {
    final next = [
      for (final p in presets)
        if (p.id != preset.id) p,
      preset,
    ];
    await _persist(_sorted(next));
  }

  static Future<void> deletePreset(String id) async {
    final presets = await _loadAll();
    await _persist(presets.where((p) => p.id != id).toList());
  }

  static Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static Future<List<SessionPreset>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => SessionPreset.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _persist(List<SessionPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(presets.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}

class PresetValidationException implements Exception {
  final String code;

  const PresetValidationException(this.code);

  factory PresetValidationException.emptyName() =>
      const PresetValidationException('empty_name');

  factory PresetValidationException.maxPresetsReached(int max) =>
      PresetValidationException('max_presets_$max');

  factory PresetValidationException.invalidConfig() =>
      const PresetValidationException('invalid_config');

  bool get isEmptyName => code == 'empty_name';

  bool get isMaxPresetsReached => code.startsWith('max_presets_');

  bool get isInvalidConfig => code == 'invalid_config';
}
