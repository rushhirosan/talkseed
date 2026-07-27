import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pro / IAP 状態の単一入口（ROADMAP Step 2）。
///
/// 本番 StoreKit / Play Billing は未接続。ローカル確認は debug ゲート + 解除トグルで行う。
class PurchaseService {
  PurchaseService._();

  /// App Store / Play に登録する非消費型商品 ID（仮）
  static const productId = 'talk_shuffle_pro';

  /// 未購入時のお試しプリセット件数
  static const int freePresetLimit = 1;

  /// Pro 時のプリセット上限
  static const int proPresetLimit = 10;

  /// 本番 IAP を有効化するときに true にする（商品登録・サンドボックス確認後）
  static const bool iapEnabled = false;

  static const _keyProUnlocked = 'pro_unlocked_v1';
  static const _keyDebugGating = 'debug_pro_gating_v1';
  static const _keyDebugForcePro = 'debug_force_pro_v1';

  /// Pro 判定の単一入口。
  ///
  /// - ゲート無効時も「購入済みか」自体は返す（UI 表示用）
  /// - debug の Force Pro は [kDebugMode] のときだけ効く
  static Future<bool> isPro() async {
    final prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      final forced = prefs.getBool(_keyDebugForcePro);
      if (forced != null) {
        return forced;
      }
    }
    return prefs.getBool(_keyProUnlocked) ?? false;
  }

  /// 共有・プリセット保存などの Pro ゲートを適用するか。
  ///
  /// - [iapEnabled] が true → 常にゲート
  /// - debug → prefs（デフォルト ON。ローカルでペイウォール確認用）
  /// - それ以外 → ゲートなし（従来どおり無料）
  static Future<bool> isGatingActive() async {
    if (iapEnabled) {
      return true;
    }
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyDebugGating) ?? true;
    }
    return false;
  }

  static Future<int> maxPresetsAllowed() async {
    if (!await isGatingActive()) {
      return proPresetLimit;
    }
    return await isPro() ? proPresetLimit : freePresetLimit;
  }

  /// 新規プリセットを保存できるか（[currentCount] は既存件数。更新は呼び出し側で別扱い）
  static Future<bool> canSaveNewPreset(int currentCount) async {
    if (!await isGatingActive()) {
      return true;
    }
    if (await isPro()) {
      return true;
    }
    return currentCount < freePresetLimit;
  }

  /// 履歴エクスポート（共有）が可能か
  static Future<bool> canExportHistory() async {
    if (!await isGatingActive()) {
      return true;
    }
    return isPro();
  }

  /// 購入成功時（将来の IAP）またはローカル解除で呼ぶ
  static Future<void> unlockPro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProUnlocked, true);
    if (kDebugMode) {
      // About のトグルと揃える（オフにすればいつでもペイウォール再表示）
      await prefs.setBool(_keyDebugForcePro, true);
    }
  }

  /// ローカル確認用: Pro をオフ（購入前状態に戻す）
  static Future<void> lockProForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProUnlocked, false);
    if (kDebugMode) {
      await prefs.setBool(_keyDebugForcePro, false);
    }
  }

  /// debug 専用: Pro ON/OFF（永続フラグもまとめて切替。繰り返しテスト用）
  static Future<void> setDebugProEnabled(bool enabled) async {
    assert(kDebugMode, 'setDebugProEnabled is debug-only');
    if (enabled) {
      await unlockPro();
    } else {
      await lockProForTesting();
    }
  }

  /// debug 専用: Force Pro（null で解除して永続フラグに戻す）
  static Future<void> setDebugForcePro(bool? value) async {
    assert(kDebugMode, 'setDebugForcePro is debug-only');
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_keyDebugForcePro);
    } else {
      await prefs.setBool(_keyDebugForcePro, value);
    }
  }

  /// debug 専用: Pro ゲートの ON/OFF
  static Future<void> setDebugGatingEnabled(bool enabled) async {
    assert(kDebugMode, 'setDebugGatingEnabled is debug-only');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDebugGating, enabled);
  }

  static Future<bool?> debugForceProValue() async {
    if (!kDebugMode) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDebugForcePro);
  }

  static Future<bool> debugGatingEnabledValue() async {
    if (!kDebugMode) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDebugGating) ?? true;
  }

  /// ペイウォールの「購入」相当。IAP 未接続時は debug のみローカル解除。
  static Future<PurchaseActionResult> purchasePro() async {
    if (iapEnabled) {
      // TODO(Step 2.1): in_app_purchase で [productId] を購入
      return PurchaseActionResult.unavailable;
    }
    if (kDebugMode) {
      await unlockPro();
      return PurchaseActionResult.unlockedLocally;
    }
    return PurchaseActionResult.unavailable;
  }

  /// 復元。IAP 未接続時は debug のみローカル解除（繰り返し確認用）。
  static Future<PurchaseActionResult> restorePurchases() async {
    if (iapEnabled) {
      // TODO(Step 2.1): in_app_purchase.restorePurchases()
      return PurchaseActionResult.unavailable;
    }
    if (await isPro()) {
      return PurchaseActionResult.alreadyPro;
    }
    if (kDebugMode) {
      // ストア未接続のため、復元ボタンもローカルで Pro をオンにする
      await unlockPro();
      return PurchaseActionResult.unlockedLocally;
    }
    return PurchaseActionResult.unavailable;
  }

  static Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProUnlocked);
    await prefs.remove(_keyDebugGating);
    await prefs.remove(_keyDebugForcePro);
  }
}

enum PurchaseActionResult {
  unlockedLocally,
  alreadyPro,
  nothingToRestore,
  unavailable,
}
