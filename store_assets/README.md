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
- iap/（IAP 審査用スクショ）

次にやること（ルート A — Pro 先出し）
1) メタデータを ASC / Play に転記（本ファイル群）
2) ペイウォール等のスクショを差し替え（任意だが推奨）
3) `flutter build ipa` / Archive → ASC へアップロード
4) 新バージョンに `talk_shuffle_pro` を紐づけて審査提出

注意
- 無料コア（お題・各モード）は維持。Pro はプリセット保存と履歴共有（[ROADMAP.md](../ROADMAP.md)）
- 価格は仮 tier（例: ¥100）。本決めは Step 6
- 機能の記述は現行実装に合わせて更新済み
