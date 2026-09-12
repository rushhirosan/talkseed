# Google Play 公開手順（Talk Shuffle）

個人デベロッパー向け。クローズドテスト（12人×14日）→ Production Access → 本番公開。

**進捗の正:** 下のチェックリストを更新する。要約は [../ROADMAP.md](../ROADMAP.md)。

最終更新: 2026-09-07

---

## 固定値（打ち間違い注意）

| 項目 | 値 | 備考 |
| --- | --- | --- |
| App name | `Talk Shuffle` | 後から変更可（30文字以内） |
| Package name | **`com.talkseed.app`** | **作成後変更不可**。コードの `applicationId` と一致必須 |
| Default language | English (United States) – en-US | 後から日本語ストアも追加可 |
| App or game | **App** | |
| Free or paid | **Free** | Pro は IAP。無料アプリのまま |
| Pro 商品 ID | `talk_shuffle_pro` | 非消費 / 管理対象商品。iOS と同じ ID |

ストア文面: [google_play_metadata_ja.txt](google_play_metadata_ja.txt) / [google_play_metadata_en.txt](google_play_metadata_en.txt)  
IAP: [IAP_SETUP.md](IAP_SETUP.md)

---

## 進捗チェックリスト

### A. アプリ作成（Play Console）

- [ ] **A.1** Create app フォーム入力 → Create app
  - App name: `Talk Shuffle`
  - Package name: `com.talkseed.app`
  - App / Free
  - Developer Program Policies + US export laws に同意
- [ ] **A.2** ダッシュボードのセットアップタスク開始

### B. ストア掲載・ポリシー（公開前に必須のものから）

- [ ] **B.1** ストアの設定（短い説明・説明文・アイコン・スクショ）— メタデータ TXT から転記
- [ ] **B.2** グラフィック（ハイレゾアイコン 512、フィーチャーグラフィックなど）
  - Feature graphic: [play_feature_graphic.png](play_feature_graphic.png)（1024×500・作成済 2026-09-07）
  - App icon: `web/icons/Icon-512.png`
  - Phone screenshots: `store_assets/screenshots/android/16x9/ja/`（**01–06 取込済 2026-09-07**。マッシュアップ／ビンゴは設定画面。プレイ盤は任意で追加 → [screenshot_plan.md](screenshot_plan.md)）
- [ ] **B.3** プライバシーポリシー URL
- [ ] **B.4** アプリのカテゴリ・連絡先
- [ ] **B.5** コンテンツレーティング質問票
- [ ] **B.6** 対象オーディエンス / ニュースアプリ等の宣言
- [ ] **B.7** データセーフティフォーム
- [ ] **B.8** 広告の有無（なし）

### C. 署名・AAB

- [ ] **C.1** アップロードキー / Play App Signing 設定
- [ ] **C.2** `flutter build appbundle --release`
- [ ] **C.3** 成果物: `build/app/outputs/bundle/release/app-release.aab`

### D. クローズドテスト（本番申請の前提）

個人アカウント（2023-11-13 以降作成）は公式要件:

- クローズドテストで **12人以上がオプトイン**
- 申請時点で **直前14日間連続**でその状態
- その後 Dashboard から **Production Access を申請**（質問回答）
- 参照: [App testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465)

手順:

- [ ] **D.1** テスト → クローズドテスト → トラック作成
- [ ] **D.2** 新リリースに AAB をアップロード → 審査 / 公開
- [ ] **D.3** テスター用オプトイン URL を控える  
  （例: `https://play.google.com/apps/testing/com.talkseed.app`）
- [ ] **D.4** テスター確保（知人ゼロなら有料サービス可）
  - 推奨バッファ: **15人**（12ぴったりは脱落で14日やり直し）
  - 候補: [Testers Community](https://www.testerscommunity.com/pricing) Starter 等（~$15）
- [ ] **D.5** Console でオプトイン **12人以上**を確認した日を記録: `____-__-__`
- [ ] **D.6** 14日間、人数が12未満に落ちないか時々確認
- [ ] **D.7** 14日経過後、Dashboard から Production Access 申請
  - 回答は「何をテストしたか・フィードバック・直した点」を具体的に（Spark / サイコロ / Pro など）
  - 有料サービスの回答案は骨子のみ。アプリ固有の文言に直す
- [ ] **D.8** Production Access 承認

**注意:** 有料で人数を揃えても自動公開にはならない。14日＋申請が別途必要。

### E. IAP（Play・並行可）

- [ ] **E.1** Play Console に `talk_shuffle_pro`（管理対象・非消費）を作成
- [ ] **E.2** ライセンステスターで購入・復元確認
- [ ] 詳細は [IAP_SETUP.md](IAP_SETUP.md) の Android 節

### F. 本番公開

- [ ] **F.1** 本番トラックに AAB を出す
- [ ] **F.2** 本番リリースを審査提出
- [ ] **F.3** 公開後、実機で Pro 購入フロー確認

---

## コマンドメモ

```bash
cd /Users/hiroyuki_igusa_2025/src/theme_dice
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

実機デバッグ確認例:

```bash
flutter devices
flutter run --release -d <deviceId>
```

---

## Create app 画面の記入例（コピー用）

```
App name:          Talk Shuffle
Package name:      com.talkseed.app
Default language:  English (United States) – en-US
App or game:       App
Free or paid:      Free
Declarations:      Policies ☑ / US export laws ☑
```
