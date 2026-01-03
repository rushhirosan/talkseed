/// テーマデータのモデルクラス
class ThemeModel {
  /// デフォルトのテーマリスト
  static const List<String> defaultThemes = [
    'びっくりしたこと',
    '将来の夢',
    '恋の話',
    'おすすめの本',
    '最近ハマっていること',
    '嫌いなこと',
  ];

  /// テーマリストを取得
  static List<String> get themes => defaultThemes;

  /// インデックスからテーマを取得
  static String? getThemeByIndex(int index) {
    if (index >= 0 && index < defaultThemes.length) {
      return defaultThemes[index];
    }
    return null;
  }

  /// 面の番号（1-6）からテーマを取得
  static String? getThemeByFaceNumber(int faceNumber) {
    final index = faceNumber - 1;
    return getThemeByIndex(index);
  }
}

