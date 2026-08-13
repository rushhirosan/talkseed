# Talk Shuffle — ロードマップ & To-Do

**このファイルが将来の改善・拡張の唯一の To-Do 集約先です。**  
完了した項目はここから削除する（履歴は git）。新しいタスクはここに追記。

最終更新: 2026-07-30

---

## 方針（要約）

| 層 | 内容 | 目的 |
| --- | --- | --- |
| **無料コア** | 3D サイコロ + 価値観 + グループ + **1on1** | DL・口コミ・ASO |
| **Tip（任意）** | Ko-fi 等 | 薄い収益 + social proof |
| **Pro（後から）** | **エクスポート** + **プリセット保存** +（任意）第三モードの一部 | 説明可能な paywall |
| **広告** | 非推奨 | 会議 UX・プライバシー訴求と矛盾 |

**やらないこと:** 1on1 モードそのものの Pro 化 / 無料コアの削減 / 会議中 AdMob / 第三モードなし IAP / マーケと実体の不一致放置

**Pro 商品の考え方（2026-07 確定）:** エクスポート（共有・CSV）**単体では弱い**。週次で回すファシリテーター向けに **「記録の持ち出し + 設定の名前付き保存」** を Pro バンドルとする。ストア文面の目安: 「お題はそのまま無料。Pro ではプリセット保存と履歴共有が使えます。」

---

## いま最優先（Next）

**Step 2 — Pro / IAP（サンドボックス確認済・復元改善済）**

- コード側: `iapEnabled = true`、復元タイムアウト／再試行・起動ブロック回避を反映
- 手順: [store_assets/IAP_SETUP.md](store_assets/IAP_SETUP.md)
- 次: 変更をコミット → ルート A（Pro 先出し）or B（第三モード → v3）を決める

---

## 実装状況サマリ（2026-07-30）

| 領域 | 状態 | コード |
| --- | --- | --- |
| 端末内利用集計 | **実装済**（UI なし・IAP Go 判定用） | [usage_stats_service.dart](lib/services/usage_stats_service.dart), [data/usage_stats_policy.md](data/usage_stats_policy.md) |
| 履歴テキスト共有 | **実装済**（Pro ゲート: debug で確認可） | [session_record_share_text.dart](lib/utils/session_record_share_text.dart), [session_history_page.dart](lib/pages/session_history_page.dart) |
| プリセット | **Phase 1–4 実装済**（Pro ゲート: debug で確認可） | [session_preset.dart](lib/models/session_preset.dart), [preset_service.dart](lib/services/preset_service.dart) |
| IAP / Pro | **Store 接続実装済**（`iapEnabled` オフのまま） | [purchase_service.dart](lib/services/purchase_service.dart), [pro_access.dart](lib/utils/pro_access.dart), [pro_paywall_sheet.dart](lib/widgets/pro_paywall_sheet.dart), [IAP_SETUP.md](store_assets/IAP_SETUP.md) |
| 第三モード | **未着手** | — |

---

## プリセット保存 — 段階的実装プラン

**目的:** 毎週同じ進行（1on1 の型・議論のカテゴリ・サイコロ6面など）を名前付きでワンタップ開始。Pro の中核機能の一つ。

| Phase | 対象 | 保存する内容 | 状態 |
| --- | --- | --- | --- |
| **1** | 1on1 | `OneOnOneSessionFormat`（ライト / 成長 / 関係性 / フル） | **完了** |
| **2** | グループ議論 | `SessionConfig` の discussion 系 + 人数・タイマー・プレイヤー名 | **完了** |
| **3** | サイコロ | 6面カスタムテーマ + `SessionConfig` | **完了** |
| **4** | 価値観カード | 人数・タイマー・プレイヤー名 | **完了** |

### Phase 1 — 1on1（完了）

- [x] **P1.1** `SessionPreset` モデル + `PresetService`（SharedPreferences・最大 10 件）
- [x] **P1.2** 1on1 型選択画面 — 「プリセットに保存」・保存済みチップで型を選択
- [x] **P1.3** ホーム — 「マイプリセット」横スクロール・タップで型選択スキップ開始
- [x] **P1.4** 長押しで削除・日英 l10n・[preset_service_test.dart](test/services/preset_service_test.dart)

### Phase 2 — グループ議論（完了）

