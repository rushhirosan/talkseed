import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/models/usage_stats_snapshot.dart';
import 'package:theme_dice/services/usage_stats_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UsageStatsService.resetForTesting();
  });

  tearDown(() async {
    await UsageStatsService.resetForTesting();
  });

  test('increments total and weekly count per mode', () async {
    await UsageStatsService.recordSessionCompleted(SessionRecord.modeOneOnOne);
    await UsageStatsService.recordSessionCompleted(SessionRecord.modeOneOnOne);
    await UsageStatsService.recordSessionCompleted(SessionRecord.modeDice);

    final snapshot = await UsageStatsService.getSnapshot();
    expect(snapshot.countForMode(SessionRecord.modeOneOnOne), 2);
    expect(snapshot.countForMode(SessionRecord.modeDice), 1);
    expect(snapshot.weeklyCountForMode(SessionRecord.modeOneOnOne), 2);
    expect(snapshot.weeklyTotal, 3);
    expect(snapshot.lastSessionAt, isNotNull);
  });

  test('ignores unknown mode', () async {
    await UsageStatsService.recordSessionCompleted('mashup');

    final snapshot = await UsageStatsService.getSnapshot();
    expect(snapshot.totalByMode, isEmpty);
  });

  test('shouldProceedToIapStep is false below Go threshold', () async {
    await UsageStatsService.recordSessionCompleted(SessionRecord.modeDice);
    await UsageStatsService.recordSessionCompleted(SessionRecord.modeDice);

    expect(await UsageStatsService.shouldProceedToIapStep(), isFalse);
  });

  test('shouldProceedToIapStep is true when work modes reach weekly threshold',
      () async {
    for (var i = 0; i < UsageStatsGoCriteria.weeklyWorkModeSessions; i++) {
      await UsageStatsService.recordSessionCompleted(
        SessionRecord.modeOneOnOne,
      );
    }

    expect(await UsageStatsService.shouldProceedToIapStep(), isTrue);
  });

  test('shouldProceedToIapStep is true when weekly total reaches threshold',
      () async {
    for (var i = 0; i < UsageStatsGoCriteria.weeklyTotalSessions; i++) {
      await UsageStatsService.recordSessionCompleted(SessionRecord.modeDice);
    }

    expect(await UsageStatsService.shouldProceedToIapStep(), isTrue);
  });

  test('UsageStatsGoCriteria.meets with discussion counts as work mode', () {
    const snapshot = UsageStatsSnapshot(
      totalByMode: {SessionRecord.modeDiscussion: 3},
      weeklyByMode: {SessionRecord.modeDiscussion: 3},
    );

    expect(UsageStatsGoCriteria.meets(snapshot), isTrue);
  });

  test('recordExportAttempt increments total and weekly counters', () async {
    await UsageStatsService.recordExportAttempt();
    await UsageStatsService.recordExportAttempt();

    final snapshot = await UsageStatsService.getSnapshot();
    expect(snapshot.exportAttemptCount, 2);
    expect(snapshot.weeklyExportAttemptCount, 2);
  });
}
