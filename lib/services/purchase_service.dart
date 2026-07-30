import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pro / IAP 状態の単一入口（ROADMAP Step 2）。
///
/// - [iapEnabled] が false: リリースはゲートなし。debug はローカル解除で確認
/// - [iapEnabled] が true: StoreKit / Play Billing で非消費型 [productId] を購入・復元
///
/// レシートのサーバー検証は行わない（端末内フラグ + ストアの所有権）。
class PurchaseService {
  PurchaseService._();

  /// App Store Connect / Play Console に登録する非消費型商品 ID
  static const productId = 'talk_shuffle_pro';

  /// 未購入時のお試しプリセット件数
  static const int freePresetLimit = 1;

  /// Pro 時のプリセット上限
  static const int proPresetLimit = 10;

  /// 本番 IAP を有効化するときに true（ASC 商品登録・サンドボックス確認後）
  static const bool iapEnabled = false;

  static const _keyProUnlocked = 'pro_unlocked_v1';
  static const _keyDebugGating = 'debug_pro_gating_v1';
  static const _keyDebugForcePro = 'debug_force_pro_v1';

  static final InAppPurchase _iap = InAppPurchase.instance;

  static StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  static ProductDetails? _proProduct;
  static Completer<PurchaseActionResult>? _pendingAction;
  static bool _listening = false;
  static bool _restoreExpecting = false;
  static Timer? _restoreTimeout;

  /// ストアから取得した Pro 商品（価格表示用）。未取得なら null。
  static ProductDetails? get proProduct => _proProduct;

  /// ローカライズ済み価格文字列（例: `¥480`）。未取得なら null。
  static String? get proPrice => _proProduct?.price;