- [x] **P2.1** `SessionPreset` に discussion 用フィールド追加（`discussionDeckType`, `SessionConfig` スナップショット）
- [x] **P2.2** [session_setup_page.dart](lib/pages/session_setup_page.dart) — 「プリセットに保存」・保存済みから復元
- [x] **P2.3** ホームのマイプリセット — 議論プリセットタップでセッション設定スキップ → プレイ開始
- [x] **P2.4** テスト

### Phase 3 — サイコロ（完了）

- [x] **P3.1** `SessionPreset` に `diceThemes`（6面）追加
- [x] **P3.2** [initial_settings_page.dart](lib/pages/initial_settings_page.dart) / セッション設定 — 保存・復元
- [x] **P3.3** ホームからワンタップ開始
- [x] **P3.4** テスト

### Phase 4 — Pro 連携（Step 2 と同時）

- [x] **P4.1** 未購入時: プリセット保存・件数上限（無料 1 件お試し）→ ペイウォール
- [x] **P4.2** 購入済み: 保存・適用・上限緩和（10 件）
- [x] **P4.3** 履歴詳細から「同じ設定をプリセットに保存」（Pro・設定スナップショットがある履歴のみ）

---

## 収益化 — 実装プラン

**目的:** 無料コアは維持したまま Pro（**エクスポート + プリセット保存**）で課金理由を作る。  
**価格:** Step 6 まで保留（参考: ¥480〜980）。  
**原則:** 第三モードは先に無料 → Pro 箱（エクスポート + プリセット）→ 価格と Pro 範囲はデータを見て決める。

```
Step 0 基盤（集計・共有・プリセット Phase 1）→ プリセット Phase 2/3
  → Step 2 IAP/Pro 箱 → Step 3 第三モード設計 → Step 4 実装 → Step 5 リリース v3
  → Step 6 Pro 完成・価格 → Step 7 振り返り
```

### Step 0 — 基盤（一部完了）

- [x] **0.1** 端末内利用集計 — `UsageStatsService`（完了セッションのみ・外部送信なし）
- [x] **0.2** 履歴テキスト共有 — 履歴**詳細**画面の共有ボタン（一覧にはなし）
- [x] **0.3** 1on1 プリセット Phase 1
- [x] **0.4** エクスポート試行の集計 — 共有ボタンタップ数（ペイウォール含む）
- [x] **0.5** プリセット Phase 2 / 3 / 4

### Step 2 — Pro / IAP 基盤

- [x] **2.1** `in_app_purchase` 追加・`PurchaseService` 接続（購入ストリーム・completePurchase）
- [x] **2.2** `PurchaseService` — Pro 状態の永続化・debug 解除（非消費型 1 商品）
- [x] **2.3** Pro 判定の単一入口 — `PurchaseService.isPro` / `ProAccess.ensure`
- [x] **2.4** **Pro ゲート** — 未購入時はペイウォール（debug ゲートデフォルト ON / リリースは `iapEnabled` まで無料）
  - 履歴エクスポート（共有）
  - プリセット保存（新規・無料 1 件）
  - （任意）複数件 CSV
- [ ] **2.5** App Store Connect — 非消費型 IAP 商品登録（ID: `talk_shuffle_pro`、価格は仮 tier で可）→ [IAP_SETUP.md](store_assets/IAP_SETUP.md)
- [ ] **2.6** iOS サンドボックスで購入・復元テスト（確認後 `iapEnabled = true`）
- [x] **2.7** [web/privacy.html](web/privacy.html) — 課金・復元の記載
- [ ] **2.8**（Android 提出予定なら）Play Console 同商品 + テスト

**ローカル確認手順（debug・IAP オフ時）:**
1. `flutter run`（debug）
2. ホーム「アプリについて」→ **Pro ゲートを有効化**（デフォルト ON）/ **Pro 解除済み** を切替
3. 履歴詳細の共有、またはプリセット 2 件目保存 → ペイウォール
4. 「Pro を解除（debug）」で解除後、同じ操作が通ることを確認

**ストア接続確認:** [store_assets/IAP_SETUP.md](store_assets/IAP_SETUP.md)（StoreKit Configuration / サンドボックス）

### Step 3 — 第三モード：選定・設計

**1 本だけ** 選ぶ（実装前にここで止めない）。候補は末尾「付録: 競合整理」参照。

- [ ] **3.1** マッシュアップ **or** ビンゴを決定
- [ ] **3.2** データ JSON スキーマ — タグ / カテゴリ / 制約（マッシュアップ）またはマス定義（ビンゴ）
- [ ] **3.3** 画面フロー — セッション設定・`CardDrawWidget` 流用可否・ホーム導線
- [ ] **3.4** `SessionRecord` に第三モード用 `mode` 定数追加の設計

