# Talk Seed ストア公開 To-Do リスト

## Phase 1: 事前準備（Android Studio 不要）

- [x] **1.1 アプリ ID / バンドル ID を決める**
  - 例: `com.yourdomain.talkseed`（`com.example.*` は避ける）
  - 採用: `com.talkseed.app`

- [x] **1.2 プライバシーポリシーページを作成・公開**
  - `web/privacy.html` が作成済み
  - `store_assets/FIREBASE_DEPLOY.md` を参照して Firebase Hosting にデプロイ
  - 取得した URL をメモ（例: `https://<PROJECT_ID>.web.app/privacy.html`）

- [x] **1.3 サポートページを用意**
  - `web/support.html` が作成済み（メールアドレスを実際の連絡先に差し替えること）
  - Firebase Hosting にデプロイ済みなら同じドメインで利用可能
  - 取得した URL をメモ（例: `https://<PROJECT_ID>.web.app/support.html`）

- [x] **1.4 メタデータに URL を反映**
  - `app_store_metadata_ja.txt` の `<SUPPORT_URL>`, `<PRIVACY_POLICY_URL>` を置き換え
  - `app_store_metadata_en.txt` も同様

---

## Phase 2: スクリーンショット

- [ ] **2.1 撮影**（screenshot_plan.md を参照）
  - モード選択
  - 3D サイコロ画面
  - テーマ設定（ドラッグ＆ドロップ）
  - チェックイン／チェックアウト
  - 価値観カード
  - セッション設定 or 履歴

- [ ] **2.2 サイズ調整**
  - iOS: 6.7" 必須（他サイズは任意）
  - Android: 16:9 or 20:9（主要サイズ）

- [ ] **2.3 日英それぞれのスクリーンショットを撮る**（任意）

---

## Phase 3: 開発環境・ビルド設定

- [x] **3.1 アプリ ID を変更**
  - Android: `android/app/build.gradle.kts` の `applicationId` と `namespace`
  - iOS: Xcode の Bundle Identifier（`ios/Runner.xcodeproj/project.pbxproj`）
  - 採用: `com.talkseed.app`

- [x] **3.2 Android リリース署名の設定**
  - upload keystore を作成（`android/upload-keystore.jks`）
  - `android/key.properties` を作成（`.gitignore` に追加済み）
  - `build.gradle.kts` に release signing config を追加
  - ※ key.properties のパスワードはバックアップすること（`android/KEYSTORE_SETUP.md` 参照）

---

## Phase 4: ビルド・提出物作成

- [x] **4.1 Android AAB をビルド**
  - `flutter build appbundle`
  - 出力: `build/app/outputs/bundle/release/app-release.aab` ✓

- [x] **4.2 iOS IPA / Xcode Archive**
  - Archive 作成済み: `build/ios/archive/Runner.xcarchive`
  - IPA エクスポート: Apple Developer Program 登録・iOS Distribution 証明書が必要
  - Xcode で開いて手動エクスポート: `open build/ios/archive/Runner.xcarchive`

※ Android ビルドのため `vibration` を 1.8.4 → 2.1.0 にアップグレード済み（v1 embedding 対応）

---

## Phase 5: ストア登録・提出

- [ ] **5.1 Google Play Console**
  - 開発者登録（初回）
  - 新規アプリ作成
  - ストア掲載情報（メタデータ、スクリーンショット）を入力
  - AAB をアップロード
  - 審査提出

- [ ] **5.2 App Store Connect**
  - Apple Developer Program 登録（年 $99）
  - 新規アプリ作成
  - ストア掲載情報（メタデータ、スクリーンショット）を入力
  - ビルドをアップロード
  - 審査提出

---

## Phase 6: 最終確認（任意）

- [ ] **6.1 メタデータの転記**
  - store_assets の各ファイルを各ストアのフォームにコピペ

- [ ] **6.2 機密情報チェック**
  - `git status` / `git diff` で `.env` や API キーなどが含まれていないか確認
