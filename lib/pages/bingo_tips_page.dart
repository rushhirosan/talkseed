import 'package:flutter/material.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/pages/mode_tips_page.dart';

/// 会話ビンゴの遊び方ヒント（[ModeTipsPage] への薄いラッパー）
class BingoTipsPage extends StatelessWidget {
  const BingoTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ModeTipsPage.forKind(ModeTipsKind.bingo, l10n);
  }
}