### Step 4 — 第三モード：実装（無料で入れる）

- [ ] **4.1** `data/` に JSON + 読み込みモデル
- [ ] **4.2** プレイ画面 — 抽選・表示・次プレイヤー（既存ページと同様のセッション連携）
- [ ] **4.3** [lib/pages/mode_selection_page.dart](lib/pages/mode_selection_page.dart) 等から導線
- [ ] **4.4** セッション終了 → `SessionRecord` 保存・履歴一覧・詳細表示
- [ ] **4.5** 日英 l10n
- [ ] **4.6** テスト — 抽選ロジック・空データ時の挙動

### Step 5 — リリース v3（第三モード無料・Pro はエクスポート + プリセット）

- [ ] **5.1** バージョン bump・What's New（日英）
- [ ] **5.2** ストア文面 — 第三モード +「お題は無料。Pro は進行セットの保存と記録の共有」
- [ ] **5.3** スクリーンショット 1 枚以上（第三モード・プリセット・履歴共有）
- [ ] **5.4** App Store 提出・審査
- [ ] **5.5**（任意）Google Play 提出
- [ ] **5.6** Solomaker / X / Uneed で再宣伝

### Step 6 — Pro 完成・価格決定

- [ ] **6.1** 第三モードの Pro 範囲を決める — 全無料のまま / 仕事向けプリセットのみ Pro / 週替わり全件 Pro 等
- [ ] **6.2** Pro 価格を App Store 価格帯から決定
- [ ] **6.3** ストア説明・SS に Pro 訴求を追記
- [ ] **6.4** 本番購入フロー最終確認（復元含む）

### Step 7 — 振り返り・次の一手

- [ ] **7.1** 端末内集計の確認 — モード別セッション・エクスポート試行・プリセット保存数
- [ ] **7.2** 収益・DL のメモ（App Store Connect / Play レポート）
- [ ] **7.3** 次の Pro 候補 — お題パック IAP / チェックイン・チェックアウト復活（仕事向け Pro パック）等

### 任意（後回し）

- [ ] **1.6** 複数件 CSV エクスポート
- [ ] **1.7** 履歴一覧からの直接共有（現状は詳細画面のみ）

---

## Pro 無料/有料の整理（Step 6 で最終確定）

| 無料 | Pro |
| --- | --- |
| サイコロ + カスタムテーマ（毎回入力） | 同上 |
| 価値観 + グループ + 1on1 | 同上 |
| 第三モード（初期は無料） | 範囲は Step 6 で決定 |
| セッション履歴（端末内・閲覧） | **エクスポート（共有 / CSV）** |
| セッション設定（毎回手入力） | **名前付きプリセット保存・ワンタップ開始** |

**開発中（IAP 前）:** リリースビルドではゲート無効（無料のまま）。debug ではゲート ON でローカル確認可能。

---

## ストア & マーケティング

### スクリーンショット

- [ ] **2.1.2 以降の UI で差し替え**（1on1・プリセット・履歴共有・全体）
- [ ] iOS **6.7"**（App Store 推奨）
- [ ] iOS **iPad 13"**
- [ ] Android 16:9 英語（任意 — `android/16x9/en/`）

### ストア提出・運用

- [ ] **Google Play Console** — 開発者登録〜AAB 提出・審査（未完了なら）
- [ ] **App Store Connect** — 継続リリース運用
- [ ] メタデータ転記・機密情報チェック（リリース前 [scripts/release.sh](scripts/release.sh) で一部自動）
- [ ] [store_assets/README.md](store_assets/README.md) — 「課金なし」記述を Pro 方針に合わせて更新（IAP 直前）

### 宣伝チャネル

| チャネル | To-Do |
| --- | --- |
| **Solomaker** | [ ] ログイン・商品ページ更新・アイコン + SS 5 枚・App Store リンク（[store_assets/solomaker_product_ja.txt](store_assets/solomaker_product_ja.txt)） |
| **Product Hunt** | [ ] 第三モード or v3 タイミングで launch 準備（[store_assets/producthunt_launch_en.txt](store_assets/producthunt_launch_en.txt)） |
| **Uneed / X** | [ ] 「1on1 の最初の 5 分」「会議が沈黙」系メッセージ。無料で試せる導線 |

---

## 機能バックログ

### 高 — 品質・基盤

