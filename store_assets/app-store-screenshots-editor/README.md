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

**必ずこのフォルダで** `npm run dev` してください（リポジトリ直下では動きません）。

```bash
cd store_assets/app-store-screenshots-editor
npm install --legacy-peer-deps   # 初回のみ
npm run dev
```

ブラウザで http://localhost:3000 を開き、レイアウト・キャッチコピー・テーマを調整します。

### 画面が真っ白 / 何も出ないとき

1. ターミナルに `▲ Next.js` と `Local: http://localhost:3000` が出ているか確認
2. ポートを空けて再起動:
   ```bash
   lsof -ti:3000 | xargs kill -9 2>/dev/null
   npm run dev
   ```
3. ブラウザで **スーパーリロード**（Mac: Cmd+Shift+R）
4. 数秒待つ（最初は `Loading editor…` のあとエディタが出ます）
5. それでもダメなら DevTools → Console のエラーを確認

Solomaker 用画像だけ欲しい場合は UI 不要で `npm run export:solomaker` でも可。

## エクスポート

### Solomaker 用（5枚・日本語・キャッチコピー付き）

```bash
npm run export:solomaker
```

出力: `../solomaker/01-hero.jpg` … `05-group-talk.jpg`（6.5" / 1284×2778）

初回のみ `npx playwright install chromium`。ブラウザは `.playwright-browsers/` に保存されます。

### App Store 一式（手動）

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
