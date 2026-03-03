# Talk Seed - Firebase Hosting デプロイ手順

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

- **メインアプリ**: `https://<PROJECT_ID>.web.app/`
- **プライバシーポリシー**: `https://<PROJECT_ID>.web.app/privacy.html`
- **サポート**: `https://<PROJECT_ID>.web.app/support.html`

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
