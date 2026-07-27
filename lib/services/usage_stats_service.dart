import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/models/usage_stats_snapshot.dart';

/// セッション完了の端末内集計（モード別・週次）。外部サーバーへは送信しない。
///
/// Go 基準は [UsageStatsGoCriteria] と [data/usage_stats_policy.md] を参照。
class UsageStatsService {
  UsageStatsService._();

  static const _keyTotalByMode = 'usage_stats_total_by_mode';
  static const _keyWeekKey = 'usage_stats_week_key';
  static const _keyWeeklyByMode = 'usage_stats_weekly_by_mode';
  static const _keyLastSessionAt = 'usage_stats_last_session_at';
  static const _keyExportAttempts = 'usage_stats_export_attempts';
  static const _keyWeeklyExportAttempts = 'usage_stats_weekly_export_attempts';

  static const Set<String> _knownModes = {
    SessionRecord.modeDice,
    SessionRecord.modeValueCards,
    SessionRecord.modeDiscussion,
    SessionRecord.modeOneOnOne,
  };

  /// セッション完了時に呼ぶ（[SessionRecordService.addRecord] から連携）
  static Future<void> recordSessionCompleted(String mode) async {
    if (!_knownModes.contains(mode)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = _isoWeekKey(now);

    final totalByMode = _decodeIntMap(prefs.getString(_keyTotalByMode));
    totalByMode[mode] = (totalByMode[mode] ?? 0) + 1;

    final weekly = await _ensureCurrentWeek(prefs, weekKey);
    weekly.byMode[mode] = (weekly.byMode[mode] ?? 0) + 1;

    await prefs.setString(_keyTotalByMode, jsonEncode(totalByMode));
    await prefs.setString(_keyWeekKey, weekKey);
    await prefs.setString(_keyWeeklyByMode, jsonEncode(weekly.byMode));
    await prefs.setInt(_keyWeeklyExportAttempts, weekly.exportAttempts);
    await prefs.setString(_keyLastSessionAt, now.toIso8601String());
  }

  /// 履歴共有ボタンのタップ（試行）。ペイウォールで止まった場合も含む。
  static Future<void> recordExportAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final weekKey = _isoWeekKey(DateTime.now());
    final total = (prefs.getInt(_keyExportAttempts) ?? 0) + 1;
    final weekly = await _ensureCurrentWeek(prefs, weekKey);
    weekly.exportAttempts += 1;

    await prefs.setInt(_keyExportAttempts, total);
    await prefs.setString(_keyWeekKey, weekKey);
    await prefs.setString(_keyWeeklyByMode, jsonEncode(weekly.byMode));
    await prefs.setInt(_keyWeeklyExportAttempts, weekly.exportAttempts);
  }

  static Future<UsageStatsSnapshot> getSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final weekKey = _isoWeekKey(DateTime.now());
    final weekly = await _ensureCurrentWeek(prefs, weekKey);

    final lastRaw = prefs.getString(_keyLastSessionAt);
    return UsageStatsSnapshot(
      totalByMode: _decodeIntMap(prefs.getString(_keyTotalByMode)),
      weeklyByMode: weekly.byMode,
      lastSessionAt:
          lastRaw != null ? DateTime.tryParse(lastRaw) : null,
      exportAttemptCount: prefs.getInt(_keyExportAttempts) ?? 0,
      weeklyExportAttemptCount: weekly.exportAttempts,
    );
  }

  /// Step 2（IAP 本格着手）の Go 判定。端末内集計のみで評価する。
  static Future<bool> shouldProceedToIapStep() async {
    final snapshot = await getSnapshot();
    return UsageStatsGoCriteria.meets(snapshot);
  }

  /// テスト用: 集計をリセット
  static Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTotalByMode);
    await prefs.remove(_keyWeekKey);
    await prefs.remove(_keyWeeklyByMode);
    await prefs.remove(_keyLastSessionAt);
    await prefs.remove(_keyExportAttempts);
    await prefs.remove(_keyWeeklyExportAttempts);
  }

  static Future<_WeeklyBucket> _ensureCurrentWeek(
    SharedPreferences prefs,
    String weekKey,
  ) async {
    final storedWeekKey = prefs.getString(_keyWeekKey);
    if (storedWeekKey == weekKey) {
      return _WeeklyBucket(
        byMode: _decodeIntMap(prefs.getString(_keyWeeklyByMode)),
        exportAttempts: prefs.getInt(_keyWeeklyExportAttempts) ?? 0,
      );
    }
    return _WeeklyBucket(byMode: {}, exportAttempts: 0);
  }

  static Map<String, int> _decodeIntMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );
    } catch (_) {
      return {};
    }
  }

  /// ISO 8601 週番号キー（月曜始まり）
  static String _isoWeekKey(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    final weekday = utc.weekday;
    final thursday = utc.add(Duration(days: 4 - weekday));
    final yearStart = DateTime.utc(thursday.year, 1, 1);
    final weekNumber =
        ((thursday.difference(yearStart).inDays) / 7).floor() + 1;
    return '${thursday.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }
}

class _WeeklyBucket {
  _WeeklyBucket({
    required this.byMode,
    required this.exportAttempts,
  });

  final Map<String, int> byMode;
  int exportAttempts;
}

/// 収益化 Step 2 着手の Go 基準（[data/usage_stats_policy.md] と同期）
class UsageStatsGoCriteria {
  UsageStatsGoCriteria._();

  /// 1on1 またはグループディスカッションの週次完了数がこの値以上
  static const int weeklyWorkModeSessions = 3;

  /// 全モード合計の週次完了数がこの値以上（work 以外も含む）
  static const int weeklyTotalSessions = 5;

  static bool meets(UsageStatsSnapshot snapshot) {
    final workWeekly = snapshot.weeklyCountForMode(SessionRecord.modeOneOnOne) +
        snapshot.weeklyCountForMode(SessionRecord.modeDiscussion);
    if (workWeekly >= weeklyWorkModeSessions) {
      return true;
    }
    return snapshot.weeklyTotal >= weeklyTotalSessions;
  }
}
