import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_dice/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PurchaseService.resetForTesting();
  });

  tearDown(() async {
    await PurchaseService.resetForTesting();
  });

  test('isPro is false by default', () async {
    expect(await PurchaseService.isPro(), isFalse);
  });

  test('unlockPro persists Pro state', () async {
    await PurchaseService.unlockPro();
    expect(await PurchaseService.isPro(), isTrue);
  });

  test('lockProForTesting clears Pro', () async {
    await PurchaseService.unlockPro();
    await PurchaseService.lockProForTesting();
    expect(await PurchaseService.isPro(), isFalse);
  });

  test('gating defaults on in debug; export requires Pro', () async {
    expect(await PurchaseService.isGatingActive(), isTrue);
    expect(await PurchaseService.canExportHistory(), isFalse);

    await PurchaseService.unlockPro();
    expect(await PurchaseService.canExportHistory(), isTrue);
  });

  test('free preset limit allows one save then blocks', () async {
    expect(await PurchaseService.canSaveNewPreset(0), isTrue);
    expect(await PurchaseService.canSaveNewPreset(1), isFalse);

    await PurchaseService.unlockPro();
    expect(await PurchaseService.canSaveNewPreset(5), isTrue);
    expect(
      await PurchaseService.maxPresetsAllowed(),
      PurchaseService.proPresetLimit,
    );
  });

  test('disabling debug gating restores free access', () async {
    await PurchaseService.setDebugGatingEnabled(false);
    expect(await PurchaseService.isGatingActive(), isFalse);
    expect(await PurchaseService.canExportHistory(), isTrue);
    expect(await PurchaseService.canSaveNewPreset(9), isTrue);
    expect(
      await PurchaseService.maxPresetsAllowed(),
      PurchaseService.proPresetLimit,
    );
  });

  test('debug force Pro overrides unlocked flag', () async {
    await PurchaseService.lockProForTesting();
    await PurchaseService.setDebugForcePro(true);
    expect(await PurchaseService.isPro(), isTrue);

    await PurchaseService.setDebugForcePro(false);
    expect(await PurchaseService.isPro(), isFalse);
  });

  test('setDebugProEnabled toggles on and off for retesting', () async {
    await PurchaseService.setDebugProEnabled(true);
    expect(await PurchaseService.isPro(), isTrue);
    expect(await PurchaseService.canExportHistory(), isTrue);

    await PurchaseService.setDebugProEnabled(false);
    expect(await PurchaseService.isPro(), isFalse);
    expect(await PurchaseService.canExportHistory(), isFalse);
  });

  test('purchasePro unlocks locally in debug', () async {
    final result = await PurchaseService.purchasePro();
    expect(result, PurchaseActionResult.unlockedLocally);
    expect(await PurchaseService.isPro(), isTrue);

    await PurchaseService.setDebugProEnabled(false);
    expect(await PurchaseService.isPro(), isFalse);
  });

  test('restorePurchases unlocks locally in debug', () async {
    final result = await PurchaseService.restorePurchases();
    expect(result, PurchaseActionResult.unlockedLocally);
    expect(await PurchaseService.isPro(), isTrue);
  });
}
