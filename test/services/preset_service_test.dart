import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/services/preset_service.dart';
import 'package:theme_dice/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PresetService.resetForTesting();
    await PurchaseService.resetForTesting();
    // プリセット CRUD テストは Pro 上限で検証（無料枠ゲートは purchase_service_test）
    await PurchaseService.unlockPro();
  });

  tearDown(() async {
    await PresetService.resetForTesting();
    await PurchaseService.resetForTesting();
  });

  test('saveOneOnOnePreset persists and lists by mode', () async {
    await PresetService.saveOneOnOnePreset(
      name: 'Weekly lite',
      format: OneOnOneSessionFormat.lite,
    );
    await PresetService.saveOneOnOnePreset(
      name: 'Deep dive',
      format: OneOnOneSessionFormat.growth,
    );

    final presets =
        await PresetService.listPresets(mode: SessionPresetMode.oneOnOne);
    expect(presets, hasLength(2));
    expect(presets.map((p) => p.name), containsAll(['Weekly lite', 'Deep dive']));
    expect(
      presets.firstWhere((p) => p.name == 'Weekly lite').oneOnOneFormat,
      OneOnOneSessionFormat.lite,
    );
  });

  test('saveOneOnOnePreset rejects empty name', () async {
    expect(
      () => PresetService.saveOneOnOnePreset(
        name: '   ',
        format: OneOnOneSessionFormat.full,
      ),
      throwsA(isA<PresetValidationException>()),
    );
  });

  test('saveOneOnOnePreset enforces max preset count', () async {
    for (var i = 0; i < PresetService.maxPresets; i++) {
      await PresetService.saveOneOnOnePreset(
        name: 'Preset $i',
        format: OneOnOneSessionFormat.lite,
      );
    }

    expect(
      () => PresetService.saveOneOnOnePreset(
        name: 'One too many',
        format: OneOnOneSessionFormat.lite,
      ),
      throwsA(isA<PresetValidationException>()),
    );
  });

  test('free tier allows one preset then blocks', () async {
    await PurchaseService.lockProForTesting();
    await PurchaseService.setDebugGatingEnabled(true);

    await PresetService.saveOneOnOnePreset(
      name: 'Trial',
      format: OneOnOneSessionFormat.lite,
    );

    expect(
      () => PresetService.saveOneOnOnePreset(
        name: 'Second',
        format: OneOnOneSessionFormat.lite,
      ),
      throwsA(isA<PresetValidationException>()),
    );
  });

  test('deletePreset removes entry', () async {
    final saved = await PresetService.saveOneOnOnePreset(
      name: 'Remove me',
      format: OneOnOneSessionFormat.relationship,
    );

    await PresetService.deletePreset(saved.id);

    final presets = await PresetService.listPresets();
    expect(presets, isEmpty);
  });

  test('SessionPreset round-trips through json', () {
    final preset = SessionPreset.oneOnOne(
      id: 'abc',
      name: 'Test',
      format: OneOnOneSessionFormat.full,
      updatedAt: DateTime.utc(2026, 7, 6),
      lastUsedAt: DateTime.utc(2026, 7, 5),
    );

    final restored =
        SessionPreset.fromJson(preset.toJson() as Map<String, dynamic>);

    expect(restored.id, preset.id);
    expect(restored.name, preset.name);
    expect(restored.mode, SessionPresetMode.oneOnOne);
    expect(restored.oneOnOneFormat, OneOnOneSessionFormat.full);
    expect(restored.updatedAt, preset.updatedAt);
    expect(restored.lastUsedAt, preset.lastUsedAt);
  });

  test('markPresetUsed updates lastUsedAt and listRecentPresets orders by it',
      () async {
    final a = await PresetService.saveOneOnOnePreset(
      name: 'A',
      format: OneOnOneSessionFormat.lite,
    );
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final b = await PresetService.saveOneOnOnePreset(
      name: 'B',
      format: OneOnOneSessionFormat.growth,
    );

    await PresetService.markPresetUsed(a.id);

    final recent = await PresetService.listRecentPresets(limit: 2);
    expect(recent.first.id, a.id);
    expect(recent.last.id, b.id);
  });

  test('saveGroupDiscussionPreset persists discussion config', () async {
    const config = SessionConfig(
      playerCount: 5,
      timerDuration: Duration(minutes: 5),
      enableTimer: true,
      playerNames: ['Alice', 'Bob'],
      discussionPromptsPerCategory: 2,
      discussionTotalPromptsOnTable: 4,
      discussionCategoryIds: ['logic', 'ethics'],
    );

    await PresetService.saveGroupDiscussionPreset(
      name: 'Weekly ethics',
      config: config,
      discussionDeckType: CardDeckType.groupDiscussion,
      deckLabel: 'Group discussion',
    );

    final presets = await PresetService.listPresets(
      mode: SessionPresetMode.groupDiscussion,
    );
    expect(presets, hasLength(1));
    expect(presets.single.name, 'Weekly ethics');
    expect(presets.single.sessionConfig?.playerCount, 5);
    expect(
      presets.single.sessionConfig?.discussionCategoryIds,
      ['logic', 'ethics'],
    );
  });

  test('saveGroupDiscussionPreset rejects empty category selection', () async {
    const config = SessionConfig(
      playerCount: 4,
      timerDuration: Duration(minutes: 3),
      discussionCategoryIds: [],
    );

    expect(
      () => PresetService.saveGroupDiscussionPreset(
        name: 'Invalid',
        config: config,
        discussionDeckType: CardDeckType.groupDiscussion,
      ),
      throwsA(isA<PresetValidationException>()),
    );
  });

  test('saveValueCardsPreset stores only session basics', () async {
    const config = SessionConfig(
      playerCount: 6,
      timerDuration: Duration(minutes: 2),
      enableTimer: false,
      playerNames: ['Taro'],
      discussionCategoryIds: ['ignored'],
    );

    await PresetService.saveValueCardsPreset(
      name: 'Team values',
      config: config,
    );

    final presets =
        await PresetService.listPresets(mode: SessionPresetMode.valueCards);
    expect(presets, hasLength(1));
    final saved = presets.single.sessionConfig!;
    expect(saved.playerCount, 6);
    expect(saved.enableTimer, isFalse);
    expect(saved.discussionCategoryIds, isNull);
  });

  test('SessionPreset groupDiscussion round-trips through json', () {
    final preset = SessionPreset.groupDiscussion(
      id: 'disc-1',
      name: 'Ethics night',
      config: const SessionConfig(
        playerCount: 4,
        timerDuration: Duration(minutes: 3),
        discussionPromptsPerCategory: 1,
        discussionCategoryIds: ['ethics'],
      ),
      discussionDeckType: CardDeckType.groupDiscussion,
      deckLabel: 'Group discussion',
      updatedAt: DateTime.utc(2026, 7, 6),
    );

    final restored = SessionPreset.fromJson(preset.toJson());

    expect(restored.mode, SessionPresetMode.groupDiscussion);
    expect(restored.discussionDeckType, CardDeckType.groupDiscussion);
    expect(restored.deckLabel, 'Group discussion');
    expect(restored.sessionConfig?.discussionCategoryIds, ['ethics']);
  });

  test('saveDicePreset persists cube themes and session config', () async {
    const themes = [
      'Theme 1',
      'Theme 2',
      'Theme 3',
      'Theme 4',
      'Theme 5',
      'Theme 6',
    ];
    const config = SessionConfig(
      playerCount: 3,
      timerDuration: Duration(minutes: 2),
      enableTimer: true,
      playerNames: ['A', 'B', 'C'],
    );

    await PresetService.saveDicePreset(
      name: 'Friday dice',
      diceThemes: themes,
      config: config,
    );

    final presets =
        await PresetService.listPresets(mode: SessionPresetMode.dice);
    expect(presets, hasLength(1));
    expect(presets.single.name, 'Friday dice');
    expect(presets.single.diceThemes, themes);
    expect(presets.single.sessionConfig?.playerCount, 3);
  });

  test('saveDicePreset rejects invalid theme count', () async {
    expect(
      () => PresetService.saveDicePreset(
        name: 'Bad',
        diceThemes: ['only five', 'themes', 'here', 'now', 'x'],
        config: SessionConfig.defaultConfig,
      ),
      throwsA(isA<PresetValidationException>()),
    );
  });

  test('SessionPreset dice round-trips through json', () {
    final preset = SessionPreset.dice(
      id: 'dice-1',
      name: 'Custom night',
      diceThemes: const ['A', 'B', 'C', 'D', 'E', 'F'],
      config: const SessionConfig(
        playerCount: 4,
        timerDuration: Duration(minutes: 3),
      ),
      updatedAt: DateTime.utc(2026, 7, 7),
    );

    final restored = SessionPreset.fromJson(preset.toJson());

    expect(restored.mode, SessionPresetMode.dice);
    expect(restored.diceThemes, preset.diceThemes);
    expect(restored.sessionConfig?.playerCount, 4);
  });
}
