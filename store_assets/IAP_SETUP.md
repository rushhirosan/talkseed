# Talk Shuffle Pro — IAP セットアップ

商品 ID（コードと一致）: `talk_shuffle_pro`（非消費型）

## App Store Connect

1. アプリ → **アプリ内課金** → 非消費型を作成
2. 参照名: `Talk Shuffle Pro`
3. 製品 ID: **`talk_shuffle_pro`**（変更する場合は `PurchaseService.productId` も更新）
4. 価格: 仮 tier で可（例: ¥480）
5. 審査用スクリーンショットと説明を追加し、提出準備完了にする

## コード側の有効化

`lib/services/purchase_service.dart` の:

```dart
static const bool iapEnabled = false;
```

を **`true`** にする（サンドボックス購入が通ったあと）。

## ローカル確認（Xcode StoreKit Configuration）

1. Xcode で `ios/Runner.xcworkspace` を開く
2. Product → Scheme → Edit Scheme → Run → Options
3. StoreKit Configuration に `Runner/TalkShuffle.storekit` を指定
4. `flutter run` で実機 / シミュレータ起動
5. `iapEnabled = true` にしたうえでペイウォールから購入・復元

## iOS サンドボックス（ASC 商品登録後）

1. App Store Connect → ユーザとアクセス → Sandbox → テスター作成
2. 実機の設定 → App Store → サンドボックスアカウントでサインイン
3. `iapEnabled = true` のビルドで購入・復元・再インストール後の復元を確認

## Android（提出する場合）

1. Play Console で同じ製品 ID `talk_shuffle_pro`（管理対象商品 / 非消費）
2. ライセンステスターで購入確認
