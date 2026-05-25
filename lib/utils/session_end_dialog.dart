import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/pages/mode_selection_page.dart';
import 'package:theme_dice/pages/session_history_page.dart';
import 'package:theme_dice/services/review_prompt_service.dart';
import 'package:theme_dice/utils/route_transitions.dart';

/// セッション終了後の共通ダイアログ（終了 → トップ、履歴 → 履歴画面）。
class SessionEndDialog {
  SessionEndDialog._();

  static void navigateToModeSelection(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
      (route) => false,
    );
  }

  static void navigateToHistory(BuildContext context) {
    navigateToModeSelection(context);
    if (!context.mounted) return;
    Navigator.of(context).push(
      RouteTransitions.forwardRoute(page: const SessionHistoryPage()),
    );
  }

  /// 履歴保存済みである前提で、終了／履歴の選択ダイアログを表示する。
  /// 3回目のセッション完了後に App Store / Google Play のレビューを促す。
  static Future<void> show(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sessionSummary),
        content: Text(l10n.sessionCompleteAcknowledgeMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              navigateToModeSelection(context);
            },
            child: Text(l10n.sessionCompleteEndButton),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              navigateToHistory(context);
            },
            child: Text(l10n.historyTitle),
          ),
        ],
      ),
    );
    if (context.mounted) {
      await ReviewPromptService.onSessionCompleted();
    }
  }
}
