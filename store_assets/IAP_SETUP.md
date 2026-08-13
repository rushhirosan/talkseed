# Talk Shuffle Pro — IAP セットアップ

商品 ID（コードと一致）: `talk_shuffle_pro`（非消費型）  
Bundle ID: `com.talkseed.app`

コード側: `PurchaseService.iapEnabled = true`（確認完了後にコミット）

---

## チェックリスト（この順）

- [ ] **A.** Paid Apps Agreement / 銀行・税務が Active
- [ ] **B.** ASC に非消費型 `talk_shuffle_pro` を作成 → 提出準備完了
- [ ] **C.** ローカル（StoreKit Configuration）で購入・復元
- [ ] **D.** サンドボックステスター作成
- [ ] **E.** 実機サンドボックスで購入 → 復元 → 再インストール後の復元
- [ ] **F.** 問題なければ `iapEnabled = true` をコミット

---

## A. 契約（商品作成の前提）

1. [App Store Connect](https://appstoreconnect.apple.com/) → **ビジネス**（または Agreements, Tax, and Banking）
2. **Paid Apps** 契約が Active
3. 銀行口座・税務フォームが完了していること

未完了だと IAP を「提出準備完了」にできない。

---

## B. App Store Connect で商品登録

1. [マイ App](https://appstoreconnect.apple.com/apps) → Talk Shuffle（`com.talkseed.app`）
2. 左メニュー **収益化** → **アプリ内課金**（または「機能」→「アプリ内課金」）
3. **+** → **非消費型**
4. 入力:

| 項目 | 値 |
| --- | --- |
| 参照名 | `Talk Shuffle Pro` |
| 製品 ID | **`talk_shuffle_pro`**（後から変更不可） |
| 価格 | 仮 tier（例: ¥480） |

5. ローカライズ（最低 1 言語。日英あるとよい）:

| 言語 | 表示名 | 説明例 |
| --- | --- | --- |
| 日本語 | Talk Shuffle Pro | 名前付きプリセットの保存と、セッション履歴の共有が使えます。 |
| English | Talk Shuffle Pro | Save named presets and share session history. |

6. **審査用スクリーンショット**（必須）
   - ペイウォール画面のスクショで可（シミュレータで OK）
   - 取得例: `iapEnabled = true` で起動 → 履歴共有 or プリセット 2 件目保存 → シート表示 → 撮影

7. 保存後、ステータスを **提出準備完了（Ready to Submit）** にする  
   - 初回 IAP は次のアプリバージョン提出に紐づくことが多いが、**サンドボックステスト自体は Ready 後すぐ可能なことが多い**

---

## C. ローカル確認（Xcode StoreKit Configuration）

ASC 登録と**並行可**。実ストアに繋がず、ローカル課金シートで確認する。

1. Xcode で `ios/Runner.xcworkspace` を開く
2. **Product → Scheme → Edit Scheme → Run → Options**
3. **StoreKit Configuration** = `Runner/TalkShuffle.storekit`
4. `flutter run`（実機 or シミュレータ）
5. 確認内容:
   - ペイウォールに価格（¥480 相当）が出る
   - **購入** → Pro 解除（共有・プリセット 2 件目が通る）
   - **復元**（アプリについて or ペイウォール）

ペイウォールの出し方:

- 履歴詳細の共有、または
- プリセットを 1 件保存済みの状態で 2 件目を保存

---

## D. サンドボックステスター

1. ASC → **ユーザとアクセス** → **Sandbox**（または「テスター」）
2. **+** でテスター作成（本番 Apple ID とは別のメール）
3. 実機: **設定 → App Store → サンドボックスアカウント** でサインイン  
   - iOS の版によって「メディアと購入」配下の場合あり
   - **本番 Apple ID で App Store にログインしたまま買わない**（混在するとハマりやすい）

---

## E. 実機サンドボックス確認（ASC 商品 Ready 後）

**重要:** Scheme の StoreKit Configuration を **None** にする。  
設定したままだとローカル `.storekit` が使われ、ASC サンドボックスに繋がらない。

1. Xcode Scheme → Run → Options → StoreKit Configuration = **None**
2. `flutter run --release` でも Debug でも可（実機）
3. サンドボックスアカウントでサインイン済みであることを確認
4. チェック:
   - [ ] 購入（サンドボックス用の確認ダイアログが出る）
   - [ ] 復元
   - [ ] アプリ削除 → 再インストール → 復元で Pro が戻る

トラブル時:

| 症状 | 確認 |
| --- | --- |
| 商品が見つからない / 価格が出ない | 製品 ID が `talk_shuffle_pro` か、Ready か、契約 Active か |
| 購入シートが出ない | `iapEnabled`、StoreKit Configuration が None か、サンドボックスログイン |
| ずっと pending | ダイアログを閉じた / 別 Apple ID で試す |

---

## F. 確認後

- `iapEnabled = true` のままコミット
- ストア文面の「課金なし」更新は提出直前（ルート A/B 決定後）でよい

---

## Android（提出する場合・並行可）

1. Play Console で同じ製品 ID `talk_shuffle_pro`（管理対象商品 / 非消費）
2. ライセンステスターで購入確認
