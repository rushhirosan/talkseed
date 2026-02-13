import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';

/// エラー表示用の共通ユーティリティ
class ErrorDialogHelper {
  ErrorDialogHelper._();

  /// データ読み込み失敗ダイアログを表示
  /// [onRetry] を渡すと「再試行」ボタンを表示
  static Future<void> showDataLoadError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.errorDataLoadTitle),
        content: Text(l10n.errorDataLoadMessage),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(l10n.retry),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dismiss),
          ),
        ],
      ),
    );
  }
}
