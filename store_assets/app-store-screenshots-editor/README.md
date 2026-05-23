# Talk Shuffle — App Store スクリーンショットエディタ

[app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots) スキルのテンプレートを使ったマーケ用スクショ編集環境です。

## 初回セットアップ

```bash
cd store_assets/app-store-screenshots-editor
npm install
```

生キャプチャを差し替えたあと（`screenshots/ios/6.5inch` など）:

```bash
./scripts/sync-source-screenshots.sh
```

## 起動

```bash
npm run dev
```

ブラウザで http://localhost:3000 を開き、レイアウト・キャッチコピー・テーマを調整します。

## エクスポート

1. ツールバーで **iPhone** または **iPad** を選択
2. ロケール **en** / **ja** を切り替えて文言を確認
3. **Export bundle** で App Store 必須サイズ一式を ZIP 取得

| デバイス | 含まれるサイズ例 |
|----------|------------------|
| iPhone | 6.9" / 6.5" / 6.3" / 6.1" |
| iPad | 13" / 12.9" |

## 入力画像の場所

| 用途 | パス |
|------|------|
| iPhone 生キャプチャ | `../screenshots/ios/6.5inch/{en,ja}/` |
| iPad 生キャプチャ | `../screenshots/ios/ipad-13inch/{en,ja}/` |
| エディタ内参照 | `public/screenshots/apple/iphone/{locale}/01.png` … `06.png` |

## 設定ファイル

- `app-store-screenshots.json` — スライド構成・コピー（Git 管理推奨）
- テーマ **Talk Shuffle** — `HomePalette` 相当（`#0D0D14` / `#F5C842`）

## Cursor スキル

プロジェクトに `.agents/skills/app-store-screenshots` が入っています。チャットで「キャッチコピーを短くして」「3枚目を hero に」などと指示すると調整できます。
