import 'package:shared_preferences/shared_preferences.dart';

/// アプリの設定を管理するヘルパークラス
class PreferencesHelper {
  static const String _keyIsFirstLaunch = 'is_first_launch';

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
}
