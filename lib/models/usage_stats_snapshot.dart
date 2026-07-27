/// 端末内利用集計の読み取り専用スナップショット（外部送信なし）
class UsageStatsSnapshot {
  /// モード別の累計完了セッション数（`SessionRecord.mode*` のキー）
  final Map<String, int> totalByMode;

  /// 現在の ISO 週（例: 2026-W25）におけるモード別完了数
  final Map<String, int> weeklyByMode;

  /// 最後に完了セッションを記録した日時（端末ローカル）
  final DateTime? lastSessionAt;

  /// 履歴共有ボタンの累計タップ数（試行。成功可否は問わない）
  final int exportAttemptCount;

  /// 現在の ISO 週における共有タップ数
  final int weeklyExportAttemptCount;

  const UsageStatsSnapshot({
    required this.totalByMode,
    required this.weeklyByMode,
    this.lastSessionAt,
    this.exportAttemptCount = 0,
    this.weeklyExportAttemptCount = 0,
  });

  int get weeklyTotal =>
      weeklyByMode.values.fold<int>(0, (sum, count) => sum + count);

  int countForMode(String mode) => totalByMode[mode] ?? 0;

  int weeklyCountForMode(String mode) => weeklyByMode[mode] ?? 0;
}
