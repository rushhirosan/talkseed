import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:theme_dice/l10n/app_localizations_en.dart';
import 'package:theme_dice/l10n/app_localizations_ja.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/utils/session_record_share_text.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ja');
  });

  group('formatSessionRecordShareText', () {
    final playedAt = DateTime(2026, 6, 23);

    SessionRecord diceRecord({
      List<String> topics = const ['Topic A'],
      Map<String, int> voteResults = const {'Alice': 2, 'Bob': 1},
    }) {
      return SessionRecord(
        id: 'test-dice',
        playedAt: playedAt,
        mode: SessionRecord.modeDice,
        topics: topics,
        selectedCardsByPlayer: const {},
        playerCount: 2,
        playerNames: const ['Alice', 'Bob'],
        voteResults: voteResults,
      );
    }

    test('includes header, summary, topics, votes, and footer in English', () {
      final text = formatSessionRecordShareText(
        diceRecord(),
        AppLocalizationsEn('en'),
      );

      expect(text, contains('Talk Shuffle — Session Record'));
      expect(text, contains('Participants'));
      expect(text, contains('・Alice'));
      expect(text, contains('Topics'));
      expect(text, contains('・Topic A'));
      expect(text, contains('Voting results'));
      expect(text, contains('Alice — 2 votes'));
      expect(text, contains('Exported from Talk Shuffle'));
      expect(text, isNot(contains('Player 1')));
    });

    test('includes Japanese labels', () {
      final text = formatSessionRecordShareText(
        diceRecord(voteResults: const {}),
        AppLocalizationsJa('ja'),
      );

      expect(text, contains('Talk Shuffle — セッション記録'));
      expect(text, contains('参加者'));
      expect(text, contains('出たテーマ'));
      expect(text, contains('Talk Shuffle からエクスポート'));
    });

    test('formats value cards by player', () {
      final record = SessionRecord(
        id: 'test-values',
        playedAt: playedAt,
        mode: SessionRecord.modeValueCards,
        topics: const [],
        selectedCardsByPlayer: const {
          'Alice': ['Honesty'],
          'Bob': ['Growth'],
        },
        playerCount: 2,
        playerNames: const ['Alice', 'Bob'],
        voteResults: const {},
      );

      final text = formatSessionRecordShareText(
        record,
        AppLocalizationsEn('en'),
      );

      expect(text, contains('Selected cards'));
      expect(text, contains('Alice'));
      expect(text, contains('・Honesty'));
      expect(text, contains('Bob'));
      expect(text, contains('・Growth'));
    });

    test('formats discussion prompts without flat topics', () {
      final record = SessionRecord(
        id: 'test-discussion',
        playedAt: playedAt,
        mode: SessionRecord.modeDiscussion,
        topics: const ['Should not appear alone'],
        selectedCardsByPlayer: const {
          'Alice': ['Prompt 1', 'Prompt 2'],
        },
        playerCount: 2,
        playerNames: const ['Alice', 'Bob'],
        voteResults: const {},
      );

      final text = formatSessionRecordShareText(
        record,
        AppLocalizationsEn('en'),
      );

      expect(text, contains('Prompts by player'));
      expect(text, contains('・Prompt 1'));
      expect(text, isNot(contains('Should not appear alone')));
      expect(text, contains('Another prompt'));
    });

    test('formats one-on-one prompts by phase', () {
      final record = SessionRecord(
        id: 'test-1on1',
        playedAt: playedAt,
        mode: SessionRecord.modeOneOnOne,
        topics: const [],
        selectedCardsByPlayer: const {
          'checkin': ['How are you today?'],
          'closing': ['Anything else?'],
        },
        voteResults: const {},
      );

      final text = formatSessionRecordShareText(
        record,
        AppLocalizationsEn('en'),
      );

      expect(text, contains('Prompts discussed'));
      expect(text, contains('Check-in'));
      expect(text, contains('・How are you today?'));
      expect(text, contains('Closing'));
      expect(text, contains('・Anything else?'));
      expect(text, isNot(contains('Participants')));
    });
  });
}
