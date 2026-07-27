import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/services/usage_stats_service.dart';

/// セッション履歴の保存/取得を行うサービス
class SessionRecordService {
  static const String _boxName = 'session_records';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    }
  }

  static Box<Map<dynamic, dynamic>> _box() {
    return Hive.box<Map<dynamic, dynamic>>(_boxName);
  }

  static ValueListenable<Box<Map<dynamic, dynamic>>> listenable() {
    return _box().listenable();
  }

  /// [countTowardUsageStats] が true のときのみ端末内利用集計に加算する。
  /// サイコロソロの振り直し中間保存など、セッション未完了の保存は false にする。
  static Future<void> addRecord(
    SessionRecord record, {
    bool countTowardUsageStats = true,
  }) async {
    await _box().put(record.id, record.toMap());
    if (countTowardUsageStats) {
      await UsageStatsService.recordSessionCompleted(record.mode);
    }
  }

  static List<SessionRecord> getRecords() {
    final records = _box().values
        .map((e) => SessionRecord.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList();
    records.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return records;
  }

  static Future<void> deleteRecord(String id) async {
    await _box().delete(id);
  }

  static Future<void> clearAll() async {
    await _box().clear();
  }
}
