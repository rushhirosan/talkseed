# Android リリース署名のセットアップ

Google Play に提出するには、アップロード用 keystore と key.properties が必要です。

## ✅ セットアップ済み

`upload-keystore.jks` と `key.properties` はすでに作成済みです。
**重要**: `key.properties` 内のパスワードを安全な場所にバックアップしてください。

## 1. Keystore を作成

`android/` ディレクトリで実行（Java が必要）:

```bash
cd android
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

パスワードを聞かれたら入力（2回）。**このパスワードは絶対に忘れないでください。** Play の更新に必要です。

## 2. key.properties を作成

`android/key.properties.example` をコピーして `key.properties` を作成:

```bash
cp key.properties.example key.properties
```

`key.properties` を編集し、パスワードを設定:

```
storePassword=あなたが設定したパスワード
keyPassword=あなたが設定したパスワード
keyAlias=upload
storeFile=upload-keystore.jks
```

## 3. バックアップ

- `upload-keystore.jks` と `key.properties` のパスワードを安全な場所に保管
- keystore を失うと Play の更新ができなくなります

## 4. ビルド

```bash
flutter build appbundle
```

出力: `build/app/outputs/bundle/release/app-release.aab`
