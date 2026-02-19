# main.dart 分割・切り出し候補

## 実施済み

- **DicePage** → `lib/pages/dice_page.dart` に切り出し済み（2025-02 実施）

---

## 1. main.dart のさらなる整理

| 候補 | 現在の場所 | 提案先 | 優先度 | メモ |
|------|------------|--------|--------|------|
| **MainPage** | main.dart | `pages/main_page.dart` | 中 | main.dart をエントリ＋MyApp のみにすると見通しが良い |

- **効果**: main.dart が約 50 行になり、エントリの責務に集中できる。
- **見積**: 30 分程度。

---

## 2. 他クラス・ウィジェットの切り出し候補

### 2.1 ページ単位で大きいファイル（分割・ウィジェット抽出の候補）

| ファイル | 行数 | 切り出し候補 | 優先度 |
|----------|------|----------------|--------|
| **initial_settings_page.dart** | 約 900 | テーマ選択ブロック、モード選択ブロックをウィジェット化 | 高 |
| **value_card_page.dart** | 約 772 | カード表示エリア、結果エリアをウィジェット化 | 高 |
| **topics_page.dart** | 約 549 | トピック一覧・カード UI をウィジェット化 | 中 |
| **session_setup_page.dart** | 約 523 | プレイヤー設定ブロック、タイマー設定ブロック | 中 |
| **dice_page.dart** | 約 631 | 下記「DicePage 内の切り出し」を参照 | 中 |
| **tutorial_page.dart** | 約 409 | スライド 1 枚ごとをウィジェット化（任意） | 低 |
| **mode_selection_page.dart** | 約 360 | ボタン群を 1 ウィジェットにまとめる（任意） | 低 |

### 2.2 DicePage 内の切り出し候補

| 候補 | 内容 | 提案先 | 効果 |
|------|------|--------|------|
| **回転プリセット** | `_getBaseRotations()`（正六面体の面→回転値） | `utils/dice_rotation_presets.dart` または `widgets/dice_widget.dart` 付近 | 正八面体等追加時に再利用しやすい |
| **サイコロ振り UI ブロック** | アニメーション＋DiceWidget を包む部分 | `widgets/dice_roll_area.dart`（任意） | DicePage の build が短くなる |
| **セッション用ツールバー** | PlayerIndicator + TimerDisplay のまとまり | 既存ウィジェットの組み合わせのまま or `widgets/session_toolbar.dart` | 他画面で「セッション中ヘッダ」を再利用する場合に有効 |

### 2.3 共通化したい定数・テーマ

| 候補 | 現状 | 提案先 |
|------|------|--------|
| **カラーパレット** | `_mustardYellow`, `_white`, `_black`, `_lightYellow` 等が dice_page / initial_settings_page / session_setup_page に重複 | `utils/app_colors.dart` または `theme/app_theme.dart` で一元定義 |

- 色名は現状のまま（mustardYellow, lightYellow 等）で定数として共有すると、デザイン変更時の修正箇所が減る。

---

## 3. 優先度の目安

1. **高**: initial_settings_page / value_card_page のブロック分割（行数削減・テストしやすさ）
2. **中**: MainPage の分離、initial_settings / session_setup / dice_page のウィジェット化、色の共通化
3. **低**: tutorial / mode_selection の細かいウィジェット化、DicePage の dice_roll_area 等

---

## 4. 注意点

- 切り出す際は **import の参照先** を一括で `main.dart` → `pages/dice_page.dart` のように変更済み。今後の分離でも同様に `grep` で参照箇所を確認すること。
- 既存の `pages/` と `widgets/` の役割を守る（画面＝pages、再利用 UI＝widgets）。
