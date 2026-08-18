import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// ダイアログ閉鎖直後に [TextEditingController] を破棄する。
///
/// ルートの退場アニメ中に TextField がまだ controller を参照していると
/// “used after being disposed” → InheritedWidget dependents アサーションになる。
void disposeTextControllerSoon(TextEditingController controller) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    controller.dispose();
  });
}