- [ ] **エラーハンドリング統一** — JSON 読み込み失敗等（カスタム Exception・UI 表示）
- [ ] **MainPage の分離** — [lib/main.dart](lib/main.dart) をエントリのみに → `pages/main_page.dart`

### 中 — 差別化

- [ ] **正四面体・正八面体** — アーカイブコードの UI 統合
- [ ] **複数サイコロ** — 2 テーマの組み合わせ

### 低 — UX・nice to have

- [ ] データ分析・インサイト（よく使うテーマ等）
- [ ] オフライン同期（クラウドバックアップ — プライバシー方針と要整合）
- [ ] SNS 共有の強化
- [ ] 大画面 / フルスクリーン表示の最適化
- [ ] プリセット管理専用画面（一覧・編集・並べ替え — 件数増えたら）

---

## コード整理（リファクタ）

| 優先 | 対象 | 内容 |
| --- | --- | --- |
| 高 | `initial_settings_page.dart` | テーマ/モードブロックのウィジェット化 |
| 高 | `value_card_page.dart` | カード/結果エリアの分割 |
| 中 | `topics_page.dart`, `session_setup_page.dart`, `dice_page.dart` | ブロック抽出 |
| 中 | カラーパレット | `_mustardYellow` 等の共通化 → `theme/` |
| 低 | `tutorial_page.dart`, `mode_selection_page.dart` | 任意の細分化 |

---

## 保留・再利用候補

- [ ] **チェックイン / チェックアウト** — アプリ非表示。データは [data/checkin_checkout_work.json](data/checkin_checkout_work.json)・[data/checkin_checkout_work.md](data/checkin_checkout_work.md) に残存。**Pro 仕事向けパック**として再導入する候補（Step 7.3）

---

## 成功指標（3 ヶ月目安）

| 指標 | 目安 |
| --- | --- |
| App Store レビュー | 10 件+ |
| 1on1 利用 | 端末内集計でモード別確認 |
| プリセット保存 | 1on1 プリセット作成数（Phase 1 以降） |
| Tip / Pro | 月数件でも OK（ポートフォリオ目的） |
| 第三モード | 1 本リリース |
| 収益期待 | Tip + Pro 合計 月数千〜1.3 万円（主目的は設計実績） |

---

## 参照（手順・素材）

| ファイル | 用途 |
| --- | --- |
| [data/usage_stats_policy.md](data/usage_stats_policy.md) | 端末内集計方針 |
| [store_assets/IAP_SETUP.md](store_assets/IAP_SETUP.md) | Pro IAP 商品登録・サンドボックス手順 |
| [store_assets/FIREBASE_DEPLOY.md](store_assets/FIREBASE_DEPLOY.md) | Web デプロイ手順 |
| [scripts/release.sh](scripts/release.sh) | リリース前チェック・deploy |
| [store_assets/screenshot_plan.md](store_assets/screenshot_plan.md) | SS 撮影シナリオ |
| [store_assets/app_store_metadata_*.txt](store_assets/) | ストア文面ドラフト |
| [store_assets/solomaker_product_ja.txt](store_assets/solomaker_product_ja.txt) | Solomaker 掲載文 |
| [store_assets/producthunt_launch_en.txt](store_assets/producthunt_launch_en.txt) | Product Hunt 文案 |

---

## 付録: 競合整理（第三モード設計用）

### 被りやすいタイプ

| タイプ | 例 | Talk Shuffle との関係 |
| --- | --- | --- |
| 質問1枚引き | Party Qs | テーマ提示は重複しやすい |
| 数値＋並べ替え | Yappi / ito | 価値観カードと被りやすい |
| ビンゴ・QR | Jam Bingo | **進行ルール**で差別化しやすい |
| 2要素の掛け算 | かけアイ | 組み合わせ創発で差別化しやすい |
| AI フォローアップ | AI Icebreaker | 静的デッキとの差が明確 |

### 第三モード候補

| 候補 | 概要 | メモ |
| --- | --- | --- |
| **トピック・マッシュアップ**（推奨） | タグ×カテゴリ×制約 | かけアイ系。仕事・雑談両方 |
| **会話ビンゴ** | マス埋め・ラインで終了 | Jam Bingo との差別化 |
| 二択・投票・ランキング | Would you rather 等 | 短時間向き |
| 協働ストーリー | 最初の 1 行だけ固定 | サイコロと体験が異なる |

**結論:** 第三の柱は **マッシュアップ or ビンゴ/チャレンジ型** が Yappi/ito 系より筋がよい。
