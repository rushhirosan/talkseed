# ストア用スクリーンショット

撮影した画像を以下のフォルダに入れてください。

## フォルダ構成

| フォルダ | 用途 |
|----------|------|
| `ios/6.7inch/` | iPhone 14/15 Pro Max 相当（App Store 推奨） |
| `ios/6.1inch/` | iPhone 16e など 6.1" 用 |
| `ios/ipad-13inch/` | iPad Pro 13" 相当（iPad ネイティブ対応時・App Store 必須） |
| `android/16x9/` | Android 16:9 用 |

### 言語別サブフォルダ

日英両方のスクリーンショットを用意する場合、各サイズフォルダ内に言語フォルダを設けます。

| サブフォルダ | 用途 |
|--------------|------|
| `ja/` | 日本語 UI のスクリーンショット |
| `en/` | 英語 UI のスクリーンショット |

- **iOS**: `ios/6.1inch/ja/`, `ios/6.1inch/en/`, `ios/6.7inch/ja/`, `ios/6.7inch/en/`, `ios/ipad-13inch/ja/`, `ios/ipad-13inch/en/`
- **Android**: `android/16x9/ja/`, `android/16x9/en/`

## iPad スクリーンショット（実機なし）

iPad ネイティブ対応（`TARGETED_DEVICE_FAMILY = 1,2`）の場合、App Store に iPad 用の枠が必要です。実機 iPad は不要で、**iPad シミュレータ**で撮影できます。

1. Simulator で **iPad Pro 13-inch** などを起動
2. `flutter run -d "iPad Pro 13-inch (M4)"`（表示名は `flutter devices` で確認）
3. 各画面で **Cmd + S** → `ios/ipad-13inch/ja/`（または `en/`）に `01_`〜`06_` で保存

トップ画面のアイコンは Material Icons を使用しているため、シミュレータでも `?` 表示になりません。

## 推奨ファイル名（各画面に対応）

1. `01_mode_selection.png` - モード選択（サイコロ/チームビルディング）
2. `02_dice.png` - 3Dサイコロ画面
3. `03_theme_settings.png` - テーマ設定（ドラッグ&ドロップ）
4. `04_session_setup.png` - セッション設定（人数・タイマー）
5. `05_value_card.png` - 価値観カード
6. `06_play_history.png` - 履歴

※ チェックイン/チェックアウトは初回リリースでは非表示のため撮影対象外
