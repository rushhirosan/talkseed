# 端末内利用集計（Usage Stats）

> Step 0（収益化実装プラン）の設計メモ。コード: [lib/services/usage_stats_service.dart](../lib/services/usage_stats_service.dart)

## 目的

- モード別の**完了セッション数**と**最終利用日**を端末内だけで把握する
- 外部 Analytics・広告 SDK は使わない（プライバシー方針と一致）
- 収益化 Step 2（IAP）に進むかどうかの **Go 判断**に使う

## 何を数えるか

| 項目 | 保存先 | 説明 |
| --- | --- | --- |
| モード別累計 | `SharedPreferences` | `dice` / `value_cards` / `discussion` / `one_on_one` |
| 週次（ISO 週） | 同上 | 月曜始まりの週キー（例 `2026-W25`）ごとにリセット |
| 最終完了日時 | 同上 | 最後に完了として記録した日時 |
| エクスポート試行 | 同上 | 履歴詳細の**共有ボタンタップ数**（累計・週次）。ペイウォールで止まった場合も含む |

## いつ increment するか

- **セッション完了**として `SessionRecordService.addRecord` が呼ばれたとき（モード別）
- **共有タップ**として `UsageStatsService.recordExportAttempt` が呼ばれたとき（履歴詳細の共有）
- サイコロ**ソロ**の振り直し中間保存（`countTowardUsageStats: false`）は**セッション集計に数えない**

## 数えないもの

- 発言内容・参加者の個人情報
- セッション履歴の本文そのもの（集計はカウンタのみ）
- 外部サーバーへの送信

## Step 2（IAP）Go 基準

`UsageStatsGoCriteria` と同値。満たすいずれかで Step 2 本格着手:

1. **仕事向けモード**（1on1 + グループディスカッション）の週次完了が **3 回以上**
2. **全モード合計**の週次完了が **5 回以上**

基準は ROADMAP / 実データを見て調整可。定数は `usage_stats_service.dart` の `UsageStatsGoCriteria`。

## 既存履歴との関係

- 本機能リリース**以前**の `SessionRecord` からは自動バックフィルしない（ソロサイコロの中間履歴と区別がつかないため）
- リリース以降の完了セッションから集計開始

## プライバシー

- [web/privacy.html](../web/privacy.html) セクション 3 に端末内集計の一文を記載
- 個人を特定する情報は含まない
