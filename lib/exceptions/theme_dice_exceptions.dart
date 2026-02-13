/// Talk Seed アプリのエラーハンドリング用基底例外
sealed class ThemeDiceException implements Exception {
  ThemeDiceException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      cause != null ? '$message (cause: $cause)' : message;
}

/// アセット（JSONファイル）の読み込みに失敗した場合
class DataLoadException extends ThemeDiceException {
  DataLoadException(super.message, [super.cause]);

  /// 指定パスからの読み込み失敗
  factory DataLoadException.assetLoadFailed(String assetPath, [Object? cause]) =>
      DataLoadException(
        'Failed to load asset: $assetPath',
        cause,
      );
}

/// JSONのパース（デコード・スキーマ検証）に失敗した場合
class DataParseException extends ThemeDiceException {
  DataParseException(super.message, [super.cause]);

  /// 不正なJSON形式
  factory DataParseException.invalidJson(String assetPath, [Object? cause]) =>
      DataParseException(
        'Invalid JSON format in asset: $assetPath',
        cause,
      );

  /// 期待するスキーマと不一致
  factory DataParseException.schemaMismatch(String assetPath, String detail,
          [Object? cause]) =>
      DataParseException(
        'Unexpected schema in $assetPath: $detail',
        cause,
      );
}
