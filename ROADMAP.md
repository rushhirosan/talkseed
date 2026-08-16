# Talk Shuffle — ロードマップ & To-Do

**このファイルが将来の改善・拡張の唯一の To-Do 集約先です。**  
完了した項目はここから削除する（履歴は git）。新しいタスクはここに追記。

最終更新: 2026-08-17

---

## 方針（要約）

| 層 | 内容 | 目的 |
| --- | --- | --- |
| **無料コア** | 3D サイコロ + 価値観 + グループ + **1on1** | DL・口コミ・ASO |
| **Tip（任意）** | Ko-fi 等 | 薄い収益 + social proof |
| **Pro** | **エクスポート（履歴共有）** + **プリセット保存** +（任意）第三モードの一部 | 説明可能な paywall |
| **広告** | 非推奨 | 会議 UX・プライバシー訴求と矛盾 |

**やらないこと:** 1on1 モードそのものの Pro 化 / 無料コアの削減 / 会議中 AdMob / マーケと実体の不一致放置

**Pro 商品:** 週次で回すファシリテーター向けに **「記録の持ち出し + 設定の名前付き保存」** をバンドル。ストア文面: 「お題はそのまま無料。Pro ではプリセット保存と履歴共有が使えます。」

**ルート A（採用）:** 第三モードより先に Pro を App Store へ出す。第三モードは公開後に無料で追加する。

---

## いま最優先（Next）

**App Store 2.2.0 — 審査待ち（2026-08-17 提出）**

- iOS **2.2.0 (8)** + 非消費型 IAP **Talk Shuffle Pro**（`talk_shuffle_pro`）が審査待ち
- コード: `iapEnabled = true`・復元改善・iOS 最低バージョン **15.0**
- 価格: 仮 tier（後から変更可）。本決めは Step 6
- 次: 審査結果対応 → 公開後に本番購入の最終確認（Step 6.4）
- その後: **Step 3–4 第三モード**（マッシュアップ or ビンゴ）→ v3、または Step 6 で価格見直し

任意: EU トレーダー（DSA）書類の結果待ち / Android 同商品（2.8）

---

## 実装状況サマリ（2026-08-17）

| 領域 | 状態 | コード |
| --- | --- | --- |
| 端末内利用集計 | **実装済**（UI なし） | [usage_stats_service.dart](lib/services/usage_stats_service.dart) |
| 履歴テキスト共有 | **実装済**（Pro ゲート） | [session_history_page.dart](lib/pages/session_history_page.dart) |
| プリセット Phase 1–4 | **実装済**（無料 1 件 / Pro 10 件） | [preset_service.dart](lib/services/preset_service.dart) |
| IAP / Pro | **実装済・2.2.0 審査待ち** | [purchase_service.dart](lib/services/purchase_service.dart), [IAP_SETUP.md](store_assets/IAP_SETUP.md) |
| ストア文面（Pro 方針） | **更新済**（[store_assets/](store_assets/)） | メタデータ日英 + Play |
| 第三モード | **未着手** | — |

---

## 収益化 — 残タスク

**目的:** 無料コアは維持したまま Pro（エクスポート + プリセット）で課金理由を作る。  
**価格:** Step 6 で本決め（参考: ¥250〜980。提出時は仮 tier）。

```
Step 2 IAP 完了 → ルート A で 2.2.0 提出（審査中）
  → Step 3 第三モード設計 → Step 4 実装 → Step 5 リリース v3
  → Step 6 Pro 価格・範囲の見直し → Step 7 振り返り
```

### Step 2 — Pro / IAP（完了）

- ASC 商品 `talk_shuffle_pro`・有料アプリ契約 Active・サンドボックス購入／復元確認
- `iapEnabled = true`・復元タイムアウト／再試行・起動時 StoreKit 非ブロック
- 手順メモ: [store_assets/IAP_SETUP.md](store_assets/IAP_SETUP.md)
- [ ] **2.8**（任意）Play Console 同商品 + ライセンステスト

### Step 3 — 第三モード：選定・設計

**1 本だけ** 選ぶ。候補は末尾「付録: 競合整理」参照。

- [ ] **3.1** マッシュアップ **or** ビンゴを決定
- [ ] **3.2** データ JSON スキーマ
- [ ] **3.3** 画面フロー — セッション設定・`CardDrawWidget` 流用可否・ホーム導線
- [ ] **3.4** `SessionRecord` に第三モード用 `mode` 定数の設計

### Step 4 — 第三モード：実装（無料で入れる）

- [ ] **4.1** `data/` に JSON + 読み込みモデル
- [ ] **4.2** プレイ画面
- [ ] **4.3** [mode_selection_page.dart](lib/pages/mode_selection_page.dart) 等から導線
- [ ] **4.4** セッション終了 → 履歴保存・一覧・詳細
- [ ] **4.5** 日英 l10n
- [ ] **4.6** テスト

### Step 5 — リリース v3（第三モード無料）

- [ ] **5.1** バージョン bump・What's New（日英）
- [ ] **5.2** ストア文面 — 第三モード追記
- [ ] **5.3** スクリーンショット（第三モード・プリセット・履歴共有）
- [ ] **5.4** App Store 提出
- [ ] **5.5**（任意）Google Play 提出
- [ ] **5.6** Solomaker / X / Uneed で再宣伝

