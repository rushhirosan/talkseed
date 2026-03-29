---
name: update-cursor-settings
description: >-
  Edits Cursor/VSCode user or workspace settings.json. Use when changing editor
  font, tab size, format on save, Dart/Flutter analyzer options, themes,
  keybindings, or when the user asks to configure Cursor/VS Code for Flutter
  development.
---

# Updating Cursor / VS Code Settings

Cursor は VS Code 互換の `settings.json` を使う。変更は **既存を読んでから差分だけ** 足す。

## ファイルの場所

### ユーザー設定（全プロジェクト）

| OS | パス |
|----|------|
| macOS | `~/Library/Application Support/Cursor/User/settings.json` |
| Linux | `~/.config/Cursor/User/settings.json` |
| Windows | `%APPDATA%\Cursor\User\settings.json` |

### ワークスペース（このリポのみ）

- `.vscode/settings.json`（リポジトリ直下。チーム共有したいとき）

ユーザーが「このプロジェクトだけ」と言ったらワークスペースを優先する。

---

## 手順

1. **現在の `settings.json` を読む**（空や未作成なら `{}` から）
2. **依頼されたキーだけ**追加・更新（他は維持）
3. **JSON の妥当性**を確認（VS Code は JSONC: `//` コメント可。読むときはコメントに注意）
4. 変更後、**ウィンドウの再読み込みが必要な場合**があると伝える

---

## Flutter / Dart でよく触る設定

| 依頼の例 | 設定キー（例） |
|----------|----------------|
| 保存時フォーマット | `editor.formatOnSave`: `true` |
| Dart の既定フォーマッタ | `[dart]`: `{ "editor.defaultFormatter": "Dart-Code.dart-code", "editor.formatOnSave": true }` |
| 行末・改行 | `files.eol`, `files.insertFinalNewline` |
| 分析サーバ | Dart 拡張の設定は `[dart]` セクションや `dart.*` を確認 |

```json
{
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true,
    "editor.rulers": [80]
  }
}
```

---

## 一般設定（言語非依存）

| 依頼 | 設定 |
|------|------|
| フォントサイズ | `editor.fontSize` |
| タブ幅 | `editor.tabSize` |
| テーマ | `workbench.colorTheme` |
| ミニマップ | `editor.minimap.enabled` |
| 自動保存 | `files.autoSave` |
| 折り返し | `editor.wordWrap` |

---

## 注意

1. **JSONC**: コメントを消さないよう、書き戻すときは既存スタイルを尊重する。
2. **CLI のコミット作者表示**などは `settings.json` ではなく **Cursor Settings > Agent** や `~/.cursor/cli-config.json` の場合がある（依頼内容で切り分け）。
3. **大きな変更前**はユーザーがバックアップできる旨を一言あってよい。

---

## ワークフロー

1. 対象がユーザー設定か `.vscode/settings.json` か決める
2. Read で現状を取得
3. 要求どおりマージ
4. Write で保存
5. 再読み込みの要否を伝える
