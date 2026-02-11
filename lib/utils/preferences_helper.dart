import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// アプリの設定を管理するヘルパークラス
class PreferencesHelper {
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyLastThemes = 'last_themes';
  static const String _keyLastCardThemes = 'last_card_themes';
  /// 案B: 起動時に開くモード 'dice' | 'topic_card' | 未設定は null
  static const String _keyDefaultPlayMode = 'default_play_mode';

  /// 初回起動かどうかを確認
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  /// 初回起動フラグを無効化（チュートリアルを見た後）
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstLaunch, false);
  }

  /// 初回起動フラグをリセット（デバッグ用）
  static Future<void> resetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsFirstLaunch);
  }

  /// 最後に使用したテーマを保存（再訪時にサイコロ画面をホームにするため）
  static Future<void> saveLastThemes(List<String> themes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastThemes, jsonEncode(themes));
  }

  /// 最後に使用したテーマを読み込み（サイコロ用：6面固定）
  /// 6面分のテーマがない場合はnull
  static Future<List<String>?> loadLastThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyLastThemes);
    if (json == null) return null;
    try {
      final list = jsonDecode(json) as List<dynamic>;
      final themes = list.map((e) => e.toString()).toList();
      if (themes.length != 6) return null;
      return themes;
    } catch (_) {
      return null;
    }
  }

  /// 最後に使用したカードテーマを保存（枚数可変）
  static Future<void> saveLastCardThemes(List<String> themes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCardThemes, jsonEncode(themes));
  }

  /// 最後に使用したカードテーマを読み込み（枚数可変）
  static Future<List<String>?> loadLastCardThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyLastCardThemes);
    if (json == null) return null;
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return null;
    }
  }

  /// 起動時に開くモードを保存（案B: いつもこれで遊ぶ）
  /// [mode] 'dice' | 'topic_card' | null（未設定）
  static Future<void> saveDefaultPlayMode(String? mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (mode == null) {
      await prefs.remove(_keyDefaultPlayMode);
    } else {
      await prefs.setString(_keyDefaultPlayMode, mode);
    }
  }

  /// 起動時に開くモードを読み込み
  /// 戻り値 'dice' | 'topic_card' | null
  static Future<String?> loadDefaultPlayMode() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_keyDefaultPlayMode);
    if (v == 'dice' || v == 'topic_card') return v;
    return null;
  }
}
