import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/services/preset_service.dart';
import 'package:theme_dice/services/purchase_service.dart';
import 'package:theme_dice/utils/session_record_preset_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PresetService.resetForTesting();
    await PurchaseService.resetForTesting();
    await PurchaseService.unlockPro();
  });

  tearDown(() async {
    await PresetService.resetForTesting();
    await PurchaseService.resetForTesting();
  });

  test('legacy record without snapshot cannot save as preset', () {
    final record = SessionRecord.create(
      mode: SessionRecord.modeOneOnOne,
      topics: const [],
      selectedCardsByPlayer: const {'checkin': ['Q']},
    );
    expect(SessionRecordPresetFactory.canSaveAsPreset(record), isFalse);
  });

  test('oneOnOne record saves preset from format name', () async {
    final record = SessionRecord.create(
      mode: SessionRecord.modeOneOnOne,
      topics: const [],
      selectedCardsByPlayer: const {},
      oneOnOneFormatName: OneOnOneSessionFormat.growth.name,
    );
    expect(SessionRecordPresetFactory.canSaveAsPreset(record), isTrue);

    final preset = await SessionRecordPresetFactory.saveAsPreset(
      record: record,
      name: 'From history',
    );
    expect(preset.mode, SessionPresetMode.oneOnOne);
    expect(preset.oneOnOneFormat, OneOnOneSessionFormat.growth);
  });

  test('discussion record saves preset from config snapshot', () async {
    const config = SessionConfig(
      playerCount: 4,
      timerDuration: Duration(minutes: 5),
      enableTimer: true,
      discussionPromptsPerCategory: 2,
    );
    final record = SessionRecord.create(
      mode: SessionRecord.modeDiscussion,
      topics: const ['A'],
      selectedCardsByPlayer: const {},
      playerCount: 4,
      sessionConfig: config,
      discussionDeckTypeName: CardDeckType.groupDiscussion.name,
      deckLabel: 'Group',
    );

    final preset = await SessionRecordPresetFactory.saveAsPreset(
      record: record,
      name: 'Weekly ethics',
    );
    expect(preset.mode, SessionPresetMode.groupDiscussion);
    expect(preset.discussionDeckType, CardDeckType.groupDiscussion);
    expect(preset.sessionConfig?.playerCount, 4);
  });

  test('dice record saves with six themes', () async {
    final record = SessionRecord.create(
      mode: SessionRecord.modeDice,
      topics: const ['rolled'],
      selectedCardsByPlayer: const {},
      playerCount: 3,
      diceThemes: const ['a', 'b', 'c', 'd', 'e', 'f'],
      sessionConfig: const SessionConfig(
        playerCount: 3,
        timerDuration: Duration(minutes: 3),
      ),
    );

    final preset = await SessionRecordPresetFactory.saveAsPreset(
      record: record,
      name: 'Friday dice',
    );
    expect(preset.mode, SessionPresetMode.dice);
    expect(preset.diceThemes, ['a', 'b', 'c', 'd', 'e', 'f']);
  });
}
