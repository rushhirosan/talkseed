import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// レイアウト／遷移アニメーション中の [Navigator] 操作を避け、次フレームで実行する。
void runAfterFrame(VoidCallback action) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    action();
  });
}

/// 戻れるときは pop。できなければ [orElse] を次フレームで実行。
void safePop(
  BuildContext context, {
  VoidCallback? orElse,
}) {
  runAfterFrame(() {
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    orElse?.call();
  });
}
