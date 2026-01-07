import 'polyhedron_type.dart';

/// テーマデータのモデルクラス
class ThemeModel {
  /// デフォルトのテーマリスト（正六面体用）
  static const List<String> defaultThemes = [
    'びっくりしたこと',
    '将来の夢',
    '恋の話',
    'おすすめの本',
    '最近ハマっていること',
    '嫌いなこと',
  ];

  /// デフォルトのテーマリスト（正四面体用）
  static const List<String> defaultThemesTetrahedron = [
    'びっくりしたこと',
    '将来の夢',
    '恋の話',
    'おすすめの本',
  ];

  /// デフォルトのテーマリスト（正八面体用）
  static const List<String> defaultThemesOctahedron = [
    'びっくりしたこと',
    '将来の夢',
    '恋の話',
    'おすすめの本',
    '最近ハマっていること',
    '嫌いなこと',
    '好きな映画',
    '大切にしていること',
  ];

  /// 多面体タイプごとのデフォルトテーマを取得
  static List<String> getDefaultThemes(PolyhedronType type) {
    switch (type) {
      case PolyhedronType.tetrahedron:
        return List<String>.from(defaultThemesTetrahedron);
      case PolyhedronType.cube:
        return List<String>.from(defaultThemes);
      case PolyhedronType.octahedron:
        return List<String>.from(defaultThemesOctahedron);
    }
  }

  /// テーマリストを取得（後方互換性のため）
  @Deprecated('Use getThemesForType instead')
  static List<String> get themes => defaultThemes;

  /// 多面体タイプに対応するテーマリストを取得
  static List<String> getThemesForType(PolyhedronType type, Map<PolyhedronType, List<String>> customThemes) {
    return customThemes[type] ?? getDefaultThemes(type);
  }

  /// インデックスからテーマを取得
  static String? getThemeByIndex(int index, List<String> themes) {
    if (index >= 0 && index < themes.length) {
      return themes[index];
    }
    return null;
  }

  /// 面の番号（1から始まる）からテーマを取得
  static String? getThemeByFaceNumber(int faceNumber, List<String> themes) {
    final index = faceNumber - 1;
    return getThemeByIndex(index, themes);
  }

  /// テーマ候補のリスト
  /// ドラッグアンドドロップで使用する候補テーマ
  static const List<String> themeCandidates = [
    // 感情・体験系
    'びっくりしたこと',
    '泣いたこと',
    '笑ったこと',
    '感動したこと',
    '後悔していること',
    '誇らしいこと',
    '恥ずかしかったこと',
    
    // 趣味・興味系
    '最近ハマっていること',
    'おすすめの本',
    '好きな映画',
    '好きな音楽',
    '好きなアニメ',
    '好きなゲーム',
    '好きな食べ物',
    '行きたい場所',
    '好きなスポーツ',
    
    // 人間関係系
    '恋の話',
    '友達との思い出',
    '家族との思い出',
    '大切にしていること',
    '感謝していること',
    '応援している人',
    
    // 将来・夢系
    '将来の夢',
    'やってみたいこと',
    '実現したいこと',
    'なりたい職業',
    '行ってみたい国',
    
    // 日常・生活系
    '最近の出来事',
    '今日の出来事',
    '週末の予定',
    'リラックス方法',
    'ストレス解消法',
    '朝のルーティン',
    
    // 価値観・考え方系
    '嫌いなこと',
    '好きな言葉',
    '座右の銘',
    '大切なもの',
    '信じていること',
    '人生で学んだこと',
    
    // その他
    '最近の悩み',
    '自慢できること',
    '変わった特技',
    '秘密にしていること',
    '子供の頃の思い出',
  ];
}

