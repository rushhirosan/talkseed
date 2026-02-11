import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'polyhedron_type.dart';

/// テーマデータのモデルクラス
class ThemeModel {
  /// デフォルトのテーマキーリスト（正六面体用）
  static const List<String> defaultThemeKeys = [
    'themeSurprised',
    'themeFutureDream',
    'themeLoveStory',
    'themeRecommendedBook',
    'themeRecentHobby',
    'themeDislike',
  ];

  /// デフォルトのテーマキーリスト（正四面体用）
  static const List<String> defaultThemeKeysTetrahedron = [
    'themeSurprised',
    'themeFutureDream',
    'themeLoveStory',
    'themeRecommendedBook',
  ];

  /// デフォルトのテーマキーリスト（正八面体用）
  static const List<String> defaultThemeKeysOctahedron = [
    'themeSurprised',
    'themeFutureDream',
    'themeLoveStory',
    'themeRecommendedBook',
    'themeRecentHobby',
    'themeDislike',
    'themeFavoriteMovie',
    'themeTreasure',
  ];

  /// 多面体タイプごとのデフォルトテーマキーを取得
  static List<String> getDefaultThemeKeys(PolyhedronType type) {
    switch (type) {
      case PolyhedronType.tetrahedron:
        return List<String>.from(defaultThemeKeysTetrahedron);
      case PolyhedronType.cube:
        return List<String>.from(defaultThemeKeys);
      case PolyhedronType.octahedron:
        return List<String>.from(defaultThemeKeysOctahedron);
    }
  }

  /// 多面体タイプごとのデフォルトテーマを取得（AppLocalizationsを使用）
  static List<String> getDefaultThemes(PolyhedronType type, AppLocalizations l10n) {
    final keys = getDefaultThemeKeys(type);
    return keys.map((key) => _getThemeString(key, l10n)).toList();
  }

  /// テーマキーから文字列を取得
  static String _getThemeString(String key, AppLocalizations l10n) {
    switch (key) {
      case 'themeSurprised':
        return l10n.themeSurprised;
      case 'themeFutureDream':
        return l10n.themeFutureDream;
      case 'themeLoveStory':
        return l10n.themeLoveStory;
      case 'themeRecommendedBook':
        return l10n.themeRecommendedBook;
      case 'themeRecentHobby':
        return l10n.themeRecentHobby;
      case 'themeDislike':
        return l10n.themeDislike;
      case 'themeFavoriteMovie':
        return l10n.themeFavoriteMovie;
      case 'themeTreasure':
        return l10n.themeTreasure;
      case 'themeCried':
        return l10n.themeCried;
      case 'themeLaughed':
        return l10n.themeLaughed;
      case 'themeMoved':
        return l10n.themeMoved;
      case 'themeRegret':
        return l10n.themeRegret;
      case 'themeProud':
        return l10n.themeProud;
      case 'themeEmbarrassed':
        return l10n.themeEmbarrassed;
      case 'themeFavoriteMusic':
        return l10n.themeFavoriteMusic;
      case 'themeFavoriteAnime':
        return l10n.themeFavoriteAnime;
      case 'themeFavoriteGame':
        return l10n.themeFavoriteGame;
      case 'themeFavoriteFood':
        return l10n.themeFavoriteFood;
      case 'themeWantToVisit':
        return l10n.themeWantToVisit;
      case 'themeFavoriteSport':
        return l10n.themeFavoriteSport;
      case 'themeFriendMemory':
        return l10n.themeFriendMemory;
      case 'themeFamilyMemory':
        return l10n.themeFamilyMemory;
      case 'themeGrateful':
        return l10n.themeGrateful;
      case 'themeSupporting':
        return l10n.themeSupporting;
      case 'themeWantToDo':
        return l10n.themeWantToDo;
      case 'themeWantToAchieve':
        return l10n.themeWantToAchieve;
      case 'themeDreamJob':
        return l10n.themeDreamJob;
      case 'themeWantToVisitCountry':
        return l10n.themeWantToVisitCountry;
      case 'themeRecentEvent':
        return l10n.themeRecentEvent;
      case 'themeTodayEvent':
        return l10n.themeTodayEvent;
      case 'themeWeekendPlan':
        return l10n.themeWeekendPlan;
      case 'themeRelaxMethod':
        return l10n.themeRelaxMethod;
      case 'themeStressRelief':
        return l10n.themeStressRelief;
      case 'themeMorningRoutine':
        return l10n.themeMorningRoutine;
      case 'themeFavoriteWord':
        return l10n.themeFavoriteWord;
      case 'themeMotto':
        return l10n.themeMotto;
      case 'themeImportantThing':
        return l10n.themeImportantThing;
      case 'themeBelief':
        return l10n.themeBelief;
      case 'themeLifeLesson':
        return l10n.themeLifeLesson;
      case 'themeRecentWorry':
        return l10n.themeRecentWorry;
      case 'themeProudOf':
        return l10n.themeProudOf;
      case 'themeUniqueSkill':
        return l10n.themeUniqueSkill;
      case 'themeSecret':
        return l10n.themeSecret;
      case 'themeChildhoodMemory':
        return l10n.themeChildhoodMemory;
      default:
        return key;
    }
  }

  /// テーマリストを取得（後方互換性のため）
  @Deprecated('Use getThemesForType instead')
  static List<String> get themes => defaultThemeKeys;

  /// 多面体タイプに対応するテーマリストを取得
  static List<String> getThemesForType(PolyhedronType type, Map<PolyhedronType, List<String>> customThemes, AppLocalizations l10n) {
    return customThemes[type] ?? getDefaultThemes(type, l10n);
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

  /// テーマ候補のキーリスト
  /// ドラッグアンドドロップで使用する候補テーマ
  static const List<String> themeCandidateKeys = [
    // 感情・体験系
    'themeSurprised',
    'themeCried',
    'themeLaughed',
    'themeMoved',
    'themeRegret',
    'themeProud',
    'themeEmbarrassed',
    
    // 趣味・興味系
    'themeRecentHobby',
    'themeRecommendedBook',
    'themeFavoriteMovie',
    'themeFavoriteMusic',
    'themeFavoriteAnime',
    'themeFavoriteGame',
    'themeFavoriteFood',
    'themeWantToVisit',
    'themeFavoriteSport',
    
    // 人間関係系
    'themeLoveStory',
    'themeFriendMemory',
    'themeFamilyMemory',
    'themeTreasure',
    'themeGrateful',
    'themeSupporting',
    
    // 将来・夢系
    'themeFutureDream',
    'themeWantToDo',
    'themeWantToAchieve',
    'themeDreamJob',
    'themeWantToVisitCountry',
    
    // 日常・生活系
    'themeRecentEvent',
    'themeTodayEvent',
    'themeWeekendPlan',
    'themeRelaxMethod',
    'themeStressRelief',
    'themeMorningRoutine',
    
    // 価値観・考え方系
    'themeDislike',
    'themeFavoriteWord',
    'themeMotto',
    'themeImportantThing',
    'themeBelief',
    'themeLifeLesson',
    
    // その他
    'themeRecentWorry',
    'themeProudOf',
    'themeUniqueSkill',
    'themeSecret',
    'themeChildhoodMemory',
  ];

  /// テーマ候補のリストを取得（AppLocalizationsを使用）
  static List<String> getThemeCandidates(AppLocalizations l10n) {
    return themeCandidateKeys.map((key) => _getThemeString(key, l10n)).toList();
  }
}