### Step 6 — Pro 価格・範囲

- [ ] **6.1** 第三モードの Pro 範囲（全無料のまま / 一部 Pro 等）
- [ ] **6.2** Pro 価格を本決め（ASC で tier 変更可）
- [ ] **6.3** ストア説明・SS に Pro 訴求を必要なら更新
- [ ] **6.4** 本番購入フロー最終確認（復元含む）— **2.2.0 公開直後に実施**

### Step 7 — 振り返り

- [ ] **7.1** 端末内集計 — モード別・エクスポート試行・プリセット数
- [ ] **7.2** 収益・DL（ASC Trends / 財務レポート）
- [ ] **7.3** 次の Pro 候補 — お題パック / チェックイン・チェックアウト復活等

### 任意（後回し）

- [ ] 複数件 CSV エクスポート
- [ ] 履歴一覧からの直接共有（現状は詳細画面のみ）
- [ ] EU トレーダー（DSA）— 書類審査の結果対応

---

## Pro 無料/有料の整理（Step 6 で最終確定）

| 無料 | Pro |
| --- | --- |
| サイコロ + カスタムテーマ（毎回入力） | 同上 |
| 価値観 + グループ + 1on1 | 同上 |
| 第三モード（初期は無料） | 範囲は Step 6 で決定 |
| セッション履歴（端末内・閲覧） | **エクスポート（共有 / CSV）** |
| セッション設定（毎回手入力） | **名前付きプリセット保存・ワンタップ開始** |

**現行:** `iapEnabled = true` のビルドではゲート有効。未購入はペイウォール。購入状態は端末内 + ストア所有権（サーバー検証なし）。

---

## ストア & マーケティング

### スクリーンショット

- [ ] Pro 訴求（ペイウォール／プリセット／履歴共有）を商品ページに足す（任意・公開後でも可）
- [ ] iOS **6.7"** / **iPad 13"** の差し替え（UI 更新時）
- [ ] Android 16:9 英語（任意）

### ストア提出・運用

- [x] App Store — **2.2.0 + Talk Shuffle Pro 提出済（審査待ち）**
- [ ] 公開後の継続リリース運用
- [ ] **Google Play** — 開発者登録〜AAB・同 IAP（未完了なら）
- [ ] メタデータは [store_assets/app_store_metadata_*.txt](store_assets/) を正とする

### 宣伝チャネル

| チャネル | To-Do |
| --- | --- |
| **Solomaker** | [ ] 商品ページ更新・Pro 言及・App Store リンク |
| **Product Hunt** | [ ] 第三モード or v3 タイミングで launch 準備 |
| **Uneed / X** | [ ] 「1on1 の最初の 5 分」系。無料コア + Pro の伝え方 |

---

## 機能バックログ

### 高 — 品質・基盤

- [ ] **エラーハンドリング統一** — JSON 読み込み失敗等
- [ ] **MainPage の分離** — [lib/main.dart](lib/main.dart) をエントリのみに

### 中 — 差別化

- [ ] **正四面体・正八面体** — アーカイブコードの UI 統合
- [ ] **複数サイコロ** — 2 テーマの組み合わせ

### 低 — UX

- [ ] データ分析・インサイト
- [ ] オフライン同期（プライバシー方針と要整合）
- [ ] SNS 共有の強化
- [ ] 大画面最適化
- [ ] プリセット管理専用画面（件数増えたら）

---

## コード整理（リファクタ）

| 優先 | 対象 | 内容 |
| --- | --- | --- |
| 高 | `initial_settings_page.dart` | テーマ/モードブロックのウィジェット化 |
| 高 | `value_card_page.dart` | カード/結果エリアの分割 |
| 中 | `topics_page.dart`, `session_setup_page.dart`, `dice_page.dart` | ブロック抽出 |
| 中 | カラーパレット | 共通化 → `theme/` |
| 低 | `tutorial_page.dart`, `mode_selection_page.dart` | 任意の細分化 |

---

## 保留・再利用候補

- [ ] **チェックイン / チェックアウト** — データは [data/checkin_checkout_work.json](data/checkin_checkout_work.json) に残存。**Pro 仕事向けパック**候補（Step 7.3）

---

## 成功指標（3 ヶ月目安）

| 指標 | 目安 |
| --- | --- |
| App Store レビュー | 10 件+ |
| 1on1 利用 | 端末内集計でモード別確認 |
| プリセット保存 | 作成数 |
| Tip / Pro | 月数件でも OK |
| 第三モード | 1 本リリース |
| 収益 | Tip + Pro 合計 月数千〜1.3 万円（主目的は設計実績） |

---

## 参照（手順・素材）

| ファイル | 用途 |
| --- | --- |
| [store_assets/IAP_SETUP.md](store_assets/IAP_SETUP.md) | Pro IAP・サンドボックス |
| [store_assets/FIREBASE_DEPLOY.md](store_assets/FIREBASE_DEPLOY.md) | Web デプロイ |
| [scripts/release.sh](scripts/release.sh) | リリース前チェック |
| [store_assets/app_store_metadata_*.txt](store_assets/) | ストア文面 |
| [store_assets/iap/](store_assets/iap/) | IAP 審査用スクショ |

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
