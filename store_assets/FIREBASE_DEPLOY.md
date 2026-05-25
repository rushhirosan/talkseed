# Talk Shuffle - Firebase Hosting デプロイ手順

プライバシーポリシー・サポートページを Firebase Hosting で公開する手順です。

## 前提条件

- Node.js がインストールされていること
- [Firebase CLI](https://firebase.google.com/docs/cli) がインストールされていること

```bash
npm install -g firebase-tools
```

## 初回セットアップ

### 1. Firebase にログイン

```bash
firebase login
```

### 2. Firebase プロジェクトを初期化

```bash
firebase init hosting
```

以下のように選択します：

- **Select a default Firebase project**: 既存プロジェクトを選択するか、「Create a new project」で新規作成
- **What do you want to use as your public directory?**: `build/web`（既に firebase.json に設定済みの場合はスキップ可能）
- **Configure as a single-page app?**: No
- **Set up automatic builds with GitHub?**: お好みで

既に `firebase.json` が存在する場合は、プロジェクトの選択のみ行います。

### 3. ビルドとデプロイ

```bash
# Flutter Web をビルド（web/ 内の privacy.html, support.html も build/web/ に含まれる）
flutter build web

# Firebase Hosting にデプロイ
firebase deploy
```

## デプロイ後の URL

デプロイが完了すると、以下のような URL が表示されます：

- **ランディングページ（SEO）**: `https://<PROJECT_ID>.web.app/`
- **ブラウザ版アプリ**: `https://<PROJECT_ID>.web.app/app.html`（旧 `/index.html` は `/app.html` へリダイレクト）
- **プライバシーポリシー**: `https://<PROJECT_ID>.web.app/privacy.html`
- **サポート**: `https://<PROJECT_ID>.web.app/support.html`
- **サイトマップ**: `https://<PROJECT_ID>.web.app/sitemap.xml`

### 英語表示（ポートフォリオ連携）

クエリ `?lang=en` でランディング・静的ページ・ブラウザ版 SPA を英語表示できます（`?lang=ja` で明示的に日本語）。未指定時は日本語（静的ページ）／ブラウザ言語（SPA）。

- 例: `https://talk-seed.web.app/?lang=en`
- ブラウザ版: `https://talk-seed.web.app/app.html?lang=en`
- ポートフォリオ英語ページの Web リンクに `?lang=en` を付与する

iOS アプリの言語は変更されません（Web のみ）。

## Google インデックス登録（Search Console）

ランディングページを Google に登録し、App Store への参照元 Web 流入を増やす手順です。

### 1. デプロイ

```bash
flutter build web
firebase deploy
```

`/` は静的ランディングページ（`landing.html`）を表示します。`flutter build web` 後に `index.html` を `app.html` にリネームしてからデプロイします（`scripts/release.sh` が自動実行）。Flutter アプリは `/app.html` です。

### 2. Google Search Console にプロパティ追加

1. [Google Search Console](https://search.google.com/search-console) を開く
2. **プロパティを追加** → URL プレフィックス `https://talk-seed.web.app`
3. 所有権確認（HTML タグを `web/landing.html` の `<head>` に追加して再デプロイ、または DNS 確認）

### 3. サイトマップを送信

Search Console → **サイトマップ** → `https://talk-seed.web.app/sitemap.xml` を送信

### 4. インデックス登録をリクエスト

Search Console → **URL 検査** → `https://talk-seed.web.app/` → **インデックス登録をリクエスト**

### 5. App Store Connect との連携

- App Store Connect の **マーケティング URL**（任意）に `https://talk-seed.web.app/` を設定
- note や SNS からも同 URL を共有 → Analytics の「参照元 Web」に計測される
- iPhone Safari では Smart App Banner（`app-id=6760679042`）が表示される

インデックス反映まで **数日〜2週間** かかることがあります。

## ストア提出用メタデータへの反映

デプロイ後、以下のファイルのプレースホルダを実際の URL に置き換えてください：

- `store_assets/app_store_metadata_ja.txt`
- `store_assets/app_store_metadata_en.txt`

```
Support URL:
https://<PROJECT_ID>.web.app/support.html

Privacy Policy URL:
https://<PROJECT_ID>.web.app/privacy.html
```

## サポートページの連絡先について

`web/support.html` のメールアドレス（`support@example.com`）を、実際の連絡先に差し替えてからデプロイしてください。
