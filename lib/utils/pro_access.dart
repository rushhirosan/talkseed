import 'package:flutter/material.dart';

import 'package:theme_dice/services/preset_service.dart';
import 'package:theme_dice/services/purchase_service.dart';
import 'package:theme_dice/widgets/pro_paywall_sheet.dart';

/// Pro が必要な機能
enum ProFeature {
  /// 履歴テキスト共有
  historyExport,

  /// プリセット新規保存（無料枠あり）
  presetSave,
}

/// UI から Pro 可否を問い合わせる入口。未許可ならペイウォールを出す。
class ProAccess {
  ProAccess._();

  /// true = 続行可 / false = キャンセルまたは未購入のまま
  static Future<bool> ensure(
    BuildContext context, {
    required ProFeature feature,
  }) async {
    final allowed = switch (feature) {
      ProFeature.historyExport => await PurchaseService.canExportHistory(),
      ProFeature.presetSave => await PurchaseService.canSaveNewPreset(
          (await PresetService.listPresets()).length,
        ),
    };
    if (allowed) {
      return true;
    }
    if (!context.mounted) {
      return false;
    }
    final unlocked = await showProPaywallSheet(context);
    return unlocked == true;
  }
}
