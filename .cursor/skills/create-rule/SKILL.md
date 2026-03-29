---
name: create-rule
description: >-
  Creates and edits Cursor project rules under .cursor/rules/ (.mdc). Use when
  adding coding standards, Flutter/Dart conventions, file-specific globs,
  AGENTS.md, or when the user mentions project rules, .cursor/rules, or
  project-rules.mdc for Theme Dice or similar Flutter repos.
---

# Creating Cursor Rules（プロジェクトルール）

`.cursor/rules/*.mdc` に永続的な AI 向けコンテキストを置く。

## このリポジトリ（Theme Dice）の既存ルール

- メイン: `.cursor/rules/project-rules.mdc`
- 追記・分割するときは **関心ごとにファイルを分ける**（例: `material-ui.mdc`, `state-management.mdc`）

## 作成前に決めること

1. **目的**: 何を守らせるか（命名、レイヤ、禁止事項など）
2. **適用範囲**: 常時か、特定ファイルだけか
3. **globs**: ファイル別ルールならパターン（例: `lib/**/*.dart`）

文脈から推測できる場合は重複質問を避ける。スコープが曖昧なら「常時か、globs か」を確認する。

---

## ファイル形式

`.cursor/rules/` に `.mdc` を置き、YAML フロントマター付き:

```markdown
---
description: ルールの要約（ルールピッカーに表示）
globs: lib/**/*.dart
alwaysApply: false
---

# タイトル

本文…
```

### フロントマター

| フィールド | 説明 |
|------------|------|
| `description` | 何のルールか（必須に近い） |
| `globs` | マッチしたファイルを扱うときに適用（省略時は alwaysApply と組み合わせ） |
| `alwaysApply` | `true` なら毎セッションで読み込む |

### 常に効かせる

```yaml
---
description: Theme Dice の共通方針
alwaysApply: true
---
```

### Dart / Flutter だけ

```yaml
---
description: lib 以下の Dart 規約
globs: lib/**/*.dart
alwaysApply: false
---
```

### 特定ディレクトリのみ

```yaml
---
description: ウィジェットの分割方針
globs: lib/widgets/**/*.dart
alwaysApply: false
---
```

---

## ベストプラクティス

- **短く**: 目安 50 行以内／関心はファイル分割
- **実行可能**: 「〜にすること」が一文で分かる
- **例**: 良い例・悪い例があると迷いが減る
- **500 行未満**: 長いら別 `.mdc` に分ける

---

## チェックリスト

- [ ] `.cursor/rules/` 配下の `.mdc`
- [ ] `description` と `alwaysApply` / `globs` が意図どおり
- [ ] 既存の `project-rules.mdc` と矛盾しない（矛盾するなら統合または明記）
