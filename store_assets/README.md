Talk Shuffle ストア素材（ドラフト）

このフォルダは App Store / Google Play 提出用のテキスト素材と
スクリーンショット作成ガイドをまとめたものです。

**将来の To-Do・優先順位:** [../ROADMAP.md](../ROADMAP.md)

含まれるファイル
- app_store_metadata_ja.txt
- app_store_metadata_en.txt
- google_play_metadata_ja.txt
- google_play_metadata_en.txt
- store_keywords_ja.txt
- store_keywords_en.txt
- screenshot_plan.md
- screenshots/（撮影した画像の保存先：ios/, android/）
- FIREBASE_DEPLOY.md（Firebase Hosting デプロイ手順）
- IAP_SETUP.md（Pro アプリ内課金の商品 ID・ASC / サンドボックス手順）
- GOOGLE_PLAY_LAUNCH.md（**Play 公開: Create app → クローズド 12×14 → 本番**）
- play_feature_graphic.png（Play ストア Feature graphic 1024×500）
- iap/（IAP 審査用スクショ）

次にやること
1) **Google Play** — [GOOGLE_PLAY_LAUNCH.md](GOOGLE_PLAY_LAUNCH.md) のチェックリストを上から消化
2) メタデータを Play に転記（google_play_metadata_*.txt）
3) AAB → クローズドテスト → テスター確保 → Production Access
4) Play に `talk_shuffle_pro` を作成（IAP_SETUP.md Android 節）

注意
- Package name は **`com.talkseed.app`**（変更不可）
- 無料コアは維持。Pro はひらめきモード + プリセット + 履歴共有（[ROADMAP.md](../ROADMAP.md)）
- 個人アカウントはクローズド 12人×14日が本番申請の前提