  static bool get _storeSupported {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// 起動時に呼ぶ。購入ストリーム購読と商品情報の先読み。
  static Future<void> init() async {
    if (!iapEnabled || !_storeSupported) {
      return;
    }
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        return;
      }
      await _ensureListening();
      await refreshProducts();
    } catch (e, st) {
      debugPrint('PurchaseService.init failed: $e\n$st');
    }
  }

  static Future<void> _ensureListening() async {
    if (_listening) {
      return;
    }
    _listening = true;
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object e, StackTrace st) {
        debugPrint('PurchaseService.purchaseStream error: $e\n$st');
        _finishPending(PurchaseActionResult.error);
      },
      onDone: () {
        _listening = false;
        _purchaseSub = null;
      },
    );
  }

  /// 商品詳細を再取得（ペイウォール表示前など）。
  static Future<bool> refreshProducts() async {
    if (!iapEnabled || !_storeSupported) {
      return false;
    }
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        _proProduct = null;
        return false;
      }
      await _ensureListening();
      final response = await _iap.queryProductDetails({productId});
      if (response.error != null) {
        debugPrint(
          'PurchaseService.queryProductDetails error: ${response.error}',
        );
      }
      if (response.productDetails.isEmpty) {
        _proProduct = null;
        if (response.notFoundIDs.isNotEmpty) {
          debugPrint(
            'PurchaseService: product not found: ${response.notFoundIDs}',
          );
        }
        return false;
      }
      _proProduct = response.productDetails.first;
      return true;
    } catch (e, st) {
      debugPrint('PurchaseService.refreshProducts failed: $e\n$st');
      _proProduct = null;
      return false;
    }
  }

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

  /// 購入成功時またはローカル解除で呼ぶ
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

  /// Pro 購入。IAP 有効時はストア、無効時は debug のみローカル解除。
  static Future<PurchaseActionResult> purchasePro() async {
    if (!iapEnabled) {
      if (kDebugMode) {
        await unlockPro();
        return PurchaseActionResult.unlockedLocally;
      }
      return PurchaseActionResult.unavailable;
    }

    if (await isPro()) {
      return PurchaseActionResult.alreadyPro;
    }
    if (!_storeSupported) {
      return PurchaseActionResult.unavailable;
    }

    final available = await _iap.isAvailable();
    if (!available) {
      return PurchaseActionResult.unavailable;
    }

    await _ensureListening();
    if (_proProduct == null) {
      await refreshProducts();
    }
    final product = _proProduct;
    if (product == null) {
      return PurchaseActionResult.unavailable;
    }

    if (_pendingAction != null && !_pendingAction!.isCompleted) {
      return PurchaseActionResult.pending;
    }

    final completer = Completer<PurchaseActionResult>();
    _pendingAction = completer;
    _restoreExpecting = false;

    try {
      final started = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) {
        _clearPending();
        return PurchaseActionResult.unavailable;
      }
    } catch (e, st) {
      debugPrint('PurchaseService.purchasePro failed: $e\n$st');
      _clearPending();
      return PurchaseActionResult.error;
    }

    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        _clearPending();
        return PurchaseActionResult.error;
      },
    );
  }

  /// 購入復元。IAP 有効時はストア、無効時は debug のみローカル解除。
  static Future<PurchaseActionResult> restorePurchases() async {
    if (!iapEnabled) {
      if (await isPro()) {
        return PurchaseActionResult.alreadyPro;
      }
      if (kDebugMode) {
        await unlockPro();
        return PurchaseActionResult.unlockedLocally;
      }
      return PurchaseActionResult.unavailable;
    }

    if (await isPro()) {
      return PurchaseActionResult.alreadyPro;
    }
    if (!_storeSupported) {
      return PurchaseActionResult.unavailable;
    }

    final available = await _iap.isAvailable();
    if (!available) {
      return PurchaseActionResult.unavailable;
    }

    await _ensureListening();

    if (_pendingAction != null && !_pendingAction!.isCompleted) {
      return PurchaseActionResult.pending;
    }

    final completer = Completer<PurchaseActionResult>();
    _pendingAction = completer;
    _restoreExpecting = true;
    _restoreTimeout?.cancel();
    _restoreTimeout = Timer(const Duration(seconds: 12), () {
      if (_restoreExpecting) {
        _finishPending(PurchaseActionResult.nothingToRestore);
      }
    });

    try {
      await _iap.restorePurchases();
    } catch (e, st) {
      debugPrint('PurchaseService.restorePurchases failed: $e\n$st');
      _restoreTimeout?.cancel();
      _clearPending();
      return PurchaseActionResult.error;
    }

    return completer.future;
  }

  static Future<void> _onPurchaseUpdated(
    List<PurchaseDetails> purchases,
  ) async {
    var sawProOwned = false;

    for (final purchase in purchases) {
      if (purchase.productID != productId) {
        if (purchase.pendingCompletePurchase) {
          await _safeComplete(purchase);
        }
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          // ユーザー操作待ち。Completer は維持。
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          sawProOwned = true;
          await unlockPro();
          if (purchase.pendingCompletePurchase) {
            await _safeComplete(purchase);
          }
          _finishPending(
            purchase.status == PurchaseStatus.restored
                ? PurchaseActionResult.restored
                : PurchaseActionResult.purchased,
          );
        case PurchaseStatus.error:
          if (purchase.pendingCompletePurchase) {
            await _safeComplete(purchase);
          }
          _finishPending(PurchaseActionResult.error);
        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            await _safeComplete(purchase);
          }
          _finishPending(PurchaseActionResult.canceled);
      }
    }

    // 復元で空リストだけ来た場合はタイムアウト待ち（何も所有していない）
    if (_restoreExpecting && purchases.isEmpty && !sawProOwned) {
      // 空の更新は無視し、タイマーに任せる
    }
  }

  static Future<void> _safeComplete(PurchaseDetails purchase) async {
    try {
      await _iap.completePurchase(purchase);
    } catch (e, st) {
      debugPrint('PurchaseService.completePurchase failed: $e\n$st');
    }
  }

  static void _finishPending(PurchaseActionResult result) {
    final pending = _pendingAction;
    if (pending == null || pending.isCompleted) {
      _restoreExpecting = false;
      _restoreTimeout?.cancel();
      _restoreTimeout = null;
      return;
    }
    _restoreExpecting = false;
    _restoreTimeout?.cancel();
    _restoreTimeout = null;
    pending.complete(result);
    _pendingAction = null;
  }

  static void _clearPending() {
    _restoreExpecting = false;
    _restoreTimeout?.cancel();
    _restoreTimeout = null;
    _pendingAction = null;
  }

  static Future<void> resetForTesting() async {
    _restoreTimeout?.cancel();
    _restoreTimeout = null;
    _clearPending();
    await _purchaseSub?.cancel();
    _purchaseSub = null;
    _listening = false;
    _proProduct = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProUnlocked);
    await prefs.remove(_keyDebugGating);
    await prefs.remove(_keyDebugForcePro);
  }
}

enum PurchaseActionResult {
  /// debug / IAP 無効時のローカル解除
  unlockedLocally,

  /// ストア購入完了
  purchased,

  /// ストア復元完了
  restored,

  alreadyPro,
  nothingToRestore,
  canceled,
  pending,
  error,
  unavailable,
}
